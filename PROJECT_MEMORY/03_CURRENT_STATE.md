# WeTravellers — CURRENT STATE

## Last known checkpoint
**AI Phases 1–10 complete. Phases 11A–11C, 12, 13, 14A and 14B complete. Live AI works via an OpenAI-compatible provider (tested with OpenRouter). Next pending phase: Phase 15 — Context-aware AI + Card Engine integration.**

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
- Last local AI-related commit: f2170a7c (AI bottom sheet wiring and safe error handling). Test run after the commit: AI-related tests passed locally.
- Copilot Chat in VS Code had a connectivity issue earlier (ERR_CONNECTION_TIMED_OUT) — unrelated to runtime code but noted for developer UX.

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
