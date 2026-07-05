# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A hyper-local service marketplace (like armut.com) for Didim, Aydın, connecting customers with local service providers ("usta"). Flutter client (mobile/web/desktop) backed by Supabase (Postgres + Auth + PostgREST).

## Commands

```bash
flutter pub get                      # install dependencies
flutter analyze                      # static analysis — must be clean before considering work done
flutter test                         # run all tests (currently one file: test/widget_test.dart)
flutter test test/widget_test.dart   # run the single test file

flutter run -d chrome                # run interactively (opens a real browser window — does not
                                      # work from a non-interactive/headless shell; use web-server instead, see below)
flutter run -d web-server --web-port=<port> --web-hostname=127.0.0.1   # headless dev server, open the URL manually
flutter build web --release          # release web build (build/web) — much faster/more reliable to
                                      # automate against than the debug web-server, which uses DDC and
                                      # can take 60s+ to compile on first load
flutter build apk --release          # release Android APK -> build/app/outputs/flutter-apk/app-release.apk

supabase db push --yes               # apply new migrations in supabase/migrations/ to the linked remote project
supabase login --token <token>       # CLI account-level auth (needed for db push / projects create / etc.)
```

No CI config exists in this repo. `flutter analyze` + `flutter test` are the only automated gates.

### Windows/Gradle gotcha
Android release builds on this machine can fail with `Could not read workspace metadata from ...\.gradle\caches\<ver>\transforms\...\metadata.bin` — a corrupted global Gradle cache unrelated to the project. Fix: `cd android && ./gradlew --stop` (must kill the daemon first, or the cache files are locked), then delete `~/.gradle/caches/<version>/` (or just its `transforms` subdir) and rebuild.

## Architecture

**Feature-first**, not layer-first: `lib/features/{auth,profile,requests,offers}/{data,domain,presentation}`. Cross-feature imports are normal and expected (e.g. `requests` reads the provider's category from `profile`, `offers` composes both `requests` and `profile` data) — don't try to fully decouple features.

- `lib/core/config/supabase_config.dart` — Supabase URL + publishable key (safe to expose client-side, protected by RLS). Never put the `service_role` key or a personal access token in client code.
- `lib/core/constants/` — shared constants used across features: `didimNeighborhoods` (strict 12-item list) and `serviceCategories`.
- Each feature follows `data/` (Supabase-backed repository, one per table), `domain/` (plain model classes with a `fromMap` factory matching the Postgres row shape, plus enum-like status classes with a `fromDb`/`.name` mapping to the DB's `text` check-constraint values), `presentation/` (Riverpod providers + screens).

**State management**: Riverpod 3.x, no code generation — plain `Provider`/`FutureProvider`/`FutureProvider.family`/`StreamProvider`. Note the Riverpod 3 API change: `AsyncValue.valueOrNull` was renamed to `.value`.

**Auth/navigation gating** (`lib/features/auth/presentation/auth_gate.dart` → `lib/features/profile/presentation/profile_gate.dart`): `MaterialApp.home` is `AuthGate`, which watches `authStateChangesProvider` and swaps between `LoginScreen` and `ProfileGate`. `ProfileGate` watches `currentProfileProvider`; if the profile's role is `provider`, it further gates on `currentProviderProfileProvider` to decide between `ProviderProfileScreen` (profile not completed yet) and `ProviderHomeScreen`. Customers go straight to `CustomerHomeScreen`.

Important: any screen that gets to this gate via `Navigator.push` (e.g. `SignUpScreen`, `ProviderProfileScreen`) must explicitly `Navigator.pop`/`popUntil` back to the root after finishing its action and invalidating the relevant provider. The gate widgets underneath do rebuild reactively, but if a pushed route is still on top of the Navigator stack, the user keeps seeing the pushed screen — this was a real bug (found via E2E testing) where sign-up completed successfully but the UI never advanced because nothing popped `SignUpScreen`.

### Supabase backend

Schema + RLS policies live in `supabase/migrations/`, applied via `supabase db push`. Four tables: `profiles` (1:1 with `auth.users`, has `role`: customer/provider), `providers` (1:1 with `profiles` for provider accounts, has `category`/`neighborhood`/`is_verified`), `service_requests` (customer's job postings), `offers` (provider bids on requests).

**RLS recursion gotcha**: a policy on table A that subqueries table B, where table B has a policy that subqueries table A (directly or transitively), makes Postgres reject it with `infinite recursion detected in policy for relation "..."` (42P17) at query time — regardless of whether the specific row-matching branch would ever actually be reached. This bit us twice in this schema (`providers` ↔ `offers` ↔ `service_requests` cycles). Fix pattern: wrap the cross-table check in a `SECURITY DEFINER` SQL function (owned by a role with `BYPASSRLS`, e.g. the migration-applying `postgres` role) so its internal query doesn't re-trigger RLS evaluation on the other table. See `20260706000100_fix_providers_offers_rls_recursion.sql` and `20260706000200_providers_see_requests_via_own_offers.sql` for the pattern (`provider_has_offer_on_customer_request`, `request_has_offer_from_provider`).

Nested/embedded PostgREST selects (e.g. `offers.select('*, providers(business_name, rating), service_requests(title, ...)')`) enforce RLS on the embedded table too — a row can be visible on the base table but its embedded fields come back null if the current user can't independently pass the embedded table's RLS. `lib/features/offers/domain/offer.dart` handles this by making the joined fields nullable.

### Testing against the real backend (E2E, not committed)

No E2E test suite is checked into the repo — verification during development was done ad hoc with Playwright driving `flutter build web --release` served statically. If doing this again:
- Flutter web (CanvasKit) paints to canvas; there's no real DOM text. Click `flt-semantics-placeholder` once per page load to enable the accessibility tree, which then populates real DOM nodes (`aria-label` on text field inputs, `role="button"`/`role="radio"` with visible text content on tappable widgets).
- `DropdownButtonFormField` menu overlays and non-selected `TabBar` tab labels never attach to the semantics/DOM tree at all (canvas-only), even with accessibility enabled. They can't be targeted by any DOM selector — only raw coordinate clicks (`page.mouse.click(x, y)`) work, computed from the trigger's bounding box plus item index × row height (~48px), or from a screenshot.
- `flutter run -d chrome` reliably fails to launch a real browser window from a non-interactive shell in this environment ("Failed to launch browser after 3 tries") — use `-d web-server` and open the URL in an actual browser session instead.
