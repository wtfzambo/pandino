---
id: TASK-7
title: Prevent duplicate pi npm ignore rules
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-17 20:22'
updated_date: '2026-08-17 20:33'
labels: []
dependencies: []
modified_files:
  - install.sh
  - tests/test_install.sh
type: bug
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Re-running Pandino can append `.pi/npm/` repeatedly when `.pi/npm/.gitignore` is tracked, because `git check-ignore` suppresses matches for tracked paths unless index state is ignored. Make the update idempotent without relying on an exact root `.gitignore` line.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A repository with a tracked `.pi/npm/.gitignore` receives no redundant root ignore rule on repeated installs
- [x] #2 A repository that does not ignore `.pi/npm/` still receives exactly one root ignore rule
- [x] #3 Existing broader ignore rules such as `.pi/` remain respected without adding a narrower rule
- [x] #4 The installer regression suite covers the tracked nested ignore case and repeated execution
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Make the existing Git ignore probe evaluate ignore patterns independently of tracked index state. 2. Extend the installer regression fixture with a tracked nested `.pi/npm/.gitignore` and repeated installs, while preserving the existing broader-rule behavior. 3. Run the installer suite, shell syntax checks, and diff hygiene checks.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the ignore probe with `git check-ignore --no-index` so tracked nested files do not suppress applicable ignore-pattern matches. Added regression fixtures for a tracked `.pi/npm/.gitignore`, repeated installs, a broader `.pi/` rule, and the existing no-rule path. Validation: `bash tests/test_install.sh` passed; shell syntax and `git diff --check` were clean.

Reviewer follow-up pinned the regression precondition explicitly: ordinary `git check-ignore` fails for the tracked nested fixture while `--no-index` succeeds. The broader `.pi/` fixture now also runs twice. Final taste and spec reviews reported no findings.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Made Pi npm ignore setup idempotent by evaluating Git ignore patterns with `--no-index`, so tracked nested ignore files no longer cause duplicate root rules. Added repeated-install regressions for tracked nested ignores, no existing rule, and broader `.pi/` rules; verified with the full installer suite, shell syntax checks, and diff hygiene.
<!-- SECTION:FINAL_SUMMARY:END -->
