# WeTravellers — ARCHITECTURE

## Flutter
- feature-first organization
- Riverpod state management
- GoRouter navigation
- Repository → UseCase → Controller
- reusable core theme/tokens/widgets
- Home card engine is a stable presentation consumer

## AI boundaries
```text
features/ai/presentation
        ↓
features/ai/application
        ↓
core/ai service abstraction
        ↓
backend API
        ↓
backend AI provider abstraction
        ↓
OpenAI-compatible provider
```

## Backend
NestJS module under:
`backend/src/modules/ai/`

Core concepts:
- DTO validation
- controller
- orchestration service
- provider abstraction
- provider binding in module
- normalized response

## Contract principle
AI-specific transport/domain models remain separate from Home presentation models.
`AiHomeMapper` is the explicit bridge.

## Navigation principle
AI mode overlays the routed surface.
Normal mode retains FloatingNavigation.
Avoid introducing a second navigation system.
