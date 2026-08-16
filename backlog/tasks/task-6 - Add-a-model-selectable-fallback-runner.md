---
id: TASK-6
title: Add a model-selectable fallback runner
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-16 23:22'
updated_date: '2026-08-16 23:50'
labels: []
dependencies: []
references:
  - agents/final-reviewer.md
modified_files:
  - agents/fallback-runner.md
  - models.sh
  - harnesses.sh
  - install.sh
  - tests/test_install.sh
  - AGENTS.md
  - README.md
type: enhancement
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pinned reviewer agents cannot accept a call-time model override in pi. Add a generic fallback-runner role with no model pin so the orchestrator can execute a supplied specialist prompt on an explicitly selected fallback model without granting write tools.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The fallback-runner role is available to pi with inspection-only tools and no pinned model
- [x] #2 The workflow retries a reviewer through fallback-runner only after provider, quota, session, or model unavailability
- [x] #3 The fallback receives the canonical specialist instructions and an explicit alternate model, with no silent inheritance from the parent
- [x] #4 Automated or executable verification demonstrates that the fallback-runner model override is honored
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add a generic inspection-only `fallback-runner` agent definition with no model pin, and install the same role in every supported harness.
2. Teach model assignment that this one role is intentionally dynamic while preserving pins for the five specialist agents.
3. Update the core workflow and README: retry only provider, quota, session, or model launch failures; pass the failed specialist prompt verbatim; require an explicit alternate model; and disclose the substitution.
4. Extend installer regression coverage for the sixth agent, its read-only boundary, and the absence of a model pin.
5. Install the updated role into Pandino itself, run the installer suite and shell checks, then make a live pi Agent call proving the override is honored.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the sixth product-wide `fallback-runner` from canonical `agents/fallback-runner.md`; all harness translations leave it unpinned and enforce inspection-only boundaries while the five specialists remain pinned. Updated workflow, installer recap, README, and regression coverage. Verified locally with `bash tests/test_install.sh`, shell syntax checks, `git diff --check`, and a live pi invocation on `ollama-cloud/deepseek-v4-flash:0731` that returned `FALLBACK_OVERRIDE_OK`.

Review follow-up: `read_saved_models` now ignores unsupported role keys so a hand-edited `fallback-runner` or other unknown entry cannot become an invalid shell variable or pin the dynamic runner. The regression test covers that path. The trigger criterion now names session unavailability explicitly, matching the original operator problem and the documented workflow.

Reproduce the live override check from Pandino: invoke Agent with `subagent_type="fallback-runner"`, `model="ollama-cloud/deepseek-v4-flash:0731"`, `thinking="minimal"`, `max_turns=1`, and prompt `This is only an executable verification of fallback-runner model selection. Do not inspect files or run commands. Reply with exactly: FALLBACK_OVERRIDE_OK`. Observed result on 2026-08-16: `FALLBACK_OVERRIDE_OK` with zero tool uses.

Docs review follow-up: corrected the task reference to the canonical tracked agent source, removed the stale AGENTS.md line count from README, and updated the Codex writer comment to cover every inspection-only agent. The live override check remains a documented executable verification rather than a portable test because it requires a configured pi provider and an Agent-tool invocation.

Final validation: `bash tests/test_install.sh` passed after all review follow-ups; `bash -n install.sh harnesses.sh models.sh tests/test_install.sh` and `git diff --check` produced no errors. Taste and spec reviewers reported no remaining must-fix or minor implementation findings. Docs-reviewer findings about the canonical reference, stale line count, and inspection-only comment were fixed.

Final-review follow-up: narrowed the documented substitution policy to unavailable reviewers so the inspection-only runner cannot replace the implementer; clarified the installer model recap and README example; kept the runner prompt itself generic for any supplied non-mutating inspection task. Re-ran installer tests, shell syntax, diff check, and dogfood-copy comparison successfully.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added a sixth product-wide `fallback-runner` that Pandino installs unpinned and inspection-only in pi, Claude Code, opencode, and Codex, allowing an unavailable pinned specialist to be rerun on an explicit alternate model with the same canonical instructions. Preserved all five specialist pins and the three saved model roles, hardened hand-edited model config against unknown role keys, and verified the installer suite, shell syntax, diff hygiene, all harness translations, and a live pi override returning `FALLBACK_OVERRIDE_OK`.
<!-- SECTION:FINAL_SUMMARY:END -->
