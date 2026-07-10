-- Per-request chat (opens once a customer accepts a provider's offer) and an
-- in-app notification feed. Notifications are never inserted by app code --
-- like refresh_provider_rating (20260707120000_add_reviews.sql), SECURITY
-- DEFINER triggers write them server-side, because the recipient of a
-- notification is often not the actor who caused it (e.g. a provider
-- submitting an offer writes a notification row for the customer, who has no
-- RLS grant to let the provider insert into their notifications directly).

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.service_requests (id) on delete cascade,
  sender_id uuid not null references public.profiles (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create index on public.messages (request_id, created_at);

alter table public.messages enable row level security;

-- Messages is a brand new leaf table that offers/service_requests policies
-- never reference back, so (like reviews) this doesn't need the
-- SECURITY DEFINER cross-table bypass used for the providers/offers cycle.

create policy "messages: participants select"
  on public.messages for select
  using (
    exists (
      select 1 from public.service_requests sr
      where sr.id = messages.request_id
        and sr.customer_id = auth.uid()
    )
    or exists (
      select 1 from public.offers o
      where o.request_id = messages.request_id
        and o.provider_id = auth.uid()
        and o.status = 'accepted'
    )
  );

create policy "messages: participants insert"
  on public.messages for insert
  with check (
    sender_id = auth.uid()
    and (
      exists (
        select 1 from public.service_requests sr
        where sr.id = messages.request_id
          and sr.customer_id = auth.uid()
      )
      or exists (
        select 1 from public.offers o
        where o.request_id = messages.request_id
          and o.provider_id = auth.uid()
          and o.status = 'accepted'
      )
    )
  );

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null check (type in ('new_offer', 'offer_accepted', 'new_message', 'request_completed')),
  request_id uuid references public.service_requests (id) on delete cascade,
  body text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;

-- No insert policy: rows only ever come from the SECURITY DEFINER triggers
-- below, never directly from client code.

create policy "notifications: select own"
  on public.notifications for select
  using (user_id = auth.uid());

create policy "notifications: update own"
  on public.notifications for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ---------- triggers ----------

create or replace function public.notify_customer_on_new_offer()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_customer_id uuid;
  v_business_name text;
begin
  select customer_id into v_customer_id
  from service_requests where id = new.request_id;

  select business_name into v_business_name
  from providers where id = new.provider_id;

  insert into notifications (user_id, type, request_id, body)
  values (
    v_customer_id,
    'new_offer',
    new.request_id,
    coalesce(v_business_name, 'Bir usta') || ' ' || new.price || ' TL teklif verdi.'
  );
  return new;
end;
$$;

create trigger offers_after_insert_notify_customer
  after insert on public.offers
  for each row execute function public.notify_customer_on_new_offer();

create or replace function public.notify_provider_on_offer_accepted()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_title text;
begin
  if new.status = 'accepted' and old.status is distinct from new.status then
    select title into v_title
    from service_requests where id = new.request_id;

    insert into notifications (user_id, type, request_id, body)
    values (
      new.provider_id,
      'offer_accepted',
      new.request_id,
      'Teklifiniz kabul edildi: ' || coalesce(v_title, 'iş')
    );
  end if;
  return new;
end;
$$;

create trigger offers_after_update_notify_provider
  after update on public.offers
  for each row execute function public.notify_provider_on_offer_accepted();

create or replace function public.notify_on_new_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_customer_id uuid;
  v_accepted_provider_id uuid;
  v_recipient uuid;
begin
  select customer_id into v_customer_id
  from service_requests where id = new.request_id;

  select provider_id into v_accepted_provider_id
  from offers where request_id = new.request_id and status = 'accepted'
  limit 1;

  if new.sender_id = v_customer_id then
    v_recipient := v_accepted_provider_id;
  else
    v_recipient := v_customer_id;
  end if;

  if v_recipient is not null then
    insert into notifications (user_id, type, request_id, body)
    values (v_recipient, 'new_message', new.request_id, left(new.body, 120));
  end if;
  return new;
end;
$$;

create trigger messages_after_insert_notify
  after insert on public.messages
  for each row execute function public.notify_on_new_message();

create or replace function public.notify_provider_on_request_completed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_provider_id uuid;
  v_title text;
begin
  if new.status = 'completed' and old.status is distinct from new.status then
    select provider_id into v_provider_id
    from offers where request_id = new.id and status = 'accepted'
    limit 1;

    if v_provider_id is not null then
      insert into notifications (user_id, type, request_id, body)
      values (
        v_provider_id,
        'request_completed',
        new.id,
        coalesce(new.title, 'İş') || ' tamamlandı olarak işaretlendi.'
      );
    end if;
  end if;
  return new;
end;
$$;

create trigger service_requests_after_update_notify_completed
  after update on public.service_requests
  for each row execute function public.notify_provider_on_request_completed();
