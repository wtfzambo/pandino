---
id: TASK-2
title: Fix editor picker exit and ignore local pi packages
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-05 16:13'
updated_date: '2026-08-05 16:18'
labels: []
dependencies: []
modified_files:
  - install.sh
  - tests/test_install.sh
type: bug
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The interactive installer exits immediately after confirming only pi because `set -e` treats the final false selector test as the function status. pi’s downloaded project-local npm packages should also stay out of Git while its shareable agents, skills, and settings remain trackable.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Confirming only pi in the editor picker continues through installation
- [x] #2 Non-interactive picker fallback also succeeds when only pi is available
- [x] #3 Shareable `.pi/agents`, `.pi/skills`, and `.pi/settings.json` remain trackable while pi runtime dependencies stay ignored
- [x] #4 Installer regression tests pass
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Make selector accumulation return success regardless of unselected trailing options. 2. Add `.pi/npm/` idempotently to target Git ignore rules. 3. Add regression coverage for interactive and non-interactive selection, Git ignore behavior, and run the installer tests.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Root cause: `pick_many` inherited the false status of its final unselected option under `set -e`; explicit successful returns fix both terminal and fallback paths. Only `.pi/npm/` is ignored, and only when pi is selected; `.pi/agents`, `.pi/skills`, and `.pi/settings.json` remain shareable. Validation: `bash -n install.sh tests/test_install.sh`, `git diff --check`, and `bash tests/test_install.sh` all pass. The regression suite drives the real picker through a pseudo-terminal with only pi selected and verifies Git ignore behavior and idempotence. Taste/spec reviews were performed locally because this harness exposes no subagent delegation tool; they removed unrequested `.pandino/` ignoring and scoped the pi rule to pi installs.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed the editor picker abort by making `pick_many` return success after collecting selections. Added an idempotent `.pi/npm/` ignore rule for pi installs while preserving trackable pi configuration. Verified interactive and non-interactive pi-only installs plus the full installer test suite.
<!-- SECTION:FINAL_SUMMARY:END -->
