# WeTravellers — CURRENT STATE

## Last known checkpoint
**AI Phases 1–10 complete. Phases 11A–11C, 12, 13, 14A, 14B, 15A and 15B complete. Live AI works via an OpenAI-compatible provider (tested with OpenRouter). Phase 15B (Context-aware AI + Card Engine integration) implemented successfully with full home feed context extraction. Next pending phase: Phase 15C — Fix all remaining test errors and code hygiene issues (urgent). Project roadmap updated to include new phases for offline support, memory cloud sync, accessibility, and analytics.**

## Last confirmed AI state
- AI visual shell exists.
- AI prompt input exists (persistent CommandBar wired into shell).
- AI state/controller exists and is test-covered.
- AI response contract exists (AiResponse) and mapper (AiHomeMapper) is in place.
- AI Bottom Sheet UI prototype implemented (lib/features/ai/presentation/widgets/ai_bottom_sheet.dart) and wired to CommandBar fallback.
- Mock AI path available and used as a safe fallback for UI prototypes.
- NestJS `POST /ai/query` endpoint and AiApiService integration exist in code, but live requests require runtime AI_API_KEY.
- Provider abstraction exists; provider wiring supports swapping the mock and the HTTP AiApiService at provider level.
- Phase 10 sub-phases 10A–10D are complete (commit `eda9668e`).
- 11B1 Home schema contract and 11C search error sanitization are complete and tested.
- Phase 12 (Home Marketplace) UI delivered and tested for the HomeController changes.
- Phase 13 (Floating/Orbital Navigation + persistent CommandBar) implemented and committed.
- Phase 14A (AI Bottom Sheet UI prototype) implemented and committed (commit f2170a7c).
- Phase 14B complete: CommandBar Ask button + TextField submit now read/trim/clear the input (CommandBar is a StatefulWidget with its own TextEditingController); CommandBar wired via `onSubmitted` to search heuristics or `showAiBottomSheet`.
- Backend AI provider timeout raised to 90s (`REQUEST_TIMEOUT_MS`); timeout/abort errors are now classified as retryable `timeout` so the configured Mock fallback serves the request instead of failing silently.
- Flutter AI sheet timeout aligned to 90s to match the slow/free OpenRouter provider.

- Unit and integration tests around the AI parsing/controller passed locally after these changes.

## Immediate next action

- Next pending phase: **Phase 15 — Context-aware AI + Card Engine integration** (current page/result context, Help-me-choose, Explain/Compare/Alternatives/Add-to-trip card actions, manual search filter application). Do not start it without an explicit instruction.
- Phase 14B is complete: CommandBar wired to `showAiBottomSheet`, backend AI timeout raised to 90s, Flutter sheet timeout aligned to 90s, and timeout failures classified as retryable so the Mock fallback engages instead of failing silently.
- Live AI works via the OpenAI-compatible provider (tested with OpenRouter, `openrouter/free`).
- `.env` is local only; do not assume live credentials exist in git.
- Do not assume booking/payment execution is production-ready.

11B1/11C validation summary (already passing):
1. `backend/test/home.schema.spec.ts` passed.
2. `npm run build` passed in `backend/` when last verified.
3. `test/core/repositories/home_repository_impl_test.dart` passed.

Notes:
- `flutter analyze` produces non-blocking warnings (deprecated APIs, unused imports); these should be addressed separately (low priority hygiene).
- Last local AI-related commit: 2026-08-20 updates for Phase 15B (Context-aware AI integration). Core lib files are error-free, only test files require small updates.
- Copilot Chat in VS Code had a connectivity issue earlier (ERR_CONNECTION_TIMED_OUT) — unrelated to runtime code but noted for developer UX.

## Phase 15B (Context-aware AI + Card Engine integration) — COMPLETED
**All sub-stages delivered successfully**:
- Stage 1: Updated `AiQueryContext` with optional `geolocation` and `travelDates` fields (non-breaking change)
- Stage 2: Added backend DTOs (`GeolocationDto`, `TravelDatesDto`, `AiContextDto`) for type-safe context transmission
- Stage 3: Implemented `AiHomeMapper.extractContextFromHomeSections()` to automatically collect home feed context (visible item IDs, section metadata)
- Stage 4: Updated `AiController.submit()` to build context automatically from current home sections and pass it to the AI service
- Stage 5: Validated core functionality works with zero errors in lib/ directory, only test files require minor updates

## Phase 15C — Urgent: Fix all remaining issues (IN PROGRESS)
**Goal**: Resolve all 51 original build errors and remaining code hygiene issues to bring `flutter analyze` to zero errors.
**Completed sub-stages**:
1.  ✅ Stage 1: Update all mock AI services in test files to include the new `AiQueryContext? context` parameter in their `query()` method
2.  ✅ Stage 2: Fix the argument type error in `ai_bottom_sheet_test.dart` line 171 to match the new provider signature
3.  ✅ Stage 3: Run full test suite to verify all AI-related tests pass
4.  ✅ Fixed default AppMode in app_mode_provider.dart from ai to normal to enable main page access
5.  ✅ Fixed dead code issue in ai_bottom_sheet.dart (removed unreachable return statement)
6.  ✅ All original 51 build errors are RESOLVED - now only 42 non-blocking warnings/info issues remain

**Remaining sub-stages**:
1.  Fix routing redirect logic in go_router_config.dart to bypass login page for unauthenticated users
2.  Address remaining code hygiene issues (unused imports, dead code, minor lint warnings)

## Do not assume
- Do not assume the historical 55-test baseline is still current.
- Do not assume database connectivity.
- Do not assume live AI credentials exist.
- Do not assume booking/payment execution is production-ready.






<!-- AUTO_GIT_STATE_START -->
## Automatic Git State

- Branch: main
- Last commit observed before this commit: 5ff9bfa1
- Repository status before commit: see `PROJECT_GIT_STATUS.md`
- Memory synchronization timestamp: 2026-08-16 00:40:50 +0300
<!-- AUTO_GIT_STATE_END -->

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
be7b5898 (HEAD -> main) chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
606ede31 test: verify automatic memory sync
720b3c67 chore: improve project memory sync
3cba7f13 docs: add multi-agent project memory system
c8455f1d chore: fix automatic memory bundle
35c730d1 chore: sync memory bundle
82237090 chore: sync memory bundle
d5d39a7f chore: save updated project memory
8acd9024 chore: save updated project memory
```

### Pending status
```
M  .githooks/post-commit
M  .githooks/pre-commit
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
d2fa72bc (HEAD -> main) chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
606ede31 test: verify automatic memory sync
720b3c67 chore: improve project memory sync
3cba7f13 docs: add multi-agent project memory system
c8455f1d chore: fix automatic memory bundle
35c730d1 chore: sync memory bundle
82237090 chore: sync memory bundle
d5d39a7f chore: save updated project memory
```

### Pending status
```
M  .gitignore
M  backend/src/modules/ai/openai.ai.provider.ts
A  backend/test/ai.contract.spec.ts
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
35381a1e (HEAD -> main, flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
606ede31 test: verify automatic memory sync
720b3c67 chore: improve project memory sync
3cba7f13 docs: add multi-agent project memory system
c8455f1d chore: fix automatic memory bundle
35c730d1 chore: sync memory bundle
82237090 chore: sync memory bundle
```

### Pending status
```
M  backend/.env.example
M  backend/package.json
M  backend/src/modules/ai/ai.module.ts
M  backend/src/modules/ai/ai.provider.ts
M  backend/src/modules/ai/ai.service.ts
M  backend/src/modules/ai/openai.ai.provider.ts
A  backend/test/ai.fallback.spec.ts
A  backend/test/ai.http.integration.spec.ts
A  backend/test/ai.observability.spec.ts
M  lib/features/ai/application/ai_controller.dart
M  lib/features/ai/domain/ai_action.dart
M  lib/features/ai/domain/ai_item.dart
A  lib/features/ai/domain/ai_parsing.dart
M  lib/features/ai/domain/ai_response.dart
M  lib/features/ai/domain/ai_section.dart
A  test/features/ai/ai_controller_error_test.dart
A  test/features/ai/ai_http_integration_test.dart
A  test/features/ai/ai_parsing_test.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
eda9668e (HEAD -> main) feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
606ede31 test: verify automatic memory sync
720b3c67 chore: improve project memory sync
3cba7f13 docs: add multi-agent project memory system
c8455f1d chore: fix automatic memory bundle
35c730d1 chore: sync memory bundle
```

### Pending status
```
M  backend/src/common/cache/cache.provider.ts
M  backend/src/modules/cache/cache.module.ts
M  backend/src/modules/cache/cache.service.ts
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
e580b4b7 (HEAD -> main) cache
eda9668e feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
606ede31 test: verify automatic memory sync
720b3c67 chore: improve project memory sync
3cba7f13 docs: add multi-agent project memory system
c8455f1d chore: fix automatic memory bundle
```

### Pending status
```
M  PROJECT_MEMORY/01_MASTER_MEMORY.md
M  PROJECT_MEMORY/02_AGENT_MEMORY.md
M  PROJECT_MEMORY/03_CURRENT_STATE.md
M  PROJECT_MEMORY/04_PHASE_HISTORY.md
M  PROJECT_MEMORY/08_NEXT_STEPS.md
M  PROJECT_MEMORY/10_DEEPSEEK_CONTEXT.md
M  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/ACTIVE_CONTEXT.md
M  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/CHANGELOG.md
M  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/PHASE_REGISTRY.md
M  backend/.env.example
A  backend/docker-compose.yml
M  backend/src/common/dto/auth.dto.ts
M  backend/src/common/dto/car.search.dto.ts
M  backend/src/common/dto/flight.search.dto.ts
M  backend/src/common/dto/hotel.search.dto.ts
M  backend/src/database/entities/audit_log.entity.ts
M  backend/src/database/entities/home_card.entity.ts
M  backend/src/database/entities/home_section.entity.ts
M  backend/src/database/entities/offer.entity.ts
M  backend/src/database/entities/provider.entity.ts
M  backend/src/database/entities/session.entity.ts
M  backend/src/database/entities/user.entity.ts
M  backend/src/modules/home/home.service.ts
A  lib/core/network/user_facing_message.dart
M  lib/features/search/application/controllers/car_search_controller.dart
M  lib/features/search/application/controllers/flight_search_controller.dart
M  lib/features/search/application/controllers/hotel_search_controller.dart
A  test/features/search/car_search_controller_test.dart
A  test/features/search/flight_search_controller_test.dart
A  test/features/search/hotel_search_controller_test.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
e06e1f64 (HEAD -> main) eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
606ede31 test: verify automatic memory sync
720b3c67 chore: improve project memory sync
3cba7f13 docs: add multi-agent project memory system
```

### Pending status
```
M  PROJECT_MEMORY/01_MASTER_MEMORY.md
M  PROJECT_MEMORY/02_AGENT_MEMORY.md
M  PROJECT_MEMORY/03_CURRENT_STATE.md
M  PROJECT_MEMORY/04_PHASE_HISTORY.md
M  PROJECT_MEMORY/08_NEXT_STEPS.md
M  PROJECT_MEMORY/10_DEEPSEEK_CONTEXT.md
M  backend/src/common/dto/home.dto.ts
M  backend/src/modules/home/home.service.ts
A  backend/test/home.schema.spec.ts
A  test/core/repositories/home_repository_impl_test.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
24574c62 (HEAD -> main) UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
606ede31 test: verify automatic memory sync
720b3c67 chore: improve project memory sync
```

### Pending status
```
M  lib/app/shell.dart
A  lib/core/widgets/command_bar/.gitkeep
A  lib/core/widgets/command_bar/command_bar.dart
M  lib/features/home/presentation/home_controller.dart
M  lib/features/home/presentation/pages/home_page.dart
M  test/features/home/home_controller_test.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
eebecb3b (HEAD -> main) feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
606ede31 test: verify automatic memory sync
```

### Pending status
```
 M lib/app/shell.dart
A  lib/features/ai/presentation/widgets/ai_bottom_sheet.dart
?? lib/features/ai/application/ai_mock_providers.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
f2170a7c (HEAD -> main) AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
5ff9bfa1 chore: add AI handoff helper
```

### Pending status
```
M  PROJECT_MEMORY/03_CURRENT_STATE.md
M  PROJECT_MEMORY/08_NEXT_STEPS.md
 M lib/app/shell.dart
?? lib/features/ai/application/ai_mock_providers.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
2cb8cc93 (HEAD -> main) PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
be7b5898 chore: finalize synchronized memory state
```

### Pending status
```
M  lib/app/shell.dart
M  lib/core/ai/ai_assistant_service.dart
M  lib/core/network/api_client.dart
M  lib/core/network/api_error.dart
M  lib/core/network/http_api_client.dart
M  lib/core/network/user_facing_message.dart
M  lib/features/ai/application/ai_controller.dart
A  lib/features/ai/application/ai_mock_providers.dart
M  lib/features/ai/data/ai_api_service.dart
M  lib/features/ai/data/mock_ai_assistant_service.dart
M  lib/features/ai/presentation/widgets/ai_bottom_sheet.dart
M  test/core/repositories/home_repository_impl_test.dart
A  test/features/ai/ai_bottom_sheet_test.dart
M  test/features/ai/ai_controller_error_test.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
c3d6391a (HEAD -> main) fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
d2fa72bc chore: fix automatic memory synchronization
```

### Pending status
```

```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
9450e564 (HEAD -> main) fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
35381a1e (flint-gigantoraptor) feat(ai): complete phases 10a 10b and 10d
```

### Pending status
```
A  0001-fix-test-update-mocks-to-match-ApiClient-RequestToke.patch
A  0002-fix-network-ensure-all-ApiClient-implementors-accept.patch
M  lib/core/network/api_client.dart
M  lib/core/network/http_api_client.dart
A  test/core/network/http_api_client_abort_test.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
d708d8b1 (HEAD -> main) feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
```

### Pending status
```

```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
d708d8b1 (HEAD -> main) feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
eda9668e feat(ai): complete phases 10a-10d
```

### Pending status
```
M  PROJECT_MEMORY/03_CURRENT_STATE.md
M  PROJECT_MEMORY/09_AI_HANDOFF.md
M  WeTravellers_PROJECT_MEMORY_SYSTEM.zip
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
e41a3f1e (HEAD -> main) test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
e580b4b7 cache
```

### Pending status
```
M  backend/src/modules/ai/ai.module.ts
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
ac559b37 (HEAD -> main) chore(ai): runtime provider selection (OpenAi when AI_API_KEY set, otherwise Mock)
e41a3f1e test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
e06e1f64 eda9668e feat(ai): complete phases 10a-10d
```

### Pending status
```
M  PROJECT_MEMORY/01_MASTER_MEMORY.md
M  PROJECT_MEMORY/02_AGENT_MEMORY.md
M  PROJECT_MEMORY/03_CURRENT_STATE.md
M  PROJECT_MEMORY/04_PHASE_HISTORY.md
M  PROJECT_MEMORY/08_NEXT_STEPS.md
M  PROJECT_MEMORY/09_AI_HANDOFF.md
M  PROJECT_MEMORY/10_DEEPSEEK_CONTEXT.md
 D WeTravellers_MEMORY_BUNDLE_V4_2026-08-15.zip
M  backend/src/modules/ai/openai.ai.provider.ts
M  lib/core/widgets/command_bar/command_bar.dart
M  lib/features/ai/presentation/widgets/ai_bottom_sheet.dart
A  test/core/widgets/command_bar_test.dart
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
d53d9d52 (HEAD -> main) feat(ai): complete phase 14B command bar wiring and AI timeout hardening
ac559b37 chore(ai): runtime provider selection (OpenAi when AI_API_KEY set, otherwise Mock)
e41a3f1e test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
24574c62 UPGRADE UI AND UX GROPS AND  BAG AND HOME WITH AI
```

### Pending status
```
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15.zip
```

---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
6d98c980 (HEAD -> main) ok
d53d9d52 feat(ai): complete phase 14B command bar wiring and AI timeout hardening
ac559b37 chore(ai): runtime provider selection (OpenAi when AI_API_KEY set, otherwise Mock)
e41a3f1e test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
eebecb3b feat(ui): add persistent command bar and integrate floating navigation (phase 13)\n\nPhase 13: Floating/Orbital Navigation + persistent command bar\n\nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### Pending status
```
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/.githooks/post-commit
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/PROJECT_GIT_STATUS.md
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/README.md
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/ACTIVE_CONTEXT.md
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/ARCHITECTURE.md
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/CHANGELOG.md
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/DECISIONS.md
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/DEEPSEEK_HANDOFF_PROMPT.txt
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/KNOWN_ISSUES.md
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/PHASE_REGISTRY.md
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/docs/project_memory/PROJECT_MANIFEST.json
D  WeTravellers_MEMORY_BUNDLE_V4_2026-08-15/tools/update_project_memory.py
A  lib/features/ai/domain/ai_query_context.dart
```
---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
6e239c6a (HEAD -> main) clean
6d98c980 ok
d53d9d52 feat(ai): complete phase 14B command bar wiring and AI timeout hardening
ac559b37 chore(ai): runtime provider selection (OpenAi when AI_API_KEY set, otherwise Mock)
e41a3f1e test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
```

### Pending status
```
 M .githooks/post-commit
 M .githooks/pre-commit
 M backend/src/common/dto/ai.dto.ts
 M backend/src/modules/ai/ai.controller.ts
 M backend/src/modules/ai/ai.service.ts
 M lib/app/shell.dart
 M lib/core/ai/ai_assistant_service.dart
 M lib/features/ai/data/ai_api_service.dart
 M lib/features/ai/data/mock_ai_assistant_service.dart
 M lib/features/ai/presentation/widgets/ai_bottom_sheet.dart
```---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
6e239c6a (HEAD -> main) clean
6d98c980 ok
d53d9d52 feat(ai): complete phase 14B command bar wiring and AI timeout hardening
ac559b37 chore(ai): runtime provider selection (OpenAi when AI_API_KEY set, otherwise Mock)
e41a3f1e test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
f2170a7c AI: bottom sheet — primary/fallback service, typed FutureBuilder, user-facing errors
```

### Pending status
```
D  .githooks/post-commit
M  .githooks/pre-commit
M  PROJECT_MEMORY/03_CURRENT_STATE.md
M  PROJECT_MEMORY/04_PHASE_HISTORY.md
M  PROJECT_MEMORY/09_AI_HANDOFF.md
M  WeTravellers_PROJECT_MEMORY_SYSTEM.zip
 M backend/src/common/dto/ai.dto.ts
 M backend/src/modules/ai/ai.controller.ts
 M backend/src/modules/ai/ai.service.ts
 M lib/app/shell.dart
 M lib/core/ai/ai_assistant_service.dart
 M lib/features/ai/data/ai_api_service.dart
 M lib/features/ai/data/mock_ai_assistant_service.dart
 M lib/features/ai/presentation/widgets/ai_bottom_sheet.dart
```---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
327d7990 (HEAD -> main) feat(ai): phase 15A context-aware query foundation and quiet hooks
6e239c6a clean
6d98c980 ok
d53d9d52 feat(ai): complete phase 14B command bar wiring and AI timeout hardening
ac559b37 chore(ai): runtime provider selection (OpenAi when AI_API_KEY set, otherwise Mock)
e41a3f1e test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
2cb8cc93 PROJECT_MEMORY: update current state and next steps after Phase 12/13/14A work
```

### Pending status
```
A  .githooks/post-commit
M  PROJECT_MEMORY/03_CURRENT_STATE.md
M  PROJECT_MEMORY/04_PHASE_HISTORY.md
M  backend/src/common/dto/ai.dto.ts
M  backend/src/modules/ai/ai.controller.ts
M  backend/src/modules/ai/ai.service.ts
M  lib/app/shell.dart
M  lib/core/ai/ai_assistant_service.dart
M  lib/features/ai/application/ai_controller.dart
M  lib/features/ai/data/ai_api_service.dart
M  lib/features/ai/data/mock_ai_assistant_service.dart
M  lib/features/ai/domain/ai_home_mapper.dart
M  lib/features/ai/domain/ai_query_context.dart
M  lib/features/ai/presentation/widgets/ai_bottom_sheet.dart
M  test/features/ai/ai_bottom_sheet_test.dart
M  test/features/ai/ai_controller_error_test.dart
```---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
005231e5 (HEAD -> main) new agent
327d7990 feat(ai): phase 15A context-aware query foundation and quiet hooks
6e239c6a clean
6d98c980 ok
d53d9d52 feat(ai): complete phase 14B command bar wiring and AI timeout hardening
ac559b37 chore(ai): runtime provider selection (OpenAi when AI_API_KEY set, otherwise Mock)
e41a3f1e test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
c3d6391a fix(test): update mocks to match ApiClient RequestToken signature
```

### Pending status
```
M  PROJECT_MEMORY/03_CURRENT_STATE.md
A  analysis_report.txt
M  backend/node_modules/.package-lock.json
A  backend/node_modules/@duffel/api/LICENSE
A  backend/node_modules/@duffel/api/README.md
A  backend/node_modules/@duffel/api/dist/Cars/Bookings/Bookings.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/Bookings/Bookings.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/Bookings/index.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/Cars.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/Cars.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/CarsTypes.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/Quotes/Quotes.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/Quotes/Quotes.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/Quotes/index.d.ts
A  backend/node_modules/@duffel/api/dist/Cars/mocks.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/PaymentIntents/PaymentIntents.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/PaymentIntents/PaymentIntents.spec.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/PaymentIntents/PaymentIntentsType.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/PaymentIntents/index.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/PaymentIntents/mockPaymentIntents.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/Refunds/Refunds.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/Refunds/Refunds.spec.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/Refunds/RefundsType.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/Refunds/index.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/Refunds/mockRefunds.d.ts
A  backend/node_modules/@duffel/api/dist/DuffelPayments/index.d.ts
A  backend/node_modules/@duffel/api/dist/Identity/ComponentClientKeys.d.ts
A  backend/node_modules/@duffel/api/dist/Identity/CustomerUserGroups.d.ts
A  backend/node_modules/@duffel/api/dist/Identity/CustomerUsers.d.ts
A  backend/node_modules/@duffel/api/dist/Identity/Identity.d.ts
A  backend/node_modules/@duffel/api/dist/Identity/Identity.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Identity/IdentityTypes.d.ts
A  backend/node_modules/@duffel/api/dist/Links/Sessions/Sessions.d.ts
A  backend/node_modules/@duffel/api/dist/Links/Sessions/Sessions.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Links/Sessions/index.d.ts
A  backend/node_modules/@duffel/api/dist/Links/index.d.ts
A  backend/node_modules/@duffel/api/dist/Payments/Cards/Cards.d.ts
A  backend/node_modules/@duffel/api/dist/Payments/Cards/Cards.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Payments/Cards/index.d.ts
A  backend/node_modules/@duffel/api/dist/Payments/ThreeDSecureSessions/ThreeDSecureSessions.d.ts
A  backend/node_modules/@duffel/api/dist/Payments/ThreeDSecureSessions/ThreeDSecureSessions.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Payments/ThreeDSecureSessions/index.d.ts
A  backend/node_modules/@duffel/api/dist/Payments/index.d.ts
A  backend/node_modules/@duffel/api/dist/Places/Suggestions/Suggestions.d.ts
A  backend/node_modules/@duffel/api/dist/Places/Suggestions/Suggestions.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Places/Suggestions/SuggestionsType.d.ts
A  backend/node_modules/@duffel/api/dist/Places/Suggestions/index.d.ts
A  backend/node_modules/@duffel/api/dist/Places/Suggestions/mockSuggestions.d.ts
A  backend/node_modules/@duffel/api/dist/Places/index.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Accommodation/Accommodation.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Accommodation/Accommodation.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Accommodation/index.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Bookings/Bookings.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Bookings/Bookings.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Bookings/index.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Brands/Brands.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Brands/Brands.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Brands/index.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/LoyaltyProgrammes/LoyaltyProgrammes.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/LoyaltyProgrammes/LoyaltyProgrammes.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/LoyaltyProgrammes/index.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/NegotiatedRates/NegotiatedRates.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/NegotiatedRates/NegotiatedRates.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/NegotiatedRates/index.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Quotes/Quotes.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Quotes/Quotes.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Quotes/index.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/SearchResults/SearchResults.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/SearchResults/SearchResults.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/SearchResults/index.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Stays.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/Stays.spec.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/StaysTypes.d.ts
A  backend/node_modules/@duffel/api/dist/Stays/mocks.d.ts
A  backend/node_modules/@duffel/api/dist/booking/AirlineInitiatedChanges/AirlineInitiatedChanges.d.ts
A  backend/node_modules/@duffel/api/dist/booking/AirlineInitiatedChanges/AirlineInitiatedChanges.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/AirlineInitiatedChanges/AirlineInitiatedChangesTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/AirlineInitiatedChanges/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/AirlineInitiatedChanges/mockAirlineInitiatedChanges.d.ts
A  backend/node_modules/@duffel/api/dist/booking/BatchOfferRequests/BatchOfferRequests.d.ts
A  backend/node_modules/@duffel/api/dist/booking/BatchOfferRequests/BatchOfferRequests.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/BatchOfferRequests/BatchOfferRequestsTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/BatchOfferRequests/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/BatchOfferRequests/mockBatchOfferRequest.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Identity/ComponentClientKey/ComponentClientKeys.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Identity/ComponentClientKey/ComponentClientKeys.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Identity/ComponentClientKey/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Identity/ComponentClientKey/mockComponentClientKey.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Identity/ComponentClientKey/types.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Identity/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OfferRequests/OfferRequests.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OfferRequests/OfferRequests.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OfferRequests/OfferRequestsTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OfferRequests/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OfferRequests/mockOfferRequest.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Offers/OfferTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Offers/Offers.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Offers/Offers.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Offers/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Offers/mockOffer.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Offers/mockPartialOffer.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderCancellations/OrderCancellations.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderCancellations/OrderCancellations.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderCancellations/OrderCancellationsTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderCancellations/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderCancellations/mockOrderCancellations.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeOffers/OrderChangeOfferTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeOffers/OrderChangeOffers.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeOffers/OrderChangeOffers.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeOffers/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeOffers/mockOrderChangeOffer.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeRequests/OrderChangeRequests.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeRequests/OrderChangeRequestsTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeRequests/OrderRequestChanges.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeRequests/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChangeRequests/mockOrderChangeRequests.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChanges/OrderChanges.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChanges/OrderChanges.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChanges/OrderChangesTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChanges/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/OrderChanges/mockOrderChanges.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Orders/Orders.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Orders/Orders.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Orders/OrdersTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Orders/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Orders/mockOrders.d.ts
A  backend/node_modules/@duffel/api/dist/booking/PartialOfferRequests/PartialOfferRequestTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/PartialOfferRequests/PartialOfferRequests.d.ts
A  backend/node_modules/@duffel/api/dist/booking/PartialOfferRequests/PartialOfferRequests.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/PartialOfferRequests/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/PartialOfferRequests/mockPartialOfferRequest.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Payments/Payments.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Payments/Payments.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Payments/PaymentsTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Payments/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/Payments/mockPayment.d.ts
A  backend/node_modules/@duffel/api/dist/booking/SeatMaps/SeatMapTypes.d.ts
A  backend/node_modules/@duffel/api/dist/booking/SeatMaps/SeatMaps.d.ts
A  backend/node_modules/@duffel/api/dist/booking/SeatMaps/SeatMaps.spec.d.ts
A  backend/node_modules/@duffel/api/dist/booking/SeatMaps/index.d.ts
A  backend/node_modules/@duffel/api/dist/booking/SeatMaps/mockSeatMap.d.ts
A  backend/node_modules/@duffel/api/dist/booking/index.d.ts
A  backend/node_modules/@duffel/api/dist/functions/hasAvailableSeatService.d.ts
A  backend/node_modules/@duffel/api/dist/functions/hasAvailableSeatService.spec.d.ts
A  backend/node_modules/@duffel/api/dist/functions/hasService.d.ts
A  backend/node_modules/@duffel/api/dist/functions/hasService.spec.d.ts
A  backend/node_modules/@duffel/api/dist/index.es.js
A  backend/node_modules/@duffel/api/dist/index.es.js.map
A  backend/node_modules/@duffel/api/dist/index.js
A  backend/node_modules/@duffel/api/dist/index.js.map
A  backend/node_modules/@duffel/api/dist/notifications/Webhooks/Webhooks.d.ts
A  backend/node_modules/@duffel/api/dist/notifications/Webhooks/Webhooks.spec.d.ts
A  backend/node_modules/@duffel/api/dist/notifications/Webhooks/WebhooksType.d.ts
A  backend/node_modules/@duffel/api/dist/notifications/Webhooks/index.d.ts
A  backend/node_modules/@duffel/api/dist/notifications/Webhooks/mockWebhooks.d.ts
A  backend/node_modules/@duffel/api/dist/notifications/index.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Aircraft/Aircraft.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Aircraft/Aircraft.spec.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Aircraft/AircraftTypes.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Aircraft/index.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Aircraft/mockAircraft.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airlines/Airlines.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airlines/Airlines.spec.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airlines/AirlinesTypes.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airlines/index.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airlines/mockAirline.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airports/Airports.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airports/Airports.spec.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airports/AirportsTypes.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airports/index.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/Airports/mockAirport.d.ts
A  backend/node_modules/@duffel/api/dist/supportingResources/index.d.ts
A  backend/node_modules/@duffel/api/dist/typings.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/LICENSE
A  backend/node_modules/@duffel/api/node_modules/@types/node/README.md
A  backend/node_modules/@duffel/api/node_modules/@types/node/assert.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/assert/strict.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/async_hooks.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/buffer.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/child_process.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/cluster.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/console.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/constants.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/crypto.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/dgram.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/diagnostics_channel.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/dns.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/dns/promises.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/domain.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/events.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/fs.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/fs/promises.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/globals.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/globals.global.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/http.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/http2.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/https.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/index.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/inspector.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/module.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/net.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/os.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/package.json
A  backend/node_modules/@duffel/api/node_modules/@types/node/path.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/perf_hooks.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/process.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/punycode.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/querystring.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/readline.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/repl.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/stream.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/stream/consumers.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/stream/promises.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/stream/web.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/string_decoder.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/test.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/timers.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/timers/promises.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/tls.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/trace_events.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/tty.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/url.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/util.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/v8.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/vm.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/wasi.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/worker_threads.d.ts
A  backend/node_modules/@duffel/api/node_modules/@types/node/zlib.d.ts
A  backend/node_modules/@duffel/api/package.json
A  backend/node_modules/@nestjs/throttler/LICENSE
A  backend/node_modules/@nestjs/throttler/README.md
A  backend/node_modules/@nestjs/throttler/dist/hash.d.ts
A  backend/node_modules/@nestjs/throttler/dist/hash.js
A  backend/node_modules/@nestjs/throttler/dist/hash.js.map
A  backend/node_modules/@nestjs/throttler/dist/index.d.ts
A  backend/node_modules/@nestjs/throttler/dist/index.js
A  backend/node_modules/@nestjs/throttler/dist/index.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler-module-options.interface.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler-module-options.interface.js
A  backend/node_modules/@nestjs/throttler/dist/throttler-module-options.interface.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage-options.interface.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage-options.interface.js
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage-options.interface.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage-record.interface.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage-record.interface.js
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage-record.interface.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage.interface.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage.interface.js
A  backend/node_modules/@nestjs/throttler/dist/throttler-storage.interface.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler.constants.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler.constants.js
A  backend/node_modules/@nestjs/throttler/dist/throttler.constants.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler.decorator.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler.decorator.js
A  backend/node_modules/@nestjs/throttler/dist/throttler.decorator.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler.exception.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler.exception.js
A  backend/node_modules/@nestjs/throttler/dist/throttler.exception.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler.guard.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler.guard.interface.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler.guard.interface.js
A  backend/node_modules/@nestjs/throttler/dist/throttler.guard.interface.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler.guard.js
A  backend/node_modules/@nestjs/throttler/dist/throttler.guard.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler.module.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler.module.js
A  backend/node_modules/@nestjs/throttler/dist/throttler.module.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler.providers.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler.providers.js
A  backend/node_modules/@nestjs/throttler/dist/throttler.providers.js.map
A  backend/node_modules/@nestjs/throttler/dist/throttler.service.d.ts
A  backend/node_modules/@nestjs/throttler/dist/throttler.service.js
A  backend/node_modules/@nestjs/throttler/dist/throttler.service.js.map
A  backend/node_modules/@nestjs/throttler/dist/tsconfig.build.tsbuildinfo
A  backend/node_modules/@nestjs/throttler/dist/utilities.d.ts
A  backend/node_modules/@nestjs/throttler/dist/utilities.js
A  backend/node_modules/@nestjs/throttler/dist/utilities.js.map
A  backend/node_modules/@nestjs/throttler/package.json
A  backend/node_modules/@types/node-fetch/LICENSE
A  backend/node_modules/@types/node-fetch/README.md
A  backend/node_modules/@types/node-fetch/externals.d.ts
A  backend/node_modules/@types/node-fetch/index.d.ts
A  backend/node_modules/@types/node-fetch/package.json
A  backend/node_modules/asynckit/LICENSE
A  backend/node_modules/asynckit/README.md
A  backend/node_modules/asynckit/bench.js
A  backend/node_modules/asynckit/index.js
A  backend/node_modules/asynckit/lib/abort.js
A  backend/node_modules/asynckit/lib/async.js
A  backend/node_modules/asynckit/lib/defer.js
A  backend/node_modules/asynckit/lib/iterate.js
A  backend/node_modules/asynckit/lib/readable_asynckit.js
A  backend/node_modules/asynckit/lib/readable_parallel.js
A  backend/node_modules/asynckit/lib/readable_serial.js
A  backend/node_modules/asynckit/lib/readable_serial_ordered.js
A  backend/node_modules/asynckit/lib/state.js
A  backend/node_modules/asynckit/lib/streamify.js
A  backend/node_modules/asynckit/lib/terminator.js
A  backend/node_modules/asynckit/package.json
A  backend/node_modules/asynckit/parallel.js
A  backend/node_modules/asynckit/serial.js
A  backend/node_modules/asynckit/serialOrdered.js
A  backend/node_modules/asynckit/stream.js
A  backend/node_modules/combined-stream/License
A  backend/node_modules/combined-stream/Readme.md
A  backend/node_modules/combined-stream/lib/combined_stream.js
A  backend/node_modules/combined-stream/package.json
A  backend/node_modules/combined-stream/yarn.lock
A  backend/node_modules/delayed-stream/.npmignore
A  backend/node_modules/delayed-stream/License
A  backend/node_modules/delayed-stream/Makefile
A  backend/node_modules/delayed-stream/Readme.md
A  backend/node_modules/delayed-stream/lib/delayed_stream.js
A  backend/node_modules/delayed-stream/package.json
A  backend/node_modules/es-set-tostringtag/.eslintrc
A  backend/node_modules/es-set-tostringtag/.nycrc
A  backend/node_modules/es-set-tostringtag/CHANGELOG.md
A  backend/node_modules/es-set-tostringtag/LICENSE
A  backend/node_modules/es-set-tostringtag/README.md
A  backend/node_modules/es-set-tostringtag/index.d.ts
A  backend/node_modules/es-set-tostringtag/index.js
A  backend/node_modules/es-set-tostringtag/package.json
A  backend/node_modules/es-set-tostringtag/test/index.js
A  backend/node_modules/es-set-tostringtag/tsconfig.json
A  backend/node_modules/form-data/CHANGELOG.md
A  backend/node_modules/form-data/License
A  backend/node_modules/form-data/README.md
A  backend/node_modules/form-data/index.d.ts
A  backend/node_modules/form-data/lib/browser.js
A  backend/node_modules/form-data/lib/form_data.js
A  backend/node_modules/form-data/lib/populate.js
A  backend/node_modules/form-data/package.json
M  backend/package-lock.json
M  backend/package.json
M  backend/src/app.module.ts
M  backend/src/modules/ai/ai.module.ts
M  backend/src/modules/ai/ai.service.ts
A  backend/src/modules/duffel/duffel.controller.ts
A  backend/src/modules/duffel/duffel.module.ts
A  backend/src/modules/duffel/duffel.service.ts
M  lib/core/mappers/offer_mapper_fixed.dart
M  lib/core/network/http_api_client.dart
M  lib/core/ui/accessible_button.dart
M  lib/features/ai/presentation/widgets/ai_bottom_sheet.dart
M  lib/features/booking/application/booking_controller.dart
M  lib/features/booking/application/booking_providers.dart
M  lib/features/search/application/controllers/hotel_search_controller.dart
M  lib/features/search/application/sort_utils.dart
M  lib/shared/providers/app_mode_provider.dart
M  test/features/ai/ai_bottom_sheet_test.dart
```
---
## Automatic Git Sync
- Branch: main
- Last sync before commit
- Repository status captured automatically

### Recent commits
```
1f42e833 (HEAD -> main) duffel install
005231e5 new agent
327d7990 feat(ai): phase 15A context-aware query foundation and quiet hooks
6e239c6a clean
6d98c980 ok
d53d9d52 feat(ai): complete phase 14B command bar wiring and AI timeout hardening
ac559b37 chore(ai): runtime provider selection (OpenAi when AI_API_KEY set, otherwise Mock)
e41a3f1e test(network): add tests for request abort behavior
d708d8b1 feat(network): implement hard abort for HttpApiClient using dart:io
9450e564 fix(network): ensure all ApiClient implementors accept RequestToken? token
```

### Pending status
```
M  backend/.env.example
M  backend/src/modules/ai/ai.module.ts
M  backend/src/modules/duffel/duffel.service.ts
```
