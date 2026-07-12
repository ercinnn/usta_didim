// Mints a short-lived presigned PUT URL for Cloudflare R2 so the Flutter app
// can upload service-request photos directly to R2 without R2 credentials
// ever touching the client. Called from
// lib/features/requests/data/r2_upload_repository.dart via
// supabase.functions.invoke, which attaches the caller's own access token --
// verified here with auth.getUser() so only genuinely signed-in users (not
// just anon-key holders) can mint upload URLs.
//
// Required secrets (`supabase secrets set NAME=value`, or Dashboard ->
// Edge Functions -> Secrets):
//   R2_ACCOUNT_ID        - Cloudflare account id
//   R2_ACCESS_KEY_ID     - R2 API token access key id
//   R2_SECRET_ACCESS_KEY - R2 API token secret access key
//   R2_BUCKET_NAME       - target R2 bucket name
//   R2_PUBLIC_BASE_URL   - public base URL for reading objects back (the
//                          bucket's r2.dev subdomain or a custom domain),
//                          no trailing slash
// SUPABASE_URL / SUPABASE_ANON_KEY are injected automatically.

import { createClient } from 'npm:@supabase/supabase-js@2';
import { AwsClient } from 'npm:aws4fetch@1';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const R2_ACCOUNT_ID = Deno.env.get('R2_ACCOUNT_ID')!;
const R2_ACCESS_KEY_ID = Deno.env.get('R2_ACCESS_KEY_ID')!;
const R2_SECRET_ACCESS_KEY = Deno.env.get('R2_SECRET_ACCESS_KEY')!;
const R2_BUCKET_NAME = Deno.env.get('R2_BUCKET_NAME')!;
const R2_PUBLIC_BASE_URL = Deno.env.get('R2_PUBLIC_BASE_URL')!;

const R2_ENDPOINT = `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`;

const r2Client = new AwsClient({
  accessKeyId: R2_ACCESS_KEY_ID,
  secretAccessKey: R2_SECRET_ACCESS_KEY,
  service: 's3',
  region: 'auto',
});

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const CONTENT_TYPE_EXTENSIONS: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

function jsonResponse(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return jsonResponse({ error: 'Missing Authorization header' }, 401);
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) {
    return jsonResponse({ error: 'Unauthorized' }, 401);
  }

  const { contentType } = await req.json();
  const extension = CONTENT_TYPE_EXTENSIONS[contentType];
  if (!extension) {
    return jsonResponse({ error: 'Unsupported content type' }, 400);
  }

  const key = `service-requests/${userData.user.id}/${crypto.randomUUID()}.${extension}`;

  const url = new URL(`${R2_ENDPOINT}/${R2_BUCKET_NAME}/${key}`);
  url.searchParams.set('X-Amz-Expires', '300');
  const signedRequest = await r2Client.sign(url.toString(), {
    method: 'PUT',
    aws: { signQuery: true },
  });

  return jsonResponse(
    {
      uploadUrl: signedRequest.url,
      publicUrl: `${R2_PUBLIC_BASE_URL}/${key}`,
    },
    200,
  );
});
