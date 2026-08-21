# WeTravellers — DEEPSEEK EXECUTION CONTEXT

## Project
WeTravellers — Flutter travel application + NestJS backend.

## Current checkpoint
Phases 1–17 are complete (17 = real auth end-to-end, Home demo/cache fallback + dev seed). Next = **Phase 18 — PROJECT_MEMORY cloud sync + analytics foundation** — only when explicitly requested.

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
Phases 1–17 are complete. Implement only **Phase 18 — PROJECT_MEMORY cloud sync + analytics foundation** when explicitly requested, then stop. Later phases 19+ remain listed but not started; see `08_NEXT_STEPS.md`. Keep the hard rules: no delete/rename, no secrets in code or memory, minimal scoped work.
