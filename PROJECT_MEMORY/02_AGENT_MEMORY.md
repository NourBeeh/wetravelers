# WeTravellers — EXECUTION AGENT MEMORY

## Mission
You are the implementation agent. Work only on the requested task.

## Current known state (updated 2026-09-02)
- Flutter 3.44.8 / Dart 3.12.2 (verify locally).
- Architecture: feature-first + Riverpod + GoRouter + Repository→UseCase→Controller.
- Phases 1–17 complete. On top of them, the three Wave workstreams are complete (W0 UI/nav rebuild, W1 real providers, W2 search/home rebuild, W3 booking+payment). Full detail: `01_MASTER_MEMORY.md` §12.5; cross-references: `04_PHASE_HISTORY.md` addendum 2026-09-02. Baseline: 432 Flutter tests / 129 backend tests green, analyze 0 errors.
- **Design language is LIGHT-ONLY ("Pure White Premium")** — dark theme removed by user decision; no theme toggles. Unified motion: fade-through on every route. Buttons via the `AppButton` kit. Manrope (Latin) + Cairo (Arabic) fonts; en/ar l10n everywhere (gen-l10n).
- **Navigation**: attached bottom bar (Home / Search / **AI centre button** / Groups / Explore). AI centre pushes `/ai-chat` (root route, NOT a shell branch). Branch order Home=0, Search=1, Groups=2, Explore=3 (`shell.dart`). CommandBar/FloatingNavigation/AiMorphControl were DELETED — do not reference them.
- **Search pages** use `SearchScaffold` (scroll-linked collapsible header) + `SearchStatesView` + `SortChipsRow` + destination picker sheets. Pages read router extras in `didChangeDependencies` (NOT initState).
- **Providers (backend)**: Nuitee hotels LIVE-verified (one base URL api.liteapi.travel/v3.0, sandbox = `sand_` key; rates at `data[].roomTypes[].rates[]`), Duffel flights + `revalidateOffer`, MarketContext EG/EGP/ar-EG + FX + deterministic PricingEngine (offers carry `customerPrice`), cars rich mock. `POST /offers/revalidate` gates checkout.
- **Payments (backend)**: `modules/payments` — PaymentGateway interface, MockEgyptGateway (idempotent, signed webhooks, 3DS), PaymentRouter (EG only), LedgerService, `/payments/*`. Flutter checkout calls the real backend flow. Real PSP pending (spec §K).
- **Booking funnel**: review → passengers → add-ons → checkout → confirmation under `/booking/review/*`; review's Continue enforces revalidation (PRICE_CHANGED blocks).
- NestJS backend lives under `backend/`; current AI provider OpenAI-compatible REST; 90s timeout with Mock fallback.
- Flutter AI consumes normalized `AiResponse` and maps to existing Home cards.

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
