-- Providers need to see the full service_request row (title, description,
-- neighborhood, preferred_date, status) for any request they've submitted an
-- offer on, even after its status moves away from 'open' (e.g. once accepted)
-- -- otherwise "My Active Jobs" couldn't show accepted jobs. A direct subquery
-- to offers here would recreate the same RLS cycle fixed in the previous
-- migration (service_requests -> offers -> service_requests), so this uses
-- the same SECURITY DEFINER bypass pattern.

create or replace function public.request_has_offer_from_provider(check_request_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from offers
    where request_id = check_request_id
      and provider_id = auth.uid()
  );
$$;

create policy "service_requests: provider select via own offer"
  on public.service_requests for select
  using (
    public.request_has_offer_from_provider(id)
  );
