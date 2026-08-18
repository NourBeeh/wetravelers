# WeTravellers — EXECUTION AGENT MEMORY

## Mission
You are the implementation agent. Work only on the requested task.

## Current known state
- Flutter 3.44.8 / Dart 3.12.2 (verify locally).
- Architecture: feature-first + Riverpod + GoRouter + Repository→UseCase→Controller.
- AI Phases 1–10 are complete; Phase 11 is active.
- 11B1 Home schema mismatch is complete and contract-tested. **11B2 — remaining verified TypeScript errors** is next; do not start it, 11C, or Phases 12–15 without an explicit task prompt.
- NestJS backend lives under `backend/`.
- Current AI backend provider is OpenAI-compatible REST, bound through `AI_PROVIDER`.
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
