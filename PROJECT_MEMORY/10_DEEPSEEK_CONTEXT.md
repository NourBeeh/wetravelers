# WeTravellers — DEEPSEEK EXECUTION CONTEXT

## Project
WeTravellers — Flutter travel application + NestJS backend.

## Current checkpoint
AI Phases 1–9 complete; Phase 10 sub-phases 10A–10D complete. Future product/UX vision is in the roadmap (08_NEXT_STEPS.md).

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

## Current next-step candidates
Phase 10 is not yet selected. Wait for the explicit execution prompt.
