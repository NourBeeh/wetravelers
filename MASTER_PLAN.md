# WeTravellers — Master Execution Plan (MERGED v2)

> **نقطة الاستكمال في أي سيزون جديد:** اقرأ الملف ده كامل + AGENTS.md + الملفين الأصليين (`محرك التوصيات.txt`, `UNIVERSAL SEARCH MASTER.txt`) حسب المرحلة اللي هتنفذها + `git status --short`. نفّذ أول مرحلة PENDING حسب "الترتيب المتفق عليه" تحت. الملف ده مصدر الحقيقة الوحيد.
> **PENDING DECISIONS قسم في الآخر — عشان أي اقتراح جديد محتاج موافقة صريحة قبل التنفيذ.**

---

## Resume protocol (any new session)

1. Read THIS file fully → AGENTS.md → the source prompt file for the target phase (`محرك التوصيات.txt` = memory/booking/trip track, `UNIVERSAL SEARCH MASTER.txt` = search track).
2. `git status --short` — the working tree is SHARED with the Universal Search workstream (their US-2 work is uncommitted).
3. Execute the first PENDING phase in the "Agreed execution order". Confirm with the user first. Per-phase: implement → validate → report → STOP, wait for approval.
4. Update this file's status markers after each phase (this file IS the progress log).

## Execution protocol (non-negotiable — from both source plans + AGENTS.md)

- Per phase: **implement → test → fix errors → report → STOP**. Never start the next phase without user approval.
- Validation: Flutter phases → `dart analyze lib test` + `flutter test` (0 failed, 0 analyzer errors); backend phases → `npx tsc --noEmit` + full Jest.
- No commit / push (US-1-FINAL was the single approved exception; already done). No file deletion without explicit approval. No package installation without approval. No destructive git.
- Never modify Home Ranking / Recommendation Engine / EventsTracker implementation / Product Card architecture / Booking architecture / Theme / SearchIntentParser behavior **unless the phase explicitly authorizes it**.
- No ML / vector DB / embeddings. Cache is never price/availability truth.
- If a defect is found in a file owned by the OTHER workstream (list below): **report it, do not fix without approval**.
- `backend/test-nuitee.ts`: never modify/delete/commit.
- Any NEW idea or change to an existing decision → **ask the user FIRST** (see PENDING DECISIONS).

## Workstream boundary — Universal Search agent (WIP) — DO NOT MODIFY until landed

Until the user confirms US-2 has landed and is committed:
- `lib/features/universal_search/**` (all)
- `lib/features/ai/data/ai_api_service.dart`, `application/ai_providers.dart`, `domain/search_intent_parser.dart`, `presentation/pages/ai_chat_page.dart`, `ai_visual_shell_page.dart`
- `backend/src/modules/ai/**`, `backend/src/common/dto/ai.dto.ts`, `backend/src/modules/events/**`, `backend/src/modules/profile/*` (their edits), `backend/src/app.module.ts` (their edits)
- `lib/app/config/app_config.dart`, `test/features/universal_search/**`, `test/features/ai/**` (their edits)
- STATUS VERIFIED 2026-09-06: US-0 ✅ (contract doc exists `docs/universal-search-ux-contract.md`) · US-1 ✅ + US-1-FINAL ✅ (commit 794ebcb9, zero legacy refs) · **US-2 ⏳ in progress uncommitted** (parser enhanced with `_isNumericFragment`/budget/months, `StructuredTravelIntent` extended with rooms/budget/minStars/amenities, gap-chip flow `fillGap`, 60+ tests added) — looks near-complete, awaiting their validation + report.

## Ground truth (verified in code 2026-09-06)

Backend done: Memory Spine 2A (`/memory/me`), 2B DerivedPreferenceProfile + ranking, 2C-A/B `POST /ai/chat` + selector + extraction. Flutter done: 2A MemoryRepository+tests; Universal Search US-0/US-1 (state machine, Hero container transform 320ms, query persistence, adapters → HomeItem, categories); Home is **Nuitee-only** (uncommitted: Postgres purged 4 sections+10 cards, empty feed authoritative, stale snapshots dropped, hotels flip preview→success; home/repo suites 137 passed; full `flutter test` interrupted → M0). Search infra: 3 vertical controllers (flight/hotel/car) cancellable; `/smart-search` root route; EventsTracker 5 event types.

---

# PHASES

## Track A — Home & Platform (this workstream) — ✅ approved direction

### M0 — Finish validation of Nuitee-only Home + record baseline — ✅ DONE (2026-09-06)
- `dart analyze lib test`: **0 errors** (137 infos — mostly inside US-2 WIP files, reported not fixed).
- `flutter test` full suite: **631 passed / ~6 skipped / 0 failed** (baseline was 568 pre-US-2 — the delta is the other agent's US-2 work, all green).
- Backend `npx tsc --noEmit`: **clean**.
- **NEW BASELINE: 631 passed.** US-2 WIP observations for the other agent (do not fix ourselves): unnecessary dart:async import + underscore local var in `universal_search_controller_test.dart`.

### H1 — Single skeleton rail + remove pull-to-refresh — ✅ DONE (2026-09-06)
- `home_page.dart`: removed `RefreshIndicator` wrapper (comment documents the H1 decision); added `_SkeletonRecommendedRail` + `_SkeletonHotelCard` — EXACT geometry of the real rail (same fixed title, 220px height, 260px cards, 120px image, text rows). Renders only when `recommendedHotels.isEmpty && sections.isEmpty` (Nuitee-only loading state); real rail/composed sections replace it with zero layout jump.
- `home_controller.dart`: `refresh()` removed (documented as H1 product decision; repository `refresh()` hook stays — it's the HomeRepository contract).
- `_developmentPreviewSections()` KEPT intact for future phases (no deletion).
- NEW test file `test/features/home/presentation/pages/home_skeleton_rail_test.dart` (3 tests: fixed title, ≥3 skeleton cards + zero RefreshIndicator, zero fake travel data). Controller pinned via `homeControllerProvider.overrideWith` + inert repo.
- Retired test: 'HomeController refresh triggers repo refresh' (documented in place).
- **VALIDATION: flutter test = 633 passed / ~6 skipped / 0 failed (baseline 631 → 633: +3 new, -1 retired). dart analyze = 0 errors.**

### H2 — Refresh = price/availability only — ✅ DONE (2026-09-06)
- `home_controller.dart`: NEW public `refreshPrices()` → routes through the existing `_runLiveValidation()` ONLY (no feed/hotel/image reload). All guards apply (one job per snapshot, content-on-screen, empty-sections no-op → Nuitee-only Home is a safe no-op until 7B sections return).
- `home_page.dart`: `HomePage` → `ConsumerStatefulWidget` with `WidgetsBindingObserver` (app resume → refreshPrices) + GoRouter delegate listener (returning to '/' from any sub-route/tab → refreshPrices). Router hook is LAZY via `GoRouter.maybeOf` in `didChangeDependencies` (test hosts without GoRouter stay valid); unhook in dispose uses the saved router reference (no ancestor lookup in dispose).
- NEW test `test/features/home/h2_refresh_prices_test.dart` (3 tests: revalidates WITHOUT feed/hotels re-fetch (delta-asserted), safe no-op on empty Nuitee-only Home, burst calls collapse into one job via in-flight guard). Spy service pattern over HomeLiveValidationService.
- **P2 APPROVED by user (2026-09-06):** ResizeImage/cacheWidth decode in H3 image cache + external packages allowed WITH per-case confirmation.
- **VALIDATION: flutter test = 636 passed / ~6 skipped / 0 failed (633 → 636: +3 H2 tests). dart analyze = 0 errors. Full-app smoke test green after router-hook fix.**

### H3 — Hotel image cache (Hive) — ✅ DONE (2026-09-07)
- `lib/features/home/application/hotel_image_cache.dart`: `HotelImageCache` — LRU (cap 30) + TTL (7 days) on top of the EXISTING shared `OfflineCache` box (keys `hotel_image|<url>`), no new Hive box, no packages. Best-effort everywhere (never throws); lazy TTL eviction on read + TTL/LRU sweep on write.
- `lib/features/home/presentation/widgets/cached_hotel_image.dart`: `CachedHotelImage` — shimmer placeholder (H1 primitive) on miss → fetch (shared per-URL `_inFlight`) → store → render; P2 approved decode `Image.memory(cacheWidth: displayWidth×dpr)`; network failure → neutral fallback icon, never throws.
- Wired: hotel card image in `home_page.dart` (rail) + `hotelImageCacheProvider` in `home_providers.dart`.
- Tests: `test/features/home/h3_hotel_image_cache_test.dart` (7 service + 4 widget).
  - **Fix during close-out:** widget tests were hanging forever ("did not complete" + "Bad state: Cannot add event while adding stream" on kill) — root cause: `_pngBytes()` used `PictureRecorder→toImage()→toByteData()`, real engine-async work the testWidgets FakeAsync zone cannot drive. Replaced with constant 1×1 PNG bytes (69B). Also updated 2 pre-P2 assertions to expect the `ResizeImage(MemoryImage)` shape.
- **VALIDATION: flutter test = 647 passed / ~6 skipped / 0 failed (636 → 647: +11 H3). dart analyze = 0 errors (138 infos/warnings pre-existing, mostly US-2 WIP files — reported, not fixed). No orphan flutter_tester processes at close.**

### NAV — Remove bottom nav; Home-centric navigation — PENDING (user notes)
- Remove `AppBottomNav` + 4-tab shell; merge Explore + Search hub into Home; Home navigation buttons row (flights/hotels/cars/packages +transfers → existing routes); Groups → Home button/section. Explore/Groups are v1 mock → dissolve into Home discovery awaiting real sources (7B).
- **COORDINATION:** must land AFTER US-2 completes (router + `/smart-search` root behavior are shared; US contract requires root/branch navigation intact). Profile/AI-chat need new root routes once the shell is gone.

## Track B — Universal Search (other agent's file, merged order)

### US-2 — Advanced intent + NLP — ⏳ THEIRS, in progress (see boundary)
- After they land: I validate baseline + merge their report here. Parser enhancement authorized ONLY in US-2 (done by them). Gap-chips (ask, never invent) + AI resolution → StructuredTravelIntent only.
- **BLOCKER NOTE (2026-09-07, from H3 close): US-2 must land before NAV.** Current next-in-order after H3 = [US-2 lands (theirs) → validate+merge] → NAV.

### US-3 — Voice search — PENDING
- Replace disabled mic with real STT into the SAME query (no parallel state). Arabic+English, full error handling, semantics.
- **PROPOSAL P1 (needs approval):** `speech_to_text` package (pub.dev, csdcorp — the community standard, Android/iOS/web). Requires explicit package approval. If declined → keep placeholder, defer US-3.

### US-4 — AI assistant inside Universal Search — PENDING
- Narrative line + real product sections + follow-up chips (أرخص/أفخم/قريب من/قارن/غيّر التواريخ) patching StructuredTravelIntent → SEARCHING. NO free-form chat loop. AI failure → deterministic search. Safe structured context only.

### US-5 — Search personalization — PENDING
- Existing behavioral signals + profile context (EventsTracker, R-4 architecture untouched). Personalization may order/suggest — NEVER override explicit intent (Dubai wins over habitual Cairo). 2C rule: no explicit memory facts into DerivedPreferenceProfile/Home ranking (that's Phase 7's job, separately approved).

### US-6 — Compare + refinement — PENDING
- Contract-based comparison on structured fields (hotel/flight/car field lists in spec). Refinements patch intent or explicit SearchFilter → SEARCHING. Preserve query+refinement state on back.

### US-7 — Production hardening (Universal Search) — PENDING (placed after 7B — see order)
- Full audit: state machine, Hero handoff pixel-stability, keyboard (iOS/Android/desktop/web), back behavior, query persistence, suggestions debounce/cancellation, AI fallback, adapters, events, cache, accessibility, responsive, performance (rebuilds/leaks/timers).
- **PROPOSAL P5 (needs approval):** add Android 14 **predictive back** verification (`PopScope.canPop` ahead-of-time API — per docs.flutter.dev) to the audit checklist, since US-0 deferred it to US-2+.

## Track C — Memory & AI (from محرك التوصيات)

### 2C-C1 — Flutter wiring `POST /ai/chat` — PENDING
- NEW FILES ONLY (ai_chat_repository + provider + DTOs). Zero edits to WIP files. `prompt ≤ 4000`, authenticated → `/ai/chat`, guest → `/ai/query` unchanged. Flutter never extracts memories / decides relevance / sends raw transcript.
- Tests: serialization, parsing, limit, auth, server error, timeout, malformed, repo/controller.

### 2C-C2 — Memory Controls + Chat UI — PENDING
- "What I Know About You": 3 types (preferred_destination/budget/travel_style) view/Edit/Delete/Clear-all via EXISTING MemoryRepository (2A). No new backend, no raw fields, no vocabulary beyond the 3. Premium Light + RTL/LTR. Personalization disabled → no memory context.
- Chat wiring touches `ai_chat_page.dart` (WIP) → coordinate first.

### 2D — AI context hardening — PENDING
- Audit full path (chat → selector → context → provider → Flutter): guest isolation, disabled behavior, expiration, ownership, sensitive scanner, prompt-injection boundaries (memory = untrusted data, never instructions), failure isolation, no memory values in logs. Security + isolation regression tests.

### PH-7 — Explicit Memory → Home Ranking (the deliberately deferred standalone phase) — PENDING
- `ExplicitPreferenceSignal` adapter; NEVER conversation→behavior type conversion; DerivedPreferenceProfile semantics untouched; behavioral memory stays separate.
- Precedence: hard validity > explicit user signal > 2B explicit profile prefs > derived behavioral > deterministic score > stable tie-breaker. Explicit wins on conflict; never overrides availability/price/provider truth.
- Batch retrieval only (no N+1, no per-card, no AI calls in ranking). Expired/wrong-user/wrong-type ignored; no duplicate-key inflation; latest value on same-key conflict.
- `preferred_travel_style`: verify a deterministic consumer exists; else implement the other two + document deferral.
- Deliverables: explicit signal CONTRACT documented, signal PRIORITY separated from result ORDERING, integration point rationale, full regression, final report confirmations (2B intact, /ai/rerank whitelist unchanged, cache-first intact, no AI call in ranking, no ML/vector).

## Track D — Search backend & verticals (from محرك التوصيات; feeds US-5/US-6)

### 3A — Unified search foundation — PENDING
- Domain models + contracts (Flight/Hotel/Car/Package), Repository→UseCase→Controller, Riverpod state, backend aggregation contract, loading/error/empty, cancellation/debounce, state preservation. NO booking/payment/details UI. Providers: Doville (flights) / Nuitee (hotels) / cars TBD / packages = current backend only. Never invent a provider.
### 3B — Provider aggregation — PENDING
- Doville + Nuitee normalized into unified models; provider IDs preserved; per-provider timeout; partial failure isolation; deterministic dedup; currency/price normalization without inventing prices; cached price never = booking truth.
### 3C — Results + filters + sorting — PENDING
- Uses existing Card Engine (FlightSearchCard/HotelSearchCard/PackageSearchCard/CarSearchCard). Provider-safe filters; sorting (price/rating/duration; "recommended" only if deterministic backend-supported). No AI rerank unless existing contract ready.
### 3D — Product details — PENDING
- Flight (route/times/stops/baggage/fare), Hotel (images/stars/room-rates/cancellation/taxes), Car (model/seats/transmission/mileage), Package (cities/inclusions). Provider data only; CTA passes revalidation.

## Track E — Booking & payment

### 4A — Booking foundation — PENDING
- Domain model + status lifecycle + repos/use cases; `/bookings/prepare` `/bookings/revalidate` `/bookings`. Never trust Hive snapshot as final price; revalidate before commit; provider identity mandatory; **idempotency mandatory** (no double booking on retry); normalized errors; no payment yet.
### 4B — Flight booking (Doville only) — PENDING
- Search → Details → Revalidate → Passenger → Prepare → Booking → Status. Retry-safe, failure recovery. Tests: expired offer/price change/success/provider failure/duplicate/malformed.
### 4C — Hotel booking (Nuitee) — PENDING
- Search → Details → Room/Rate → Revalidate → Guest → Prepare → Booking → Confirmation. Respect cancellation policy/rate conditions/taxes/occupancy; provider reference.
### 4D — Car + package booking — PENDING
- Real provider only; else domain/contracts WITHOUT fake booking. No invented car provider, no fake inventory.
### 4E — Payment + confirmation — PENDING
- Approved Egyptian gateway ONLY. Intent/session, secure redirect/webview, **server-side verification**, webhook handling, idempotency, payment lifecycle, booking/payment consistency, confirmation screen + reference. NEVER store card/CVV, never log secrets, never trust client callback alone.

## Track F — Trip

### 5A — Unified Trip model — PENDING
- ONE active Trip; unified TripItem (flight/hotel/car/train/activity/transfer) with statuses (planned/booked/cancelled/completed) + provider reference. "+ Add to Trip". Booking confirmation can add items. No live tracking yet.
### 5B — Trip timeline + itinerary — PENDING
- Home/Trip entry: upcoming trip, next item, itinerary, dates, locations, references, actions. Built on TripItem. Premium RTL/LTR. No tracking/notifications/AI actions.
### 5C — Live trip tracking — PENDING
- Provider/status sync ONLY with a real source. Refresh strategy, timestamps, stale marking, graceful failure. UI: Live / Updated X ago / Unavailable. Never invent status.

## Track G — Notifications + Trip AI

### 6A — Notifications — PENDING
- Types: booking confirmation, payment status, trip reminder, schedule/status change, cancellation, travel alert. Backend model, ownership, read/unread, preferences, deep links, Flutter center. No spam/duplicates; no sensitive payload data.
### 6B — Contextual AI travel assistant (in Trip) — PENDING
- Understand current Trip, answer itinerary, suggest ordering, explain bookings — with authorization. AI never invents booking data/prices, never executes booking/payment, sensitive actions via backend contract. Minimal relevant trip context. Explicit memory stays AI-only.
### 6C — Post-booking AI — PENDING
- Trip preparation, reminders, packing, itinerary Qs, disruption explanation, alternatives. Real provider data for commercial recommendations. No auto booking/payment.

## Track H — Home intelligence final

### 7A — Home intelligence finalization — PENDING
- Review full stack (Profile/Behavior/Derived/Geo/Trip/Provider/Recommendation/AI/Cache). Home: cache-first → instant snapshot → background refresh → live validation → quiet update. 2B stays the ranking source.
### 7B — Deals / Discovery — PENDING
- Real sections return here (Recommended, Continue browsing, Deals, Destinations, Flights, Hotels, Cars, Packages, Experiences if real source) via the approved Card Engine. NO fake deals; provider-backed or clearly-labeled discovery snapshot. Cache-first + background refresh.

## Track I — Ops, audits, release

### 8A — Admin operational hardening — PENDING (CRUD validation, authorization, audit trail, safe status changes, input sanitization; admin can never bypass provider truth)
### 8B — Provider health & observability — PENDING (health checks, timeout metrics, error classification, latency, status, correlation IDs; no sensitive logging)
### 9A — Security & reliability audit — PENDING (authz, IDOR, prompt injection, memory poisoning, webhook replay, booking/payment duplication, sensitive logging, malformed provider responses)
- **PROPOSAL P4 (needs approval):** structure the audit as an **OWASP MASVS** checklist (STORAGE/CRYPTO/AUTH/NETWORK/PLATFORM/CODE/RESILIENCE/PRIVACY categories) + regression test per finding.
### 9B — Performance & cache hardening — PENDING (no duplicate requests/AI calls, no N+1, instant Home preserved, background refresh never blocks first paint; measure before/after)
### 10A — Full E2E regression — PENDING (all journeys in spec; fix defects only)
- **PROPOSAL P3 (needs approval):** add an official `integration_test` suite (dev-dependency — needs approval) for the 16 journeys; runs on device/emulator.
### 10B — Production readiness audit — PENDING (env, secrets, migrations, indexes, CORS, rate limits, monitoring, webhooks, backups, Android/iOS release settings, RTL/LTR, accessibility, offline behavior; PASS/FAIL/BLOCKED checklist)
### 10C — Final release gate — PENDING (tsc+jest, analyze+test, git/diff review, no debug code/secrets/test endpoints; final counts + release-ready verdict)

---

# Agreed execution order (MERGED — dependencies resolved)

```
M0 → H1 → H2 → H3 → [US-2 lands (theirs) → validate+merge] → NAV
→ 2C-C1 → 2C-C2 → 2D
→ US-3 → US-4
→ 3A → 3B → 3C → 3D
→ US-5 → US-6
→ PH-7 (Explicit Memory → Home Ranking)
→ 4A → 4B → 4C → 4D → 4E
→ 5A → 5B → 5C
→ 6A → 6B → 6C
→ 7A → 7B
→ US-7 (search hardening — after all search work)
→ 8A → 8B → 9A → 9B → 10A → 10B → 10C
```

**Ordering rationale (flags for user review):**
1. NAV waits for US-2 landing (shared router; US contract requires root/branch nav intact).
2. US-3/US-4 before 3A-3D: US-3 (voice) is client-side; US-4 (AI assistant) rides the existing intent pipeline — both independent of backend aggregation.
3. US-5/US-6 AFTER 3A-3D: personalization & compare/refinement consume the unified search contracts.
4. PH-7 after US-5: US-5 explicitly defers memory→ranking to the approved phase — that IS PH-7.
5. US-7 after 7B: harden search only when all search-consuming phases are final.

# DECISIONS (ALL APPROVED by user 2026-09-07 — no longer pending)

| # | Proposal | Phase affected | Status |
|---|---|---|---|
| P1 | `speech_to_text` package for US-3 voice (community standard, Android/iOS/web, AR+EN) | US-3 | ✅ APPROVED — install when US-3 starts |
| P2 | `ResizeImage`/`cacheWidth` decode in H3 image cache (official Flutter guidance — big memory win, no package) | H1/H3 | ✅ APPROVED + IMPLEMENTED (H3) |
| P3 | Official `integration_test` dev-dependency for 10A E2E journeys | 10A | ✅ APPROVED — install when 10A starts |
| P4 | Structure 9A as OWASP MASVS category checklist | 9A | ✅ APPROVED |
| P5 | Android 14 predictive back (`PopScope.canPop`) verification in US-7 + 9B audits | US-7, 9B | ✅ APPROVED |
| P6 | The merged execution order (NAV after US-2; US-5/US-6 after 3A-3D) | All | ✅ APPROVED — order is final |

External packages are allowed with per-case confirmation (user policy 2026-09-06).

# Files changed by the Home/Platform workstream (uncommitted, 2026-09-06)

- `lib/core/repositories/contracts/home_repository.dart` — `clearHomeSnapshot` contract
- `lib/core/repositories/impl/home_repository_impl.dart` — empty feed authoritative; `clearHomeSnapshot`; `@override`
- `lib/features/home/presentation/home_controller.dart` — empty feed → preview + snapshot drop; hotels flip preview→success
- `test/features/home/home_controller_test.dart` (+3 Nuitee-only tests), `test/features/home/live_validation_test.dart`, `test/core/repositories/home_fallback_test.dart`
- **Postgres:** 10 cards + 4 fake sections DELETED (tables now 0 rows). `backend/scripts/seed-home.js` kept intact (card system reserved).
