# WeTravellers — CURRENT STATE

## Last known checkpoint (AUTHORITATIVE — 2026-09-07)
**Home & Platform workstream M0–H3 complete; Universal Search US-2 in progress by the sibling agent; everything below was validated by direct runs.**

### Verified baseline (2026-09-07)
- `flutter test` **647 passed / ~6 skipped / 0 failed**
- `dart analyze lib test` **0 errors** (~138 infos/warnings pre-existing, mostly US-2 WIP files — reported, not fixed)
- Backend `tsc --noEmit` **clean**
- Backend `npx jest` **232 passed / 1 skipped / 0 failed**
- Postgres (`wetravellers-postgres` docker, PG16): `home_sections` 0 rows, `home_cards` 0 rows (fake seed purged 2026-09-06). **NEVER run `npm run seed:home`.**

### Workstream 1 — Home & Platform (COMPLETE for now; spec = `MASTER_PLAN.md`)
- **M0:** Nuitee-only Home — empty feed authoritative; legacy `home|sections` cache never resurrected; audience v2 snapshots dropped on empty feed (`HomeRepository.clearHomeSnapshot`); hotels arrival flips dev-preview → success.
- **H1:** pull-to-refresh REMOVED (`RefreshIndicator` + controller `refresh()`); `_SkeletonRecommendedRail`/`_SkeletonHotelCard` mirror the real rail geometry exactly (fixed title, 220px, 260px cards); `_developmentPreviewSections()` kept (no-deletion rule).
- **H2:** `HomeController.refreshPrices()` → `_runLiveValidation()` ONLY. `HomePage` = `ConsumerStatefulWidget` + `WidgetsBindingObserver` (resume) + GoRouter delegate listener (return to '/') — lazy hook via `GoRouter.maybeOf`, router ref saved for dispose. Tests: `h2_refresh_prices_test.dart`.
- **H3:** `lib/features/home/application/hotel_image_cache.dart` — LRU(30)/TTL(7d) byte cache on the shared OfflineCache box (`hotel_image|<url>` keys); `lib/features/home/presentation/widgets/cached_hotel_image.dart` — shimmer → shared per-URL fetch → store → decode with P2 `cacheWidth` (ResizeImage at display res); wired into `_HotelCard` + `hotelImageCacheProvider`. Tests: `h3_hotel_image_cache_test.dart` (11). **Test-env lesson: never `pumpAndSettle` under a live shimmer — fixed pump loops.**
- **NOT committed yet** (see Git below).

### Workstream 2 — Universal Search (sibling agent; spec = `UNIVERSAL SEARCH MASTER.txt`)
- US-0 ✅ (contract `docs/universal-search-ux-contract.md`), US-1 ✅ + US-1-Final ✅ (commit 794ebcb9, legacy v1 deleted — the single approved deletion).
- **US-2 ⏳ in progress uncommitted** (parser `_isNumericFragment`/budget/months; `StructuredTravelIntent` rooms/budget/minStars/amenities; gap chips `fillGap`; ~60 tests). Files owned by them: `lib/features/universal_search/**`, `lib/features/ai/{data,application,search_intent_parser,ai_chat_page,ai_visual_shell_page}`, `backend/src/modules/{ai,events,profile-edges}`, AI DTOs, `test/features/universal_search/**` + their AI test edits.
- **NAV (remove bottom nav → Home-centric buttons) is blocked until US-2 lands** (shared router).

### Memory Spine (backend, from 2C phases)
- `modules/memory/` + `user_memory.entity.ts` + `memory.dto.ts`: JWT-owned CRUD `/memory/me` (+ POST/PATCH/DELETE/clear). `POST /ai/chat` (`ai.conversation.controller.ts`): the ONLY surface where explicit memories reach the AI; selector/extraction failures swallowed; personalization-disabled → plain behavior. `POST /ai/rerank` + Flutter `ai_rerank_client.dart` (id-validated, optional).
- Flutter 2A: `lib/core/memory/` MemoryRepository + tests green. **2C-C1 (Flutter /ai/chat wiring) NOT started — next after NAV.**

### Repo-root documents (read order)
1. `MASTER_PLAN.md` — merged plan M0→10C + boundaries + PENDING DECISIONS (P1/P3-P6 open; P2 approved).
2. `محرك التوصيات.txt` — memory/AI/search/booking/trip track specs.
3. `UNIVERSAL SEARCH MASTER.txt` — search track specs (US-0→US-7).
4. `AGENTS.md` — project rules. 5. `PROJECT_MEMORY/` — this system.

### Git (at this checkpoint)
- 7 local commits ahead of origin/main (latest: 794ebcb9 universal-search legacy removal) + ALL M0–H3 work UNCOMMITTED in the tree alongside the sibling agent's US-2 WIP.
- Commit/push only on explicit user instruction; commits must be scoped per workstream.

### Standing warnings
- `backend/test-nuitee.ts` — never modify/delete/commit. `.env` never read/printed/committed.
- Do NOT run `npm run seed:home`.
- Security gap: `/api/duffel/create-booking` unguarded + `any[]` DTO — gate before any non-localhost exposure.

---

# Historical checkpoints (superseded — kept for reference)

## 2026-09-06 — project memory system refreshed
`PROJECT_MEMORY/` rewritten to the two-workstream state (see `04_PHASE_HISTORY.md` addendum 2026-09-06). Verified baseline then: 633/232.

## 2026-09-03 — Phase 0 stabilization (R-4 verified, AI single-provider)
Geo/Profile/Events/Recommend modules; AI mock/fallback deleted; Nuitee fixtures coverage lost (known debt). Baseline 437/134. Full detail: `04_PHASE_HISTORY.md`.

## 2026-09-02 — Admin workstream (4 unpushed commits: f95cecf2, b41ae2f4, 7344acd2, bf3335d1)
`/admin/home/*` CRUD + audit + publication windows; DB provider registry runtime switching; Flutter `/admin` panel. Full detail: `04_PHASE_HISTORY.md`.

## 2026-09-02 — Waves W0–W3
Light-only UI rebuild, real providers (Nuitee LIVE, Duffel revalidate, MarketContext EG/EGP), search/home rebuild, booking funnel + MockEgyptGateway payments.

## Earlier (2026-08-26 and before)
AI chat overhaul; card system Stage 2; Phases 1–17. See `04_PHASE_HISTORY.md`.
---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
794ebcb9 (HEAD -> main) chore(universal-search): remove legacy v1 search page
b4317d8d chore(phase0): stabilize single-provider tests and document r4
dd0b11e5 feat(personalization): geo profile events recommend modules and ai single-provider
f95cecf2 fix(admin): seed-admin camelCase columns + role in /auth/me
b41ae2f4 fix(providers): restore NuiteeService export dropped in ADM-B1 rewrite
7344acd2 feat(admin): admin panel - home content management + runtime provider switching
bf3335d1 feat(app): full UI rebuild, real travel providers, and booking/payment foundation (Waves 0-3)
66a80f94 (origin/main, origin/HEAD) feat(project): add automatic git sync and update state documentation
b7f3f985 feat(cards): shared card design system (Stage 2) + redesign, audit, and memory sync
bf6cc0ea feat(ai): full-screen AI chat page with conversation history and auto-expiry
```

### Pending status
```
 M PROJECT_MEMORY/01_MASTER_MEMORY.md
 M PROJECT_MEMORY/02_AGENT_MEMORY.md
 M PROJECT_MEMORY/03_CURRENT_STATE.md
 M PROJECT_MEMORY/04_PHASE_HISTORY.md
 M PROJECT_MEMORY/08_NEXT_STEPS.md
 M PROJECT_MEMORY/README.md
 M backend/src/app.module.ts
 M backend/src/common/dto/ai.dto.ts
 M backend/src/modules/ai/ai.controller.ts
 M backend/src/modules/ai/ai.module.ts
 M backend/src/modules/ai/ai.provider.ts
 M backend/src/modules/ai/ai.service.ts
 M backend/src/modules/ai/openai.ai.provider.ts
 M backend/src/modules/events/events.module.ts
 M backend/src/modules/events/events.service.ts
 M backend/src/modules/profile/profile.controller.ts
 M backend/src/modules/profile/profile.module.ts
 M lib/app/config/app_config.dart
M  lib/core/repositories/contracts/home_repository.dart
M  lib/core/repositories/impl/home_repository_impl.dart
 M lib/core/storage/hive_offline_cache.dart
 M lib/core/storage/offline_cache.dart
 M lib/features/ai/application/ai_providers.dart
 M lib/features/ai/data/ai_api_service.dart
 M lib/features/ai/domain/search_intent_parser.dart
 M lib/features/ai/presentation/pages/ai_chat_page.dart
 M lib/features/ai/presentation/pages/ai_visual_shell_page.dart
 M lib/features/bag/presentation/pages/trip_details_page.dart
 M lib/features/booking/presentation/pages/booking_confirmation_page.dart
A  lib/features/home/application/home_live_validation_service.dart
A  lib/features/home/application/home_personalization_orchestrator.dart
A  lib/features/home/application/hotel_image_cache.dart
A  lib/features/home/application/local_behavior_store.dart
A  lib/features/home/application/recommendation_service.dart
A  lib/features/home/domain/home_composer.dart
A  lib/features/home/domain/home_greeting.dart
A  lib/features/home/domain/personalization_context.dart
M  lib/features/home/presentation/home_controller.dart
M  lib/features/home/presentation/pages/home_page.dart
A  lib/features/home/presentation/widgets/cached_hotel_image.dart
M  lib/features/home/providers/home_providers.dart
 M lib/features/search/application/controllers/hotel_search_controller.dart
 M lib/features/search/application/providers/hotel_car_providers.dart
 M lib/features/search/presentation/pages/hotel_search_page.dart
 M lib/features/search/presentation/pages/offer_details_page.dart
 M lib/features/universal_search/application/universal_search_controller.dart
 M lib/features/universal_search/application/universal_search_state.dart
 M lib/features/universal_search/domain/structured_travel_intent.dart
 M lib/features/universal_search/presentation/pages/universal_search_page.dart
 M lib/features/universal_search/presentation/widgets/universal_search_widgets.dart
 M lib/shared/widgets/placeholder_page.dart
 M test/core/repositories/home_fallback_test.dart
 M test/features/ai/presentation/pages/ai_chat_page_test.dart
A  test/features/home/derived_preferences_test.dart
A  test/features/home/h2_refresh_prices_test.dart
A  test/features/home/h3_hotel_image_cache_test.dart
A  test/features/home/home_composer_test.dart
M  test/features/home/home_controller_test.dart
A  test/features/home/live_validation_test.dart
A  test/features/home/personalization_spine_test.dart
A  test/features/home/presentation/pages/home_skeleton_rail_test.dart
 M test/features/universal_search/universal_search_controller_test.dart
 M test/features/universal_search/universal_search_page_test.dart
?? AGENTS.md
?? MASTER_PLAN.md
?? "UNIVERSAL SEARCH MASTER.txt"
?? backend/src/common/dto/ai.rerank.dto.ts
?? backend/src/common/dto/memory.dto.ts
?? backend/src/database/entities/user_memory.entity.ts
?? backend/src/modules/ai/ai.conversation.controller.ts
?? backend/src/modules/ai/ai.conversation.module.ts
?? backend/src/modules/ai/ai.rerank.controller.ts
?? backend/src/modules/memory/
?? backend/test-nuitee.ts
?? backend/test/ai.chat.memory-context.spec.ts
?? backend/test/ai.rerank.spec.ts
?? backend/test/ai.suggest.spec.ts
?? backend/test/behavioral_memory.spec.ts
?? backend/test/conversation_memory.spec.ts
?? backend/test/memory.spec.ts
?? lib/core/ai/ai_rerank_client.dart
?? lib/core/events/
?? lib/core/geo/
?? lib/core/memory/
?? lib/core/profile/
?? test/core/memory/
?? test/features/ai/domain/
?? test/features/universal_search/structured_travel_intent_us2_test.dart
?? "\331\205\330\255\330\261\331\203 \330\247\331\204\330\252\331\210\330\265\331\212\330\247\330\252.txt"
```
