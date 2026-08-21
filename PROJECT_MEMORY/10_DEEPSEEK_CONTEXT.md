# WeTravellers — DEEPSEEK EXECUTION CONTEXT

## Project
WeTravellers — Flutter travel application + NestJS backend.

## Current checkpoint
AI Phases 1–10, 11A, 11B1, 11B2, 11C, 12, 13, 14A, 14B, 15A–15C and 16 (offline Hive cache) are complete. Live AI works via the OpenAI-compatible provider (tested with OpenRouter). Next = **Phase 17 — Auth (login/profile/persisted sessions)** — only when explicitly requested.

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
Phases 1–16 are complete. Implement only **Phase 17 — Auth (login/profile/persisted sessions)** when explicitly requested, then stop. Later phases 18+ remain listed but not started; see `08_NEXT_STEPS.md`. Keep the hard rules: no delete/rename, no secrets in code or memory, minimal scoped work.
