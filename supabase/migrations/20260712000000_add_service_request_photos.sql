-- Up to 5 customer-uploaded photos per service request, stored in Cloudflare
-- R2 (not Supabase Storage) via a presigned PUT URL minted by the
-- r2-presigned-upload Edge Function -- see supabase/functions/r2-presigned-upload/.
-- No RLS change needed: the existing "profiles: insert/update own" style
-- policies on service_requests already check auth.uid() = customer_id
-- regardless of which columns are written.
alter table public.service_requests
  add column photo_urls text[] not null default '{}';

alter table public.service_requests
  add constraint service_requests_photo_urls_max5
  check (array_length(photo_urls, 1) is null or array_length(photo_urls, 1) <= 5);
