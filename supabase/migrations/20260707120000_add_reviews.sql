-- Customers can leave a single 1-5 star rating (+ optional comment) on a
-- completed request, for the provider whose offer was accepted. Inserting a
-- review recalculates providers.rating as the average of all their reviews,
-- so the rating already surfaced throughout the app (offer tiles, provider
-- profile) becomes real data instead of an always-null column.

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null unique references public.service_requests (id) on delete cascade,
  provider_id uuid not null references public.providers (id) on delete cascade,
  customer_id uuid not null references public.profiles (id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now()
);

create index on public.reviews (provider_id);

alter table public.reviews enable row level security;

-- Reviews are only visible to the customer who wrote them and the provider
-- they're about -- matching the conservative visibility already used for
-- offers (no public review feed in this MVP).

create policy "reviews: customer select own"
  on public.reviews for select
  using (customer_id = auth.uid());

create policy "reviews: provider select own"
  on public.reviews for select
  using (provider_id = auth.uid());

-- A review can only be inserted by the request's customer, once the request
-- is completed, and only naming the provider whose offer was actually
-- accepted on it. This doesn't need the SECURITY DEFINER cross-table
-- bypass used elsewhere in this schema: reviews is a brand new table that
-- offers/service_requests policies never reference back, so there's no
-- circular RLS dependency to break.

create policy "reviews: customer insert for own completed request"
  on public.reviews for insert
  with check (
    customer_id = auth.uid()
    and exists (
      select 1 from public.service_requests sr
      where sr.id = request_id
        and sr.customer_id = auth.uid()
        and sr.status = 'completed'
    )
    and exists (
      select 1 from public.offers o
      where o.request_id = reviews.request_id
        and o.provider_id = reviews.provider_id
        and o.status = 'accepted'
    )
  );

-- Keep providers.rating in sync with the average of their reviews. Runs as
-- SECURITY DEFINER because the reviewing customer has no RLS grant to update
-- the providers row directly (see "providers: update own").

create or replace function public.refresh_provider_rating()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.providers
  set rating = (
    select avg(rating)::numeric(3,2)
    from public.reviews
    where provider_id = new.provider_id
  )
  where id = new.provider_id;
  return new;
end;
$$;

create trigger reviews_after_insert_refresh_rating
  after insert on public.reviews
  for each row execute function public.refresh_provider_rating();
