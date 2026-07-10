-- FCM device tokens, one row per (user, installation). The
-- send-push-notification Edge Function (supabase/functions/) reads this
-- table -- via its own service-role key, bypassing RLS -- whenever a row is
-- inserted into notifications, to know which devices to push to.

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('android', 'web')),
  created_at timestamptz not null default now()
);

create index on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

create policy "device_tokens: manage own"
  on public.device_tokens for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
