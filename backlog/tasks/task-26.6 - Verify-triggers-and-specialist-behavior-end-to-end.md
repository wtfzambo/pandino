---
id: TASK-26.6
title: Verify triggers and specialist behavior end to end
status: To Do
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
updated_date: '2026-10-21 16:32'
labels: []
dependencies:
  - TASK-26.5
parent_task_id: TASK-26
type: task
ordinal: 32000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The design depends on agents opening the right playbook when a trigger applies, which pi does not guarantee for advertised skills, and on specialists performing as well as before.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A headless pi probe in a never-pushed worktree of speak-like-you-eat with the branch installed covers session start, a bug fix, writing tests, launching a review and finishing an implementation, and each run opens the expected file
- [ ] #2 bench/agents-variants runs the new instructions once per task, three times where results diverge, with no regression against the current variant
- [ ] #3 Relevant reviewers have reviewed the branch and every must-fix has a disposition
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-10-21, probe evidence for acceptance criterion 1.

Setup. /private/tmp/slye-probe is a git worktree of speak-like-you-eat on the local branch pandino-probe-task26 at commit 3a6fb69, with this branch installed (.pandino/install.json records revision dce075d).

Method. /private/tmp/probe_run.py resets that worktree with git reset --hard plus git clean -fd -e .pi/npm, then runs pi -p --no-session --mode json --model <provider/model> --thinking medium on six Italian prompts (session pickup, fix a config bug, add tests, propose a plan, prepare a review brief, close the session) and records every tool call that mentions .pandino/playbooks/<name>.md, pandino-pickup or pandino-handoff.

Result, in /private/tmp/probe_opus.json. Session pickup opened pandino-pickup/SKILL.md. Config bug fix opened .pandino/playbooks/debugging.md and testing.md. Tests opened testing.md. Plan opened workflow.md, design.md and docs.md. Review brief opened review.md and reviewing.md. Handoff opened pandino-handoff/SKILL.md. Each run opened the file its trigger names and no unrelated playbook.

Reproduce with python3 /private/tmp/probe_run.py <provider/model> /private/tmp/probe_<name>.json. The model of the recorded run is not inside the JSON, only in the file name and in that session's shell history. A second run at 18:27 aborted on a stale .git/worktrees/slye-probe/index.lock and left an empty /private/tmp/probe_sol.json, so a second model is still missing.

Still open for this criterion, a second model and the operator's decision on whether this evidence passes. Criterion 2 needs an agents-variants variant for the split layout, because bench/agents-variants/variants/current.md still holds an older AGENTS.md of 2,734 words and no playbooks. Criterion 3 needs the review round.
<!-- SECTION:NOTES:END -->
