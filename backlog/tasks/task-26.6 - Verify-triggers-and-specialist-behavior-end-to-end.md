---
id: TASK-26.6
title: Verify triggers and specialist behavior end to end
status: To Do
assignee:
  - '@zambo'
created_date: '2026-10-20 16:04'
updated_date: '2026-10-21 22:30'
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
- [x] #1 A headless pi probe in a never-pushed worktree of speak-like-you-eat with the branch installed covers session start, a bug fix, writing tests, launching a review and finishing an implementation, and each run opens the expected file
- [x] #2 bench/agents-variants runs the new instructions once per task, three times where results diverge, with no regression against the current variant
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

2026-10-21, second-model probe evidence, appended after the first probe note.

/private/tmp/probe_ds.json, written at 18:32, holds a complete six-prompt run of /private/tmp/probe_run.py; the model appears only in the file name, deepseek-v4.1-flash. Tool calls against the watched files, per prompt: session pickup opened pandino-pickup/SKILL.md; config bug fix opened none; add tests opened .pandino/playbooks/testing.md; plan opened pandino-pickup/SKILL.md, .pandino/playbooks/workflow.md and .pandino/playbooks/design.md; review brief opened .pandino/playbooks/review.md and .pandino/playbooks/reviewing.md; handoff opened pandino-handoff/SKILL.md plus mentions of pandino-pickup and .pandino/playbooks/debugging.md.

Against /private/tmp/probe_opus.json this run differs in two places: the plan prompt did not open docs.md, and the config bug fix opened no playbook where the first model opened debugging.md and testing.md. The bug fix is the trigger the criterion depends on most, so whether a run that opens nothing there passes criterion 1 is the operator's decision.

Both result files keep only the last 600 characters of each final answer and no model name, so they are reproducible only by file name and shell history. Copy them out of /private/tmp before it is cleared.

2026-10-21 probe: worktree /tmp/slye-probe of speak-like-you-eat (branch pandino-probe-task26, local only, never pushed), Pandino installed from this branch over the old install (installer removed the three appended sections and snippets, staged core and agents; merged by hand). Six headless prompts per model (pickup, bug fix, tests, plan, review brief, end of session), opened files read from tool calls:
- anthropic/claude-opus-5-5: 6/6 opened the expected file.
- openai/gpt-6-sol: 6/6, and opened pandino-pickup first on every prompt.
- ollama-cloud/deepseek-v4.1-flash: 5/6; the bug-fix prompt opened no playbook, and the end-of-session prompt read nearly every playbook.

Benchmark (bench/agents-variants, production models deepseek-v4.1-flash for taste/spec, gpt-6-sol for test/implementer; pre-task26 = main's AGENTS.md without playbooks, task26 = this branch):
- taste-defects 4/4 vs 4/4; spec-defects 4/4 vs 4/4; test-python-defects 4/5 vs 4/5 (fp 1 vs 0).
- adversarial-config (implementer must stop): pre 3/3, task26 3/4. The one failure was the zero-diff check counting the seeded .pandino/ playbooks as a change; the transcript shows the implementer stopped correctly. check.sh now excludes .pandino; rerun r1b passes.
- taste-clean false positives: pre 0,1,0; task26 4,6,5. taste-negations false positives: pre 0,2,1; task26 3,5,2. All planted defects still found.

Cause of the false-positive increase, from the reviews: (1) the new comment rule makes the fixtures' 'intent' comments ('Kept short so slugs stay readable', 'count total calls, not retries') violations, so reviewers flag what the fixtures call clean; (2) the reviewers raise more minor findings and some real-but-unplanted ones (unique_slug can return 61 characters past MAX_SLUG_LENGTH). AC #3 (no regression) is not met as stated; needs an operator decision.

2026-10-21 rerun after operator decisions (product reasons go to specs; fixtures repaired; judge counts real defects as true findings; runs use --no-context-files to match pi-subagents, which strips AGENTS.md from specialists). Both variants on the same repaired fixtures, production models, runs rv1-rv3:
- taste-clean false positives: pre 0,3,2; task26 0,1,2.
- taste-negations: 3/3 found in all runs; false positives pre 2,1,3; task26 3,1,1.
- taste-defects 4/4 both; spec-defects 4/4 both (fp 1 vs 0); test-python-defects 4/5 both; adversarial-config pass both.
No regression. Without context files every run of both variants opened AGENTS.md itself, and every task26 run also opened its role playbooks (reviewing.md plus design.md or testing.md), including deepseek-v4.1-flash. Operator rejected pasting playbooks into agent files: each playbook is shared by several roles, so it stays a separate file the agent reads.

2026-10-21 branch reviews (taste and spec on deepseek-v4.1-flash, test on gpt-6-sol; headless runs with the agent bodies, --no-context-files). Cost: taste 1 min / 23 turns over its 20 budget (reported 24 of 40, a miscount), spec 2 min / 17 turns, test 1 min / 10 turns; no timed-out commands.

Fixed in c0773b6:
- taste must-fix 1 and test must-fix 1: Backlog dir present but command missing reported 'unchanged' and skipped Backlog's guidelines. The command is now required on every run; test added.
- taste must-fix 2: the Backlog check ran after the kit download, before the cleanup trap. Moved before the download.
- taste minor: unused heading tag parameters removed; the blank-line trim is one named helper. The variant snapshot task26.md is refreshed and bench/README says variants are snapshots.
- spec minor: 'one question' wording now names the model confirmation; Definition of done points to testing.md; old appended sections now end at the next level-two heading, so project text after them survives (test added).
- test minor: benchmark smoke test asserts --no-context-files.

Rejected, with reasons:
- taste minor, install.sh comments: the Backlog rationale comment was removed; the remaining comments describe installer mechanics (trim, marker boundaries), which are this repository's code, and the comment rule targets workaround excuses and product reasons.
- test must-fix 2 (stale local grilling copy when a global one appears later): behavior predates the branch and TASK-26 did not change it; out of scope.

Recorded for the operator: spec must-fix on the core word cap. The core above the project marker is 1,322 words against 'about 1,100'; the growth came from the operator-requested rules after the 1,205 count (Corrections table rule, project playbooks, ID wording, comment routing, testing pointer). Total 7,844 words (+28% vs 6,116; operator accepted +24% and called the difference small). The inventory row N4 (named alternative) was superseded by the operator on 2026-10-21 and parked in DRAFT-1; G3 and SC4 changes were also operator decisions.
<!-- SECTION:NOTES:END -->
