# WeTravellers Memory System V4

## Install
Copy the `docs/project_memory/` and `tools/` directories into the project root.

Optional Git hook:
    git config core.hooksPath .githooks

Manual update:
    python3 tools/update_project_memory.py

## Important
The updater can automatically capture repository metadata, but it cannot safely infer human decisions such as "Phase 10 is approved" from code. Update `PHASE_REGISTRY.md` / `DECISIONS.md` when a phase or architectural decision changes.

The system is intentionally additive and non-destructive.
