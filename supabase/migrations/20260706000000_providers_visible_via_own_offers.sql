-- Customers must be able to see the business name/rating of any provider
-- (verified or not) who has submitted an offer on one of their own requests,
-- otherwise unverified providers would be invisible on their own bids.
create policy "providers: select via own offers"
  on public.providers for select
  using (
    id in (
      select provider_id from public.offers
      where request_id in (
        select id from public.service_requests where customer_id = auth.uid()
      )
    )
  );
