# ARCHITECTURE & DECISIONS

## AI
- AI-specific incoming contract lives under `features/ai/domain`.
- `AiHomeMapper` is the single boundary converting AI data into existing Home models.
- Existing `HomeCard` / `HomeSectionWidget` engine must remain reusable and untouched unless a future phase explicitly requires otherwise.
- `AiController` depends on abstractions, not mock implementation details.
- Backend AI provider is selected through DI token `AI_PROVIDER`.
- Phase 9 uses an OpenAI-compatible REST provider without adding an SDK.
- Provider identity is not exposed in the Flutter response metadata.

## Navigation
- GoRouter + ShellRoute + AppRoute remain the routing architecture.
- Normal mode keeps FloatingNavigation.
- AI mode displays the AI visual shell.

## Engineering rules
- Prefer additive, reversible changes.
- Avoid speculative refactors.
- Preserve existing behavior outside the active phase.
- No destructive deletion commands.
