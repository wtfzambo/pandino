---
id: TASK-26.4
title: Update the installer for the new layout
status: To Do
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
labels: []
dependencies:
  - TASK-26.2
parent_task_id: TASK-26
type: task
ordinal: 30000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The installer still appends snippets, asks about Backlog, parallel notes and i-have-adhd, and knows nothing about playbooks or the continuity skills.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A fresh install requires the backlog command, asks only which editors to set up, and writes the core, the playbooks and the continuity skills where each selected editor finds them
- [ ] #2 Updating an existing install removes only the marked Pandino sections and the snippets folder, preserves project-specific rules, and stages a differing core for manual merge
- [ ] #3 Re-running the installer overwrites changed playbooks and leaves a global grilling skill without a local copy
- [ ] #4 tests/test_install.sh covers these behaviors and passes
<!-- AC:END -->
