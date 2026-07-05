-- The "providers: select via own offers" policy created a circular RLS
-- dependency: providers -> offers -> service_requests -> providers, which
-- Postgres rejects with "infinite recursion detected in policy" (42P17).
-- A SECURITY DEFINER helper function breaks the cycle: its internal lookups
-- run with the function owner's privileges (bypassing RLS) instead of
-- re-triggering the calling table's policy evaluation.

drop policy "providers: select via own offers" on public.providers;

create or replace function public.provider_has_offer_on_customer_request(check_provider_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from offers o
    join service_requests sr on sr.id = o.request_id
    where o.provider_id = check_provider_id
      and sr.customer_id = auth.uid()
  );
$$;

create policy "providers: select via own offers"
  on public.providers for select
  using (
    public.provider_has_offer_on_customer_request(id)
  );
