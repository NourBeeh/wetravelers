# WeTravellers — PHASE HISTORY

| Phase | Status | Main result |
|---|---|---|
| 1 | Complete | Four real GoRouter routes wired |
| 2 | Complete | AI/Normal AppMode state |
| 3 | Complete | AI visual shell |
| 4 | Complete | AI response contract + mapper |
| 5 | Complete | Mock response rendered by existing Home cards |
| 6 | Complete | AI controller + state |
| 7 | Complete | AI service abstraction |
| 8 | Complete | NestJS AI endpoint + mock provider |
| 9 | Complete | OpenAI-compatible real provider |
| 10 | Complete (10A–10D) | Response hardening, live integration, provider config/fallback, AI contract tests |
| 11A | Complete | Local database/cache foundation |
| 11B1 | Complete | Home schema mapped and contract-tested end to end |
| 11B2 | Complete | Remaining verified TypeScript errors resolved (backend tsc build clean) |
| 11C | Complete | Search error sanitization |
| 12 | Complete | Home Marketplace UI |
| 13 | Complete | Floating Navigation + persistent CommandBar |
| 14 | Complete (14A UI + 14B wiring/timeouts) | AI Bottom Sheet + CommandBar wiring + 90s timeout hardening; Mock fallback now engages on timeout |
| 15A | Complete | Context-aware AI foundation: AiQueryContext model, service contract extended with optional context, context wired from shell/AI sheet path, backend supports context injection into prompts |
| 15B | Next (pending approval) | Context-aware AI + Card Engine integration deep polish |
| 16 | Pending | Authentication, profile, and persisted sessions |
| 17 | Pending | End-to-end booking/payment and Bag synchronization |
| 18 | Pending | Unified Trip Bag, imports, readiness, Wallet, Price Watch |
| 19 | Pending | Live Travel Companion, Map, Travel Mode, event notifications |
| 20 | Pending | Production readiness and launch |
| 21 | Pending | Trusted Group Trips: members, shared plans, safety, reviews |

### Phase discipline
Each phase is intentionally small. Never start the next phase without an explicit instruction.

### Notes (addendum 2026-08-19)
- Phase 10 was executed as sub-phases 10A–10D and is complete (commit `eda9668e`).
- Phases 11A, 11B1, 11B2 and 11C completed; 11B2's remaining TypeScript errors resolved (backend `tsc` build clean).
- Phase 12 (Home Marketplace) and Phase 13 (Floating/Orbital Navigation + persistent CommandBar) completed and committed.
- Phase 14 completed as 14A (AI Bottom Sheet UI prototype, commit `f2170a7c`) + 14B (CommandBar Ask/TextField wiring, backend AI timeout 90s, timeout classified as retryable so Mock fallback engages, Flutter sheet timeout aligned to 90s). Live AI verified via OpenRouter (`openrouter/free`).
- Phase 15 is next and remains pending until explicitly started.