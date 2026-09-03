# WeTravellers — EXECUTION AGENT MEMORY

## Mission
You are the implementation agent. Work only on the requested task.

## Current known state (updated 2026-09-03 — Phase 0)
- Flutter 3.44.8 / Dart 3.12.2 (verify locally).
- Architecture: feature-first + Riverpod + GoRouter + Repository→UseCase→Controller.
- Phases 1–17 + Waves W0–W3 + Admin workstream + R-4 personalization all complete IN CODE. **R-4 and Phase-0 stabilization are still UNCOMMITTED in the working tree; 4 admin commits are unpushed.** Verified baseline (2026-09-03): 437 Flutter tests / 6 skipped / 0 failed; 134 backend tests / 1 skipped; analyze 0 errors; tsc clean. Full detail: `04_PHASE_HISTORY.md` addenda 2026-09-02/03; current facts: `03_CURRENT_STATE.md`.
- **Design language is LIGHT-ONLY ("Pure White Premium")** — dark theme removed by user decision; no theme toggles. Unified motion: fade-through on every route. Buttons via the `AppButton` kit. Manrope (Latin) + Cairo (Arabic) fonts; en/ar l10n everywhere (gen-l10n).
- **Navigation**: attached bottom bar (Home / Search / **AI centre button** / Groups / Explore). AI centre pushes `/ai-chat` (root route, NOT a shell branch). Branch order Home=0, Search=1, Groups=2, Explore=3 (`shell.dart`). CommandBar/FloatingNavigation/AiMorphControl were DELETED — do not reference them.
- **Search pages** use `SearchScaffold` (scroll-linked collapsible header) + `SearchStatesView` + `SortChipsRow` + destination picker sheets. Pages read router extras in `didChangeDependencies` (NOT initState).
- **Providers (backend)**: Nuitee hotels LIVE-verified (one base URL api.liteapi.travel/v3.0, sandbox = `sand_` key; rates at `data[].roomTypes[].rates[]`), Duffel flights + `revalidateOffer`, MarketContext EG/EGP/ar-EG + FX + deterministic PricingEngine (offers carry `customerPrice`), cars rich mock. `POST /offers/revalidate` gates checkout.
- **Payments (backend)**: `modules/payments` — PaymentGateway interface, MockEgyptGateway (idempotent, signed webhooks, 3DS), PaymentRouter (EG only), LedgerService, `/payments/*`. Flutter checkout calls the real backend flow. Real PSP pending (spec §K).
- **Booking funnel**: review → passengers → add-ons → checkout → confirmation under `/booking/review/*`; review's Continue enforces revalidation (PRICE_CHANGED blocks).
- NestJS backend lives under `backend/`; AI is a SINGLE OpenAI-compatible provider (OpenRouter via AI_API_KEY/AI_BASE_URL/AI_MODEL env), 90s timeout. **The Mock provider and the fallback layer were DELETED with the R-4 workstream** — do not reference them; provider failures surface to the caller (503). `AI_FALLBACK_PROVIDER` in `backend/.env` is a dead, unread line.
- Flutter AI consumes normalized `AiResponse` and maps to existing Home cards.
- **R-4 personalization (backend, uncommitted as of 2026-09-03)**: modules `geo/` (`GET /geo/country`), `profile/` (`user_profiles` + `GET/PATCH /profile/me`), `events/` (`POST /events`, 5 types), `recommend/` (`GET /home/recommended` — Nuitee candidates + deterministic scoring + optional AI re-rank). Flutter Home consumes the recommended-hotels carousel. NOTE: Flutter does NOT yet call `/events`, `/profile/me`, or `/geo/country`, and `setCountry*` has no caller — wiring is future work (see 07/08).

## Mandatory rules
- NEVER delete files/directories.
- NEVER rename files/directories unless explicitly approved.
- NEVER use destructive commands.
- Do not add packages unless explicitly approved.
- Do not modify unrelated features.
- Preserve HomeCard/HomeSection engine.
- Preserve GoRouter/AppRoute unless task explicitly targets routing.
- Do not invent API keys or secrets.
- Do not change contracts casually.
- Keep changes minimal and phase-scoped.

## Required workflow
1. Inspect relevant files.
2. State what you found.
3. Implement only the requested phase.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. For backend changes run the appropriate TypeScript checks/tests.
7. Report:
   - created files
   - modified files
   - behavior
   - validation
   - remaining issues
8. STOP. Do not start the next phase automatically.

## AI architecture
```text
PromptInput
 → AiController
 → AiAssistantService
 → backend / AiProvider
 → AiResponse
 → AiHomeMapper
 → HomeSectionWidget
 → existing HomeCard engine
```

## Current task
Use the explicit task prompt as the only source of implementation scope.
