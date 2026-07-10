// Triggered by a Supabase Database Webhook on INSERT into public.notifications
// (configure in Dashboard -> Database -> Webhooks, or via `supabase functions
// deploy` + a trigger; see CLAUDE.md for the general migration-apply gotchas
// in this project). Looks up the recipient's device_tokens and pushes via
// the FCM HTTP v1 API, using a Firebase service account for OAuth2.
//
// Required secrets (`supabase secrets set NAME=value`):
//   FIREBASE_PROJECT_ID       - Firebase project id
//   FIREBASE_SERVICE_ACCOUNT  - full service account JSON, as a single string
// SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are injected automatically by the
// Supabase Edge Functions runtime.

import { createClient } from 'npm:@supabase/supabase-js@2';
import { GoogleAuth } from 'npm:google-auth-library@9';

const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID')!;
const FIREBASE_SERVICE_ACCOUNT = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!);
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const auth = new GoogleAuth({
  credentials: FIREBASE_SERVICE_ACCOUNT,
  scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
});

interface NotificationRow {
  id: string;
  user_id: string;
  type: string;
  body: string;
  request_id: string | null;
}

Deno.serve(async (req) => {
  const payload = await req.json();
  const notification = payload.record as NotificationRow;

  const { data: tokens, error } = await supabase
    .from('device_tokens')
    .select('token')
    .eq('user_id', notification.user_id);

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
  if (!tokens || tokens.length === 0) {
    return new Response(JSON.stringify({ sent: 0, total: 0 }), { status: 200 });
  }

  const client = await auth.getClient();
  const { token: accessToken } = await client.getAccessToken();

  const staleTokens: string[] = [];

  const results = await Promise.all(
    tokens.map(async (row) => {
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: {
              token: row.token,
              notification: { title: 'Didim Usta', body: notification.body },
              data: {
                type: notification.type,
                request_id: notification.request_id ?? '',
              },
            },
          }),
        },
      );
      if (!response.ok) {
        const errorBody = await response.text();
        if (errorBody.includes('UNREGISTERED') || errorBody.includes('INVALID_ARGUMENT')) {
          staleTokens.push(row.token);
        }
      }
      return response.ok;
    }),
  );

  if (staleTokens.length > 0) {
    await supabase.from('device_tokens').delete().in('token', staleTokens);
  }

  const sent = results.filter(Boolean).length;
  return new Response(JSON.stringify({ sent, total: tokens.length }), { status: 200 });
});
