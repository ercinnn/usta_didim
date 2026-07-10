-- supabase_flutter's `.stream()` (used by messagesForRequestProvider and
-- myNotificationsProvider, both added alongside this migration's siblings)
-- subscribes via Supabase Realtime's postgres_changes feature, which only
-- fires for tables that are part of the supabase_realtime publication.
-- New tables aren't added to it automatically.

alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.notifications;
