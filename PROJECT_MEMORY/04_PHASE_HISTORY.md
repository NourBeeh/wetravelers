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
| 15B | Complete | Context-aware AI + Card Engine integration + Home feed context extraction |
| 15C | Complete | Code hygiene & test stabilization: bottom sheet cancellation fix, 0 analyze errors (16 non-blocking), 203 passing tests |
| 16 | Complete | Offline support foundation: Hive-backed OfflineCache wired in main(); write-through cache for flight/hotel/car search results + AI responses (SHA-256 prompt-hash keys); cache-first read with graceful fallback on network failure; `crypto` package added; 23 new tests, 226 total passing |
| 17 | Complete | Auth: backend register/login/me (bcryptjs, JwtStrategy+Guard, validated DTOs) + Flutter secure-storage session, `/auth` page, profile split, logout; plus Home empty-state fix (demo+cache fallback), `npm run seed:home` dev seed, CommandBar layout fix |
| 18 | Pending | PROJECT_MEMORY cloud sync (auto-backup of memory files to external storage) + analytics foundation (AI query tracking) — **NEXT** |
| 19 | Pending | End-to-end booking/payment and Bag synchronization |
| 20 | Pending | Unified Trip Bag, imports, readiness, Wallet, Price Watch |
| 21 | Pending | Accessibility improvements (screen reader support, text scaling compliance) |
| 22 | Pending | Live Travel Companion, Map, Travel Mode, event notifications |
| 23 | Pending | Production readiness and launch (performance optimization, security hardening) |
| 24 | Pending | Trusted Group Trips: members, shared plans, safety, reviews |

### Phase discipline
Each phase is intentionally small. Never start the next phase without an explicit instruction.

### Notes (addendum 2026-08-19)
- Phase 10 was executed as sub-phases 10A–10D and is complete (commit `eda9668e`).
- Phases 11A, 11B1, 11B2 and 11C completed; 11B2's remaining TypeScript errors resolved (backend `tsc` build clean).
- Phase 12 (Home Marketplace) and Phase 13 (Floating/Orbital Navigation + persistent CommandBar) completed and committed.
- Phase 14B completed as 14A (AI Bottom Sheet UI prototype, commit `f2170a7c`) + 14B (CommandBar Ask/TextField wiring, backend AI timeout 90s, timeout classified as retryable so Mock fallback engages, Flutter sheet timeout aligned to 90s). Live AI verified via OpenRouter (`openrouter/free`).
- Phase 15 (15A–15C) completed: context-aware AI + code hygiene baseline.
- Phase 16 completed 2026-08-21: Hive offline cache for offers + AI responses.
- Phase 17 completed 2026-08-21: real auth end-to-end (backend + Flutter), Home empty-state fix (demo+cache fallback, `npm run seed:home` dev seed), CommandBar layout constraints. Next = Phase 18, pending explicit instruction.

### Notes (addendum 2026-08-26) — post-Phase-17 AI chat overhaul (unnumbered iteration)
Executed across multiple sessions on top of Phase 17; no numbered phase was opened.
- AI launcher retired the floating morph window entirely (scrim/swipe-to-close era removed). `lib/app/widgets/ai_morph_control.dart` is now a bubble-only launcher that pushes `/ai-chat`.
- NEW full-screen chat page: `lib/features/ai/presentation/pages/ai_chat_page.dart`, top-level GoRoute outside ShellRoute with standard platform transitions (iOS edge-swipe-back preserved).
- Conversation model: `AiChatMessage` (user/assistant, fromCache) + `AiState.messages`; controller appends user msg instantly and assistant replies on success/error/empty; rolling cap 50 messages; 6h idle TTL with injectable clock (`expireIfIdle`). In-memory persistence semantics: backgrounding keeps the chat, app restart clears it.
- Chat UX: WhatsApp-style expanding input (1→4 lines), circular gradient send button, typing dots, per-bubble entrance animations, ⚡ cached badge, friendly error bubbles + retry, haptics on open/close/submit.
- Closing paths: header ✕ (right side), Android Back, iOS swipe-back, Escape (web/desktop).
- Fixed Hive disk-round-trip crash: `HiveOfflineCache` box retyped to `Box<Map>` with deep `convertHiveValue`; cache reads made best-effort in `AiController.submit` and `ai_bottom_sheet`. This also protected flight/hotel/car search caches.
- Tests: Flutter suite grew 242 → 262 passing (chat model/controller/page/bubble suites); analyze 0 errors. New test files: `test/features/ai/ai_chat_messages_test.dart`, `test/features/ai/presentation/pages/ai_chat_page_test.dart`, `test/core/storage/hive_offline_cache_test.dart`.
- Known issue logged: pre-existing `hotel_card.dart:34` Column overflow with demo data at small test viewports (unrelated to AI work).
- Next = Phase 18, still pending explicit instruction.

### Notes (addendum 2026-08-26 #2) — Card system redesign + audit (unnumbered iteration)
- All Home + Search cards brought to one luxury standard matching the search pages' visual language: gradient-scrim-over-image on Hotel/Package/Car, corner badge/rating pills, compact 200px pill FlightCard for horizontal containers, NEW generic `SectionContainerCard` (title + View All + horizontal child cards), search-result cards gained `CardImage` (`BaseOffer.imageUrl` already existed — no model change), `CardImage` gained `fallbackIcon` degraded-image support wired across all image cards, `CardPrice` gained a scrim-legible `color` override. FlightCard semantics hardened with `ExcludeSemantics`.
- Full audit written to `docs/card-system-audit.md` (inventory, issues, duplication, reuse map, gaps vs professional system).
- **Approved follow-up sub-phases (slot alongside/before Phase 18 per user sequencing):**
  - **24A Consolidation:** hotel search page adopts shared HotelResultCard; extract shared RatingPill/scrim primitives; remove triplicates.
  - **24B Interaction contract:** onTap/actionLabel plumbing through HomeCard → detail stubs; wire View All.
  - **24C Favorites:** FavoritesService + heart toggle (Hotel/Package) with local persistence.
  - **24D Polish:** intl price formatting, shared skeleton family, responsive breakpoints, RTL audit.
  - **24E QA:** golden tests per card + accessibility re-audit.
- Note: the original roadmap's "Phase 24 = Trusted Group Trips" is unchanged; the card work above is an unnumbered iteration to avoid renumbering.

### Notes (addendum 2026-08-26 #3) — Card system Stage 2: shared design system (committed)
Stage 1 (redesign + audit) is recorded in addendum #2. Stage 2 built ONLY the shared Card Design System — no feature card (HotelCard/FlightCard) was rebuilt and no universal card was created. Everything below is committed.
- **New `lib/core/widgets/cards/card_glass.dart` (`CardGlass`):** one reusable frosted-glass recipe (BackdropFilter + brightness-aware tint + hairline border) used by every on-image overlay — centralises glassmorphism "only where the current design fits it".
- **Shared `formatCardPrice()`** in `card_price.dart`; `CardPrice` and `CardPriceBlock` both call it (removes duplicated price-formatting logic, incl. the raw `$` formatting in the hotel page's private `_HotelCard`).
- **Theme/light-dark + responsive hardening across primitives:** `CardBadge` (new `CardBadgeVariant { tinted, glass }` + optional icon), `CardRating` (new `onImage` glass pill — the single impl the 3× rating-pill triplicate should adopt), `CardFeatureList` (`primaryContainer`/`onPrimaryContainer`, `onImage`), `CardFavorite` (theme-aware surface/foreground, `onImage` glass heart, added unused-import removal), `CardCancellation` (brightness-adjusted success), `CardImage` fallback (`surfaceContainerHighest`/`onSurfaceVariant`), `BaseCard` shadow brightness-aware + gained `semanticsLabel` with `button`/`enabled` semantics (pressed/disabled/loading intact).
- **No new packages, no API changes, no business-logic change, no deleted files.** Only `lib/core/widgets/cards/*` + `test/core/widgets/cards/*` were touched in Stage 2.
- **Tests:** `test/core/widgets/cards/card_system_test.dart` expanded (CardGlass, formatCardPrice, onImage variants, disabled opacity). Full suite: **293 Flutter tests pass / 6 skipped; `flutter analyze` 0 errors**.
- **Next (unchanged order):** card sub-phases **24A → 24E** (consolidate the hotel search `_HotelCard` onto `HotelResultCard`, interaction contract, favorites, polish, QA) — then Phase 18 still awaits an explicit instruction.