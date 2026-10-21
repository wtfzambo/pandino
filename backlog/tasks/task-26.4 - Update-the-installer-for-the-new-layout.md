---
id: TASK-26.4
title: Update the installer for the new layout
status: Done
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
updated_date: '2026-10-21 16:16'
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
- [x] #1 A fresh install requires the backlog command, asks only which editors to set up, and writes the core, the playbooks and the continuity skills where each selected editor finds them
- [x] #2 Updating an existing install removes only the marked Pandino sections and the snippets folder, preserves project-specific rules, and stages a differing core for manual merge
- [x] #3 Re-running the installer overwrites changed playbooks and leaves a global grilling skill without a local copy
- [x] #4 tests/test_install.sh covers these behaviors and passes
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Claude Code reads project skills only from .claude/skills (open feature request anthropics/claude-code#16345 for .agents/skills), so the skills are also copied there when Claude Code is selected. OpenCode, Codex and pi read .agents/skills. The installer's core comparison now ends at the project marker; a fresh AGENTS.md gets the marker and an empty Corrections table. New tests: Backlog missing stops before writing; legacy install loses appended sections and snippets but keeps project rules and Backlog's block; re-run restores edited playbooks and skills; Claude skills copy under --yes.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Installer now requires Backlog.md, asks only for editors, installs .pandino/playbooks and the pandino-pickup/handoff skills, removes earlier appended sections and snippets on update, and stages a differing core in .pandino/merge/. Verified with tests/test_install.sh (PASS) and a manual fresh install.
<!-- SECTION:FINAL_SUMMARY:END -->
