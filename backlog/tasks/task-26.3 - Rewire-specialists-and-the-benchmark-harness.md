---
id: TASK-26.3
title: Rewire specialists and the benchmark harness
status: Done
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
updated_date: '2026-10-21 16:10'
labels: []
dependencies:
  - TASK-26.2
parent_task_id: TASK-26
type: task
ordinal: 29000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The seven agents read `AGENTS.md` and cite its sections by name; those sections move to playbooks. Benchmark runs seed only `AGENTS.md` into the work directory, so reviewers would not find the playbooks.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Each agent file names the core plus the playbooks its role shares, and no reference points at a moved section
- [x] #2 Benchmark prompt copies match the agent files and benchmark work directories contain the playbooks
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Repoint each agent file from AGENTS.md sections to the core plus its playbooks; taste reviewer checks the new comment rule; docs reviewer drops codebase documentation.
2. Regenerate bench/review/prompts copies with the documented awk command.
3. Make bench run_one.sh scripts seed .pandino/playbooks into each work dir next to AGENTS.md.
4. Verify: grep for stale section references, prompt-copy check, tests/test_review_bench.sh.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Applied with the operator's 2026-10-20 review round: review.md (orchestrator) and reviewing.md (reviewers, fixed report format with Coverage and Turns lines, 2-minute command timeouts, one diagnosed retry) replace the single review playbook. All seven agents now read AGENTS.md plus their role playbooks; shared severity and label rules moved to reviewing.md; each reviewer names a role field. Design's 'implement against the sketch' moved to implementer.md. bench/review/prompts regenerated; every run_one.sh seeds .pandino/playbooks next to AGENTS.md. tests/test_review_bench.sh passes with a timeout shim (macOS lacks coreutils timeout; the failure is pre-existing on main). Note: the reviewer report format changed, so the benchmark rerun in TASK-26.6 is the regression check.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Repointed all seven agent definitions from AGENTS.md sections to the core plus role playbooks, split review into review.md and reviewing.md with a shared report format, regenerated benchmark prompt copies and seeded playbooks into every benchmark work directory. Verified with a grep for stale section references (none), the prompt-copy check and tests/test_review_bench.sh passing.
<!-- SECTION:FINAL_SUMMARY:END -->
