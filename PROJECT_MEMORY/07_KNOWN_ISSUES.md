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

## Rule
Do not fix unrelated historical issues during a scoped phase unless the requested phase explicitly requires them.
