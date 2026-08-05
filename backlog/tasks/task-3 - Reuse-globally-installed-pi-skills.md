---
id: TASK-3
title: Reuse globally installed pi skills
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-05 16:45'
updated_date: '2026-08-05 16:48'
labels: []
dependencies: []
modified_files:
  - install.sh
  - tests/test_install.sh
  - README.md
type: enhancement
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pandino currently downloads local copies of grilling and i-have-adhd even when pi already discovers those skills globally. The installer should reuse global copies and avoid duplicate project files.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A global grilling skill prevents `.pi/skills/grilling` from being created
- [x] #2 A global i-have-adhd skill prevents `.pi/skills/i-have-adhd` from being created even when the add-on is accepted
- [x] #3 Without global copies, accepted skills are still installed locally as before
- [x] #4 Installer output and documentation distinguish reused global skills from local installs
- [x] #5 Installer regression tests pass
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Detect each known skill in pi’s standard global locations. 2. Skip only that skill’s local download while keeping the existing local fallback. 3. Keep recap and README claims accurate. 4. Add regression coverage for global and local cases and run the installer checks.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented direct checks for grilling and i-have-adhd in pi’s standard global skill locations (`~/.pi/agent/skills` and `~/.agents/skills`). Global i-have-adhd skips the now-irrelevant prompt; global skills are labeled in the recap. Local fallback behavior remains unchanged. Tests isolate HOME, verify local installs with no globals, then verify that globals in both supported roots create no project skill directories. README claims were updated. Validation: `bash -n install.sh tests/test_install.sh`, `git diff --check`, and `bash tests/test_install.sh` pass. Taste/spec reviews were performed locally because this harness exposes no subagent delegation tool; no remaining findings.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Pandino now reuses global grilling and i-have-adhd skills instead of duplicating them per project, while preserving local installation when globals are absent. Output and README distinguish both cases; the full installer regression suite passes.
<!-- SECTION:FINAL_SUMMARY:END -->
