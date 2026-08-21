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

## Rule
Do not fix unrelated historical issues during a scoped phase unless the requested phase explicitly requires them.