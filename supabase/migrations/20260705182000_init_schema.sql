-- Extensions
create extension if not exists pgcrypto;

-- =========================================
-- Tables
-- =========================================

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  phone text,
  role text not null check (role in ('customer', 'provider')),
  created_at timestamptz not null default now()
);

create table public.providers (
  id uuid primary key references public.profiles (id) on delete cascade,
  business_name text not null,
  category text not null,
  description text,
  neighborhood text not null,
  is_verified boolean not null default false,
  rating numeric,
  created_at timestamptz not null default now()
);

create table public.service_requests (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles (id) on delete cascade,
  category text not null,
  title text not null,
  description text,
  neighborhood text not null,
  preferred_date timestamptz,
  status text not null default 'open' check (status in ('open', 'pending', 'completed', 'cancelled')),
  created_at timestamptz not null default now()
);

create table public.offers (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.service_requests (id) on delete cascade,
  provider_id uuid not null references public.providers (id) on delete cascade,
  price numeric not null,
  note text,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'rejected')),
  created_at timestamptz not null default now()
);

create index on public.providers (category);
create index on public.service_requests (status, category);
create index on public.offers (request_id);
create index on public.offers (provider_id);

-- =========================================
-- Row Level Security
-- =========================================

alter table public.profiles enable row level security;
alter table public.providers enable row level security;
alter table public.service_requests enable row level security;
alter table public.offers enable row level security;

-- ---------- profiles ----------
-- Users can read and update only their own profile. Insert is required so the
-- app can create the profile row right after sign-up.

create policy "profiles: select own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: insert own"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles: update own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ---------- providers ----------
-- Anyone can read verified providers. Providers can manage their own row
-- (needed to create/edit their profile and to see it before verification).

create policy "providers: select verified or own"
  on public.providers for select
  using (is_verified = true or auth.uid() = id);

create policy "providers: insert own"
  on public.providers for insert
  with check (auth.uid() = id);

create policy "providers: update own"
  on public.providers for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ---------- service_requests ----------
-- Customers can insert requests and manage only their own requests.
-- Providers can view open requests that match their category.

create policy "service_requests: customer select own"
  on public.service_requests for select
  using (auth.uid() = customer_id);

create policy "service_requests: provider select open matching category"
  on public.service_requests for select
  using (
    status = 'open'
    and category in (
      select category from public.providers where id = auth.uid()
    )
  );

create policy "service_requests: customer insert own"
  on public.service_requests for insert
  with check (auth.uid() = customer_id);

create policy "service_requests: customer update own"
  on public.service_requests for update
  using (auth.uid() = customer_id)
  with check (auth.uid() = customer_id);

create policy "service_requests: customer delete own"
  on public.service_requests for delete
  using (auth.uid() = customer_id);

-- ---------- offers ----------
-- Providers can only see their own offers. Customers can see all offers
-- submitted to their own requests. Providers cannot see other providers' offers.

create policy "offers: provider select own"
  on public.offers for select
  using (auth.uid() = provider_id);

create policy "offers: customer select for own requests"
  on public.offers for select
  using (
    request_id in (
      select id from public.service_requests where customer_id = auth.uid()
    )
  );

create policy "offers: provider insert own"
  on public.offers for insert
  with check (auth.uid() = provider_id);

create policy "offers: provider update own"
  on public.offers for update
  using (auth.uid() = provider_id)
  with check (auth.uid() = provider_id);

create policy "offers: customer update status for own requests"
  on public.offers for update
  using (
    request_id in (
      select id from public.service_requests where customer_id = auth.uid()
    )
  )
  with check (
    request_id in (
      select id from public.service_requests where customer_id = auth.uid()
    )
  );
