# WeTravellers — ARCHITECTURAL DECISIONS

## AI-specific models + mapper
Chosen instead of expanding HomeItem.
Reason: keep unstable AI contract separate from stable Home presentation models.

## Reuse HomeCardType/HomeSectionLayout
Chosen to keep vocabulary consistent and avoid duplicate enums.

## Mapper boundary
`AiHomeMapper` is the single bridge from AI response to Home sections.
This protects the HomeCard engine.

## Provider abstraction
Backend uses `AI_PROVIDER` so provider implementations can be swapped without changing controller/service/UI.

## OpenAI-compatible REST
Chosen for Phase 9 because no AI SDK was required and the same protocol can support compatible providers through base URL/model configuration.

## No secret in source
`AI_API_KEY` must be supplied by runtime environment. Never commit secrets.

## Phase isolation
Every phase must have explicit scope and validation.
