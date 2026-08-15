# WeTravellers — ACTIVE CONTEXT
Updated: 2026-08-15

## Current position
- Project: WeTravellers
- Flutter: 3.44.8
- Dart: 3.12.2
- Architecture: feature-first + Riverpod + GoRouter + Repository → UseCase → Controller
- Reported baseline: 55 Flutter tests pass; `flutter analyze` = 0 errors (warnings/info only).
- Current AI track: Phase 9 COMPLETE.
- Next: Phase 10 NOT STARTED.
- Booking execution/payment: explicitly NOT STARTED.

## AI pipeline
UI → AiController → AiAssistantService → configured backend provider → AiResponse → AiHomeMapper → HomeSectionWidget/HomeCard.

Phase 9 uses an OpenAI-compatible REST provider in NestJS.
Runtime env:
- AI_API_KEY: required
- AI_BASE_URL: optional, default `https://api.openai.com/v1`
- AI_MODEL: optional, default `gpt-4o-mini`

## Hard constraints
- Do NOT delete files/directories.
- Do NOT rename files unless explicitly approved.
- Do NOT use destructive commands.
- No new package unless explicitly approved.
- Preserve HomeCard/HomeSection engine.
- Preserve GoRouter/AppRoute/AppMode unless the current phase explicitly requires change.
- Validate with `flutter analyze` and `flutter test` for Flutter changes.
- For backend changes, use the project's TypeScript compile/check command when available.
- Work in small phases.
- Do not start the next phase without an explicit phase instruction.

## Immediate next action
Design/execute Phase 10 only after its exact scope is provided and the current project state is verified.
