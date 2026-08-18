# WeTravellers — NEXT STEPS

## Phase 10 candidates
Choose one focused objective, not all at once.

> **Addendum (2026-08-18):** Candidates A–D below were executed as sub-phases **10A–10D** and are **complete**; they are preserved below for history. The active forward plan is the "Future Product / UX Vision (Roadmap)" section at the end of this file.

### Candidate A — Response hardening
- robust extraction of JSON from model output
- malformed JSON handling
- schema normalization
- safe fallback text
- tests

### Candidate B — Live integration verification
- backend startup
- `/ai/query`
- Flutter request
- loading/success/error paths
- no secret leakage

### Candidate C — Provider configuration
- configurable provider binding
- safe fallback strategy
- clear runtime configuration errors

### Candidate D — AI contract tests
- DTO normalization
- Flutter `AiResponse.fromMap`
- mapper tests
- cross-layer fixture

## Recommended order
A → D → B → C

This is a recommendation, not an automatic instruction.

---

## Future Product / UX Vision (Roadmap)

> **Status:** Future product/UX direction (added 2026-08-18). Additive and non-destructive. Preserves completed AI phases 1–9 and 10A–10D. Introduces **no new phase numbers**; the numbered list below is implementation order only.

### Home
Home = Marketplace + Discovery.

Sections:
- Hero / Inspiration
- Recommended
- Hotels
- Flights
- Cars
- Packages / Tours
- Experiences / Deals
- Continue browsing

Use horizontal carousels and clear visual hierarchy. Do not give every section equal weight.

### Header
Top-right:
- Notifications
- Profile

Settings lives inside Profile.

### AI
AI = Universal Search + Travel Assistant, not a separate normal chat page.

Bottom of screen:
- AI search/input
- Floating Navigation button

AI input context:
- Home → global travel assistant
- Hotels → hotel context
- Flights → flight context
- Cars → car context

### AI Results
Show AI results in a draggable Bottom Sheet over the current page:
- collapsed
- half
- expanded

Swipe up/down to expand/collapse/close.

Results must use the existing Card Engine, not a separate AI card UI:

```text
AI Response → existing mapper/models → existing Card UI
```

### AI Sessions
Persist conversations as sessions.
User can reopen a session and continue with the same history/context.

### Navigation
Use Floating/Orbital Navigation instead of a permanent bottom bar.
Keep it limited to ~5–7 main actions.

### Future implementation order
1. Home Marketplace layout
2. Unified cards
3. Floating Navigation
4. AI Bottom Sheet
5. AI session persistence
6. Context-aware AI
7. AI → existing Card Engine
8. UX polish
