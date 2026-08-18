# WeTravellers — DEEPSEEK EXECUTION CONTEXT

## Project
WeTravellers — Flutter travel application + NestJS backend.

## Current checkpoint
AI Phases 1–10 and 11B1 are complete. Phase 11 remains active; **11B2 — remaining verified TypeScript errors** is next pending explicit approval.

## Stack
- Flutter / Dart
- Riverpod
- GoRouter
- NestJS backend
- TypeScript
- Repository → UseCase → Controller pattern

## AI pipeline
Flutter:
`AiPromptInput → AiController → AiAssistantService → backend → AiResponse → AiHomeMapper → HomeSectionWidget/HomeCard`

Backend:
`POST /ai/query → AiController → AiService → AI_PROVIDER → OpenAiAiProvider`

## Hard rules
- NO deleting files/directories.
- NO renaming files/directories unless explicitly instructed.
- NO destructive commands.
- NO new packages unless explicitly instructed.
- NO unrelated refactors.
- Preserve HomeCard/HomeSection engine.
- Preserve routing architecture.
- Never create or commit secrets/API keys.
- Work only on the requested phase.

## Validation
Flutter:
`flutter analyze`
`flutter test`

Backend:
run the repository's appropriate TypeScript validation.

## Reporting
At the end report:
- files created
- files modified
- exact behavior
- tests/analyze
- remaining warnings/errors
- stop at the requested phase

## Current execution boundary
11B1 is complete. Implement only **11B2 — remaining verified TypeScript errors** when explicitly requested, then stop. The remaining order is 11C → 12 → 13 → 14 → 15; see `08_NEXT_STEPS.md`.
