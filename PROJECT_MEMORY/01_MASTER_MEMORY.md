# WeTravellers — MASTER PROJECT MEMORY

> **Purpose:** The authoritative handoff document for any analytical/architectural AI that must understand the project without access to previous chats.
>
> **Last known project state:** Phase 9 complete. Phase 10 not started.
>
> **Important:** This document is compiled from the project history available to the current assistant. It is not a live filesystem scan. Any item marked "verify" should be checked against the repository before making changes.

---

## 1. Project Identity

- Project name: **WeTravellers**
- Current product direction/branding: travel application evolving toward **B&GO / BEALDANDGO / B-ANDGO** design language.
- Primary stack: **Flutter + Dart**, with a **NestJS backend**.
- Flutter architecture: feature-first + Riverpod + GoRouter + Repository → UseCase → Controller.
- Flutter environment last reported: **Flutter 3.44.8 / Dart 3.12.2**.
- Linux desktop was enabled and successfully running.
- Backend location: `backend/`.
- Flutter source: `lib/`.
- Tests: `test/`.

## 2. Non-Negotiable Project Rules

1. **Never delete files or directories.**
2. **Never rename files/directories unless explicitly approved.**
3. Never use destructive commands (`rm -rf`, destructive reset/clean, etc.) for project work.
4. Do not add packages unless explicitly required and approved.
5. Do not rewrite architecture merely to solve a local issue.
6. Preserve existing HomeCard/HomeSection engine unless the task explicitly targets it.
7. Preserve GoRouter/AppRoute/navigation architecture unless explicitly targeted.
8. Booking/payment execution was historically out of scope until explicitly started.
9. Every implementation phase must validate with:
   - `flutter analyze`
   - `flutter test`
10. For backend work, validate the relevant TypeScript compile/test command.
11. Work in small phases.
12. Report exactly which files were created/modified and what was validated.
13. If a requested change conflicts with an existing architectural decision, stop and explain before changing architecture.

## 3. How AI Agents Should Work

### Analytical AI (ChatGPT / Claude / equivalent)
Use this file as the primary context. Its job is to:
- understand the whole system,
- identify the current phase,
- reason about architecture,
- produce a small, precise execution prompt,
- avoid asking the executor to rediscover project history.

### Execution AI (DeepSeek / Cline / Qwen / equivalent)
Use `02_AGENT_MEMORY.md` + `03_CURRENT_STATE.md` + the execution prompt.
The executor must:
1. inspect only the relevant files first,
2. make the smallest safe change,
3. never delete/rename,
4. validate,
5. report,
6. stop at the requested phase.

## 4. Current State Snapshot

- Phases 1–9: completed according to the latest project reports.
- Current workstream: AI architecture and AI provider integration.
- Phase 9: real OpenAI-compatible provider in NestJS.
- Phase 10: **not started**.
- Flutter AI UI exists and can consume the normalized AI contract.
- NestJS has `POST /ai/query`.
- Real provider is configured through an abstraction and environment variables.
- No real API key is stored in project memory.

## 5. Architecture Summary

### Flutter
```text
UI
 ↓
Riverpod Controller / State
 ↓
UseCase / Service / Repository
 ↓
Contracts / Providers
 ↓
Network / Storage
```

AI path:
```text
AiPromptInput
 ↓
AiController
 ↓
AiAssistantService
 ↓
AiProvider / backend
 ↓
AiResponse
 ↓
AiHomeMapper
 ↓
HomeSectionWidget
 ↓
Existing HomeCard engine
```

### Backend
```text
POST /ai/query
 ↓
AiController
 ↓
AiService
 ↓
AI_PROVIDER abstraction
 ↓
OpenAiAiProvider (current binding)
 ↓
OpenAI-compatible /chat/completions
 ↓
normalized AiResponseDto
```

## 6. Phase History

### Phase 1 — Routing Only
Completed.
- Replaced placeholders for:
  - `/` → `HomePage`
  - `/flights` → `FlightSearchPage`
  - `/hotels` → `HotelSearchPage`
  - `/cars` → `CarSearchPage`
- Only `go_router_config.dart` was changed.
- ShellRoute, redirect, AppRoute, and navigation architecture preserved.
- Remaining placeholder routes were intentionally left alone.
- BookingReview was not wired because it requires mandatory parameters and there was no matching route.

### Phase 2 — AI / Normal Mode State
Completed.
- Added `lib/shared/providers/app_mode_provider.dart`.
- `AppMode { ai, normal }`.
- Default is `AppMode.ai`.
- `shell.dart` hides FloatingNavigation in AI mode and preserves it in normal mode.
- No AI UI or toggle logic yet at this phase.

### Phase 3 — AI Visual Shell
Completed.
Created:
- `lib/features/ai/presentation/pages/ai_visual_shell_page.dart`
- `ai_ambient_visual.dart`
- `ai_empty_state.dart`
- `ai_prompt_input.dart`
- `ai_mode_indicator.dart`

Modified:
- `lib/app/shell.dart`

Behavior:
- AI mode shows a full visual AI shell.
- Normal mode retains FloatingNavigation.
- Ambient animation is presentation-only.
- Prompt input existed without network/backend logic.

### Phase 4 — AI Response Contract
Completed.
Created:
- `ai_response.dart`
- `ai_section.dart`
- `ai_item.dart`
- `ai_action.dart`
- `ai_home_mapper.dart`

Contract:
```text
AiResponse
  text?
  sections[]
  metadata

AiSection
  id?
  title
  subtitle?
  layout
  items[]
  order?
  metadata

AiItem
  id
  type
  HomeItem-compatible display fields
  order?
  data
  actions[]
  metadata

AiAction
  type
  label?
  payload
```

Important architectural decision:
- AI-specific domain models were kept separate from HomeItem/HomeSection.
- Existing `HomeCardType` and `HomeSectionLayout` are reused.
- `AiHomeMapper` is the single boundary into Home display models.
- `data` is merged into HomeItem metadata where needed (for example flight route).

### Phase 5 — Mock AI Response → Existing Home Cards
Completed.
Created:
- `mock_ai_response_data.dart`
- `mock_ai_response_provider.dart`
- `ai_response_content.dart`

Modified:
- `ai_visual_shell_page.dart`

The mock response contained mixed sections:
- hotels
- flights
- destinations
- deals

It exercised multiple HomeCard types and ordering.
Pipeline:
```text
Mock data → AiResponse → AiHomeMapper → HomeSectionWidget → HomeCard
```
No HomeCard engine modification.

### Phase 6 — AI Controller + State
Completed.
Created:
- `ai_state.dart`
- `ai_response_source.dart`
- `ai_controller.dart`
- `ai_providers.dart`

State:
- `idle`
- `loading`
- `success`
- `empty`
- `error`

Controller:
- `submit`
- `retry`
- `reset`

Prompt input became a Riverpod consumer and submits directly to the controller.

### Phase 7 — AI Service Layer
Completed.
- Added `query(String prompt)` to `core/ai/ai_assistant_service.dart`.
- Added `MockAiAssistantService`.
- Controller depends on `AiAssistantService` + `AiHomeMapper`.
- Mock source is hidden behind the service boundary.
- No HTTP/backend yet.

Known architectural note:
- `AiResponse` lives under `features/ai/domain`, while `core/ai/ai_assistant_service.dart` references it. This is an intentional compromise to preserve existing files/contracts.

### Phase 8 — NestJS AI Endpoint
Completed.
Backend module location:
`backend/src/modules/ai/`

Created:
- `backend/src/common/dto/ai.dto.ts`
- `backend/src/modules/ai/ai.provider.ts`
- `mock.ai.provider.ts`
- `ai.service.ts`
- `ai.controller.ts`

Modified:
- `ai.module.ts`

Endpoint:
`POST /ai/query`

Request:
```json
{ "prompt": "user text" }
```

Validation:
- string
- non-empty
- max length 4000
- global whitelist/forbidNonWhitelisted behavior

Provider abstraction:
- `AI_PROVIDER`
- `AiProvider`
- `generate(prompt)`

Response normalized to the Flutter AI contract.

### Phase 9 — Real AI Provider
Completed.
Created:
- `backend/src/modules/ai/openai.ai.provider.ts`
- `backend/.env.example`

Modified:
- `backend/src/modules/ai/ai.module.ts`

Current binding:
```text
AI_PROVIDER → OpenAiAiProvider
```

Environment:
- `AI_API_KEY` required at runtime
- `AI_BASE_URL` default: `https://api.openai.com/v1`
- `AI_MODEL` default: `gpt-4o-mini`

No API key is stored in the repository.

Runtime behavior when key is missing:
- backend can respond with a configuration-related 503 from the AI provider path rather than inventing a key.

## 7. Important Existing Systems

### Home
Home is a mature card/section engine and must be treated as a stable consumer.
Known card types include:
- hotel
- flight
- destination
- deal
- experience
- story
- car
- package

AI must feed Home through the mapper rather than changing the card engine.

### Search
Search foundations exist for:
- flights
- hotels
- cars
- filtering
- sorting
- offer selection

### Booking
Booking domain/application foundations exist, including:
- preparation
- revalidation
- confirmation
- state machine
- idempotency

Do not assume booking execution/payment is complete merely because booking models/controllers exist.

### Payment
Payment domain exists, but payment execution should not be assumed complete without a current validation.

### Navigation
GoRouter + ShellRoute + AppRoute are established.
FloatingNavigation is used in normal mode.

## 8. AI Contract Compatibility

The backend response must stay compatible with Flutter `AiResponse.fromMap()`.

Important fields:
- response `text`
- sections
- `layout`
- items
- item `type`
- item `data`
- item `actions`
- metadata

Examples:
- flight route can be carried in `data.route`
- car-specific type can be carried in `data.type`

Provider identity should not leak into the user-facing AI response contract unless explicitly needed.

## 9. Known Issues / Caveats

- Previous TypeScript compile reports showed `TS2564` strict property initialization errors in old DTOs/entities outside the AI scope.
- These were deliberately not changed during Phase 8/9.
- A live AI request was not validated without a real API key.
- Database connectivity was previously a separate backend boot concern.
- AI provider switching is currently controlled in the module binding rather than a dynamic environment factory.
- The AI service/core direction contains the noted dependency inversion compromise described above.
- `AiResponseSource` remains as an internal/mock-oriented contract unless later cleanup is explicitly approved.

## 10. Phase 10 Candidate Work

Phase 10 was not started. Candidate objectives should be decided only after inspecting the current repository.

Likely topics:
1. harden LLM JSON parsing/normalization,
2. handle malformed/fenced JSON robustly,
3. verify live Flutter → backend → AI flow,
4. add provider configuration/fallback policy,
5. add AI request/error observability,
6. add tests for the normalized contract,
7. only then consider production concerns.

Do not automatically implement all candidates as one phase.

## 11. Validation Baseline

Last broad Flutter project report:
- Flutter analyze: 0 errors (warnings/info only).
- Flutter tests: 55 tests passed.
This is a historical baseline and must be re-run before relying on it.

## 12. Handoff Rule

If another AI receives this file:
- Do not assume the current filesystem exactly matches every historical report.
- First run a non-destructive inspection.
- Compare actual files against this memory.
- Update `03_CURRENT_STATE.md` only after verifying.
- Do not silently reconcile contradictions.
