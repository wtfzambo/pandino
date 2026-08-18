---
id: TASK-8
title: Make negative installer assertions effective
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-18 14:37'
updated_date: '2026-08-18 14:49'
labels: []
dependencies: []
modified_files:
  - tests/test_install.sh
type: bug
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The installer suite uses top-level shell `!` commands as negative assertions under `set -e`. Bash exempts commands in an inverted pipeline from errexit, so those assertions can evaluate false without failing the suite. Replace every affected assertion with explicit propagating control flow while leaving `[ ! ... ]` expressions intact.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Every top-level shell-negated assertion in `tests/test_install.sh` fails explicitly when its forbidden condition is present
- [x] #2 Negative checks for model pins, generated sections, Git visibility, filtered models, and unwanted FINDINGS files remain covered
- [x] #3 No affected top-level `! command` assertion remains in the installer suite
- [x] #4 The full installer suite and shell syntax checks pass after the conversion
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Inventory top-level shell `!` assertions and distinguish them from safe `[ ! ... ]` expressions. 2. Replace each affected assertion with explicit `if command; then` failure control flow and specific diagnostics, without changing tested behavior. 3. Run the full suite, syntax checks, diff hygiene, and representative mutation checks proving forbidden outcomes now fail.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Converted all thirteen affected shell-negated assertions, including the compound bare-install model-pin check, to explicit failing `if` blocks with category-specific diagnostics; safe `[ ! ... ]` expressions remain unchanged. Full installer suite, all tracked shell syntax checks, full-file negation inventory, and diff hygiene pass. Temporary mutations prove Git-visibility, generated fallback pin, and bare-install pin forbidden outcomes now fail with the expected diagnostics.

Per-commit taste and spec re-review confirmed all 13 affected assertions are converted, no shell-negated command remains, and all criteria trace cleanly. The only remaining `!` tokens are safe `[ ! ... ]` test arguments.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Replaced all 13 ineffective shell-negated assertions in the installer suite with explicit failing guards and specific diagnostics, preserving every negative coverage category and safe `[ ! ... ]` tests. The clean suite and shell syntax checks pass, full-file inventory finds no shell-negated assertion, and representative forbidden-output mutations now fail as intended.
<!-- SECTION:FINAL_SUMMARY:END -->
