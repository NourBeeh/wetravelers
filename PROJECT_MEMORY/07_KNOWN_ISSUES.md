# WeTravellers — KNOWN ISSUES / CAVEATS

## Historical
- TS2564 strict-property-initialization errors existed in older DTO/entity files outside the AI scope.
- Backend database boot/connectivity has been a separate concern.
- Live AI request was not validated without a real API key.
- Historical Flutter baseline was 55 passing tests and 0 analyze errors; revalidate.

## AI
- LLM output must be treated as untrusted input.
- JSON parsing/normalization should be hardened before production.
- Provider switching is currently a module binding decision.
- `AiResponseSource` may remain as a legacy/internal mock abstraction.

## Security — Pre-production gate (added 2026-08-21)
- `POST /api/duffel/create-booking` has NO auth guard (`@UseGuards`) and NO DTO
  validation (body typed as `any[]` for passengers/payments). It calls
  `duffelClient.orders.create({ type: 'instant', ... })` — a real, immediate
  booking against the configured Duffel token, not a draft/preview.
- Currently safe only because the backend runs on localhost with no external
  exposure. This becomes a live exploit path (unauthenticated real bookings)
  the moment the backend is reachable from outside the dev machine.
- Verify `DUFFEL_ACCESS_TOKEN` in `.env` is a sandbox/test token
  (`duffel_test_...`), not a live token, while this gap remains open.
- MUST be resolved (auth guard + typed DTO with class-validator) before any
  non-localhost deployment. Tracked against Phase 16 (auth) / Phase 17
  (booking hardening) — do not deploy `create-booking` publicly before then.

## UI — Pre-existing (added 2026-08-26)
- `hotel_card.dart:34` Column overflows by 76px with the demo home feed at
  small test viewports (800×600). Surfaced while testing the AI chat route;
  unrelated to AI work. Fix candidate: make the card's Column scroll-safe or
  cap its content. Not blocking on physical devices so far.

## Rule
Do not fix unrelated historical issues during a scoped phase unless the requested phase explicitly requires them.
## Wave workstreams (2026-09-02) — current state and open items

### Verified working
- Nuitee sandbox LIVE smoke passes with the user's key in `backend/.env` (`NUITEE_LIVE_SMOKE=1 npx jest --testPathPattern=nuitee.live-smoke`).
- Full app boots and walks all tabs without exceptions (`test/app/full_app_smoke_test.dart`); all 4 search pages interaction-tested; 432 Flutter + 129 backend tests green; debug APK builds.

### Open items (none blocking, all deliberate)
- **Nuitee key is in `.env` only** (git-ignored — verified). Never copy it into committed files.
- **Duffel flights**: `revalidateOffer` + provenance shipped; the funnel does NOT yet call Duffel `createOrder` end-to-end (book wiring is Phase 19 remaining).
- **Nuitee book** (`/rates/book`) adapter method exists and is contract-tested, but the Flutter funnel does not yet pass prebookId/transactionId into a real hotel booking (Phase 19 remaining).
- **Payments**: MockEgyptGateway only. Real Egyptian PSP selection/onboarding pending (spec §K). `PAYMENT_GATEWAY_EG_REF` documented in `.env.example` but unset.
- **Booking persistence**: payments ledger + gateway state are in-memory service state; the spec §49 DB tables (bookings, payments, ledger_entries, fx_rates, webhook_events…) are NOT migrated yet.
- **Favorites**: heart toggles are presentational; no persistence service yet (leftover from card sub-phase 24C).
- **Home feed**: backend-driven via `GET /home/sections` + seed; when backend is down/empty the dev-preview fallback renders skeleton items (by design — no fake data).
- **Cars**: mock catalogue only (spec point 30 defers vendor selection).
- **`/ai` route**: still a placeholder; the real assistant is `/ai-chat`. The AI-mode visual shell page exists unrouted.
- **Known historical security gate (pre-production)**: `POST /api/duffel/create-booking` still has no auth guard/DTO validation — must be gated before production (unchanged from the 2026-08-21 note above).
