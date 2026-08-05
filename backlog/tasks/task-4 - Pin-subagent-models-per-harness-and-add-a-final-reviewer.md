---
id: TASK-4
title: Pin subagent models per harness and add a final reviewer
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-05 20:26'
updated_date: '2026-08-05 20:56'
labels: []
dependencies: []
modified_files:
  - install.sh
  - harnesses.sh
  - tests/test_install.sh
  - README.md
type: feature
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Agents ship model suggestions in prose only, so every harness lets the orchestrator spawn subagents on its own model. That defeats the point of a separate reviewer. Pandino should assign a real model per role and harness, add a stronger final-reviewer role for the whole-branch review before a merge, and never fall back silently to the parent model.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Each installed agent file carries a real model pin in its harness native format
- [x] #2 A fourth agent, final-reviewer, is installed alongside the existing three
- [x] #3 Model choices come from the models each harness actually reports as available
- [x] #4 A missing first-choice model resolves to a curated fallback and the substitution is visible to the user
- [x] #5 When no recommended model resolves, the installer asks about that one cell instead of restarting selection
- [x] #6 Choices persist in `.pandino/models.json` and are reused on later runs
- [x] #7 Interactive install shows one combined matrix with accept and customize, not one picker per harness
- [x] #8 Installer regression tests cover pinning, fallback, persistence, and the final-reviewer role
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add the final-reviewer agent definition. 2. Build per-harness catalog reads and curated per-role preference lists. 3. Resolve and persist assignments in `.pandino/models.json`. 4. Emit native pins through the harness writers. 5. Add the combined matrix UI with accept/customize and targeted prompts. 6. Cover it with regression tests and update the docs.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Model pins are resolved per harness from live catalogues: `pi --list-models`, `opencode models`, Codex `models_cache.json`, and Claude Code subscription aliases. One preference list per role serves all four because a preference is matched on its bare id. Both per-commit reviewers share the reviewer model; only the new final-reviewer gets the expensive one, following the NOTES.md benchmarks where Opus is noisiest on clean diffs. pi now goes through the same translation path as the other three so it can carry a pin, and a file differing from the kit only by that line is treated as Pandino updating its own output rather than a conflict to stage. Substitution notes are limited to multi-provider catalogues, since Claude aliases and Codex slugs were never going to carry a cross-provider first choice. Found and fixed two pre-existing bugs while driving the picker under a real pty: `read -t 0.1` is rejected by bash 3.2, which macOS still ships, so arrow keys never worked there; and the picker RETURN trap outlived its function, dereferencing a local that was gone. Verified: `bash tests/test_install.sh`, `bash -n` on all four scripts, `git diff --check`, plus manual installs into scratch repos under both bash 5.3 and system bash 3.2, interactive and non-interactive, including the customiser. Taste and spec review were performed in-session against the agent definitions; this harness exposes no subagent delegation tool.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Each installed agent now carries a real model pin in its harness native format, resolved from the models that harness actually reports, with curated fallbacks and visible substitutions. Added the final-reviewer role for the whole-branch pass on the strongest available model, persisted the assignment in .pandino/models.json where hand edits win, and replaced the four-pickers-in-a-row idea with one combined matrix offering accept or customize. Verified with the installer suite plus manual runs under bash 5.3 and bash 3.2.
<!-- SECTION:FINAL_SUMMARY:END -->
