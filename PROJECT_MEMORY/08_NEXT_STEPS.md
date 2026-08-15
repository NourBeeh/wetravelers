# WeTravellers — NEXT STEPS

## Phase 10 candidates
Choose one focused objective, not all at once.

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
