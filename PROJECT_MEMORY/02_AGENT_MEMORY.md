# WeTravellers — EXECUTION AGENT MEMORY

## Mission
You are the implementation agent. Work only on the requested task.

## Current known state
- Flutter 3.44.8 / Dart 3.12.2 (verify locally).
- Architecture: feature-first + Riverpod + GoRouter + Repository→UseCase→Controller.
- Phases 1–17 are complete (17 = real auth end-to-end + Home demo/cache fallback + `npm run seed:home`). Post-17 unnumbered iterations also landed and were committed: a full-screen AI chat overhaul and the **Card System Stage 1 (redesign + audit → `docs/card-system-audit.md`) & Stage 2 (shared Card Design System)**. **Phase 18 — PROJECT_MEMORY cloud sync + analytics foundation** is the next numbered phase; do not start it or any later phase without an explicit task prompt. The approved **card sub-phases 24A–24E** run before it (24A consolidate hotel search `_HotelCard` onto `HotelResultCard`; 24B tap/action contract; 24C favorites; 24D polish; 24E QA).
- **Card System Stage 2 (committed):** the shared card primitives in `lib/core/widgets/cards/` are theme-aware (light/dark), responsive and ready — `CardGlass` (glassmorphism recipe), shared `formatCardPrice()`, `onImage` glass variants + icons on `CardBadge`/`CardRating`/`CardFeatureList`/`CardFavorite`, `BaseCard` semantics, dark-mode contrast fixes; NO universal card and NO feature-card rebuild yet (next stages use these primitives). Suite: analyze 0 errors, 293 Flutter tests pass / 6 skipped.
- NestJS backend lives under `backend/`.
- Current AI backend provider is OpenAI-compatible REST, bound through `AI_PROVIDER`.
- Backend AI request timeout is 90s and timeout failures are classified as retryable so the Mock fallback engages. Flutter AI sheet timeout is aligned to 90s.
- CommandBar (Ask button + TextField) is wired to `showAiBottomSheet` via `onSubmitted`; search heuristics preserved in `shell.dart`.
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
