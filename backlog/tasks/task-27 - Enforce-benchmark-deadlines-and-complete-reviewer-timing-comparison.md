---
id: TASK-27
title: Enforce benchmark deadlines and complete reviewer timing comparison
status: In Progress
assignee:
  - '@zambo'
created_date: '2026-10-22 14:36'
updated_date: '2026-10-22 17:19'
labels:
  - benchmark
dependencies: []
priority: high
type: bug
ordinal: 33000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The reviewer timing comparison stalled for almost three hours when two TypeScript probes hung. The benchmark depended on an absent timeout executable, and a temporary pass-through replacement silently removed the deadline. The operator authorized fixing benchmark timeouts, completing the Sol 6.1 versus DeepSeek V4.1 Flash comparison, and exploring model routing without changing reviewer defaults yet. Keep cross-harness runner migration in the paused deadline investigation separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A benchmark review deadline terminates the reviewer and its ordinary descendant processes on macOS and Linux, preserving timeout as a failed incomplete run.
- [x] #2 Regression checks demonstrate normal completion, timeout of a hung process tree, and cancellation cleanup without paid model calls.
- [x] #3 Complete three repetitions per review case for both models with bounded concurrency and report duration, quality, and failures with measurement limitations.
- [x] #4 Explain current implementer routing and pstack model diversity using repository sources; leave reviewer defaults for the operator decision.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add bench/run_with_timeout.py with CLI seconds command args, using a new POSIX process session and a deadline; preserve command status, return 124 on timeout, terminate then kill the process group on timeout/cancellation. Call sites: python3 "$bench_dir/../run_with_timeout.py" 600 pi ... in all three benchmark runners. No extra package or PATH timeout dependency.
2. Write and run failing regression tests for process-tree timeout and cancellation before implementing the wrapper. Update the existing review smoke harness to copy the shared wrapper.
3. Verify smoke tests and wrapper regressions locally. Remove reliance on the temporary shim.
4. Resume only missing/failed timing cells, three repetitions per model/case, one active review per provider, real deadlines, incremental progress. Compare paired timing and quality; mark timeouts separately.
5. Inspect pstack source for model-family policy and present routing options. Do not change reviewer routing or merge in this slice.

6. Operator requested a focused current-model test-reviewer benchmark on 2026-10-22. Reuse the completed low-concurrency sp3 test cases and add two low-concurrency repetitions per model on all seven test-review cases (28 new reviews, 42 total). Freeze current cases/prompts, high effort for both, one active review per provider, real deadlines and monitored progress. Independently adjudicate findings against actual code/contracts, treating real unplanted issues as valid; report per-case recall, false alarms, severity and failures instead of trusting stale clean labels. Leave routing unchanged during measurement.

7. Operator requested the same focused test-review benchmark with openai/gpt-6-astra instead of Sol on 2026-10-22. Run seven unchanged cases three times at high, one active review, with existing 600s review deadlines and a 2100s overall supervisor. Reuse historical Flash/Sol evidence without rerunning them. Use current Opus 5.5 low judge as advisory and apply the prior report's product-level adjudication consistently; distinguish judge versions and historical timing references. Freeze inputs, monitor incremental progress, retain failures without replacements, report results and leave routing unchanged.

8. Operator requested Haiku as test reviewer on 2026-10-22. Use available anthropic/claude-haiku-5-5 at high on the same seven cases three times, one active review, 600s review and 2100s overall deadlines. Retain historical Sol/Flash/Astra results without new calls, keep Opus 5.5 low as advisory judge, and explicitly note judge/candidate family overlap. Freeze inputs, inspect every completed review with the established product-level rubric, preserve failures without replacements, and leave routing unchanged.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Regression-first evidence: existing review smoke failed without the absent timeout executable. Added tests for command output/status, hung process trees, and SIGTERM cleanup. Source inspection found Pi bash uses detached process groups; a new detached-child regression failed under group-only cleanup and now passes with descendant group discovery before termination. Four tests and the full review smoke pass without the shim. Stopped orphan benchmark process groups 13844 and 16421 from the interrupted run. Limits cover descendants still attached in the parent tree at cleanup, including Pi tool groups; a process that deliberately double-forks and reparents before cleanup is outside this guarantee. Reviewer comparison resumes only missing cells and one third round, at one active review per provider.

Implemented deadline repair in commit referenced by git history. Five regression tests now cover output/status, ordinary process-tree timeout, cancellation, detached tool timeout, and cancellation where the parent exits before an uncooperative detached child. Review smoke and installer tests pass without PATH shims. Self-reviewed scope and evidence against reviewer definitions because this harness exposes no specialist delegation tool. Full guarantee is POSIX attached descendant groups, not already-reparented daemons; Linux remains untested in this macOS session. Timing completion is supervised with a 30-minute overall cap and incremental progress in /tmp/pandino-speed-progress.log. The judge is rate-limited (HTTP 429); completed contestant reviews are preserved and will be inspected manually instead of rerunning contestants solely for judge failure.

Comparison completed on 2026-10-22. Report: bench/review/results/sol61-flash41-timing.md. All 72 logical reviews completed (12 cases x 2 models x 3 samples), plus two interrupted original Flash attempts preserved as incomplete rather than normal latency samples. The continuation took about 16 minutes with two concurrent providers and no remaining benchmark processes. The third, low-concurrency round reverses the earlier ranking: approximate transcript wall median Sol 61s versus Flash 43s, means 61s versus 50s, ranges 31-95s versus 7-198s. Flash faster in 11/12 paired cases in this round. Only one full low-concurrency round exists; pooling it with the two high-concurrency rounds would confound the comparison. Judge 429 failures leave 12 completed reviews unscored; raw reviews retained and selected quality findings manually checked. Sol identifies a valid docstring violation that the clean oracle penalizes. A temporary-copy TypeScript probe confirmed baseline exit 0 and save-before-charge mutation exit 124 after 3s; Flash correctly identified the unbounded deferred waits. No claim of equivalent accuracy or a routing winner. Future benchmark redesign is TASK-28. Pstack role files checked against upstream eb4db2b; same relevant content as local checkout. Writer recommendations remain Sol 6.1 medium, reviewer routing unchanged. Removed /tmp/tshim/timeout.

Final local checks pass: five deadline regressions, full review benchmark smoke, installer suite, diff whitespace check and report-link validation. AC #1 retains its Linux verification gap because this session only ran macOS. Main implementation and reviewer test/evidence inspection were performed directly under the role definitions because no specialist delegation tool is exposed. No reviewer defaults were changed, and no merge or push was performed.

Focused current-model test-review comparison completed on 2026-10-22. Report: bench/review/results/sol61-flash41-test-review.md. Reused sp3 and added tr4/tr5, both models high, one active review per provider; 65 input hashes unchanged. Of 42 total attempts, Sol completed 21/21 and Flash 20/21. Flash TypeScript-clean tr5 timed out at 600.1s with exit 124; its unbounded mutation command and descendants were stopped, no retry, no remaining benchmark processes. New launch took about 25 minutes. Product-level seeded matches are Sol 39/45 and Flash 42/45; the difference is one negative scheduling gap repeated three times. Median completed review time is 65s versus 46s; completed means 66s versus 62s, but including the failed attempt gives 66s versus 87s. These are approximate transcript wall times excluding judging, not billing costs or statistical proof. Directly inspected all 41 completed reviews and verified at least six erroneous minor Flash test-removal recommendations through independent counterexamples. Found no similarly clear erroneous Sol recommendation. Raw judge false-positive counts remain advisory: the clean TypeScript fixture has a real hang and lacks error-cause protection required by AGENTS.md. Sol's tr4 cause-preservation finding is valid despite its automatic penalty. Flash repeatedly performed file-changing temporary mutations despite the read-only role; this caused the failed attempt. README now scopes historical versus current adjudication; FINDINGS records the disproved integer-equality/type-guard redundancy hypothesis. Checks: 96 report links resolve, all 42 attempt cells present, exactly 27 new scored CSV rows and one failed new attempt, frozen hashes unchanged, whitespace clean, no active benchmark processes. No specialist delegation tool is exposed; report, evidence and documentation were checked directly. Routing, fixtures, prompts, downstream installs and merge/push remain unchanged; Linux deadline verification remains open.

Astra follow-up requested by the operator completed on 2026-10-22. Report: bench/review/results/astra6-flash41-test-review.md. Ran openai/gpt-6-astra high on all seven unchanged test-review cases three times, one active review, with 600s review and 2100s overall deadlines. All 21 attempts completed with no timeout or replacement; launch took about 22 minutes including Opus 5.5 low judging. Retained existing Sol/Flash evidence without new contestant calls. All 66 frozen inputs unchanged at source revision 17fab63. Astra matched Sol's product-level recall in every round: notification 4/5, Python 4/5, TypeScript 5/5, total 39/45; all 18 minor groups found. The same missing negative public scheduling assertion and successful member save/send ordering evidence were omitted each time. Directly inspected all 21 reviews; no clearly incorrect recommendations observed, no native edit/write calls or file-changing mutation execution observed. All TypeScript clean reviews also missed the known unbounded-wait and error-cause protection concerns, so quiet controls are not proof of complete correctness. Approximate transcript wall timing excluding judges: median 67s, mean 60s, range 25-87s. Historical references are Sol median 65s/mean66s and Flash median46s/complete mean62s, or 87s including its timeout. These are separate launches with changed judge and concurrency, not a controlled speed ranking. Opus outputs agree with direct seeded-match inspection; old Fable scores remain untouched. Checks pass: 49 report links, 21 new high-effort/status-0 CSV rows, matching totals, frozen hashes, whitespace, and no active benchmark processes. Five deadline regressions passed before launch. No specialist delegation tool is exposed; report/evidence/docs review was performed directly. No routing, prompt, fixture, downstream install, merge or push changes; Linux verification remains open. This sample provides no quality advantage for adopting Astra instead of Sol.

Haiku 5.5 follow-up on 2026-10-22 was safety-stopped, not completed. Seven hr1 reviews completed with 12/15 seeded matches (notification 4/5, Python 3/5, TypeScript 5/5); the eighth attempt, TypeScript-clean hr2, was interrupted by the orchestrator around 19:01 CEST. The other 13 planned attempts were never launched, and there were no replacements or further paid calls. Model was anthropic/claude-haiku-5-5 high; advisory judge Opus 5.5 low shares its family. Historical Sol/Flash/Astra artifacts were reused without calls.

Stop evidence: after a 120-second tool timeout on an executed mutation, Haiku issued pkill by generic test command text and a deletion loop over /tmp/mut.*. Tool call toolu_01X2nb7qHx13gczREwuYZMzt returned exit_code 0. This was executed beyond an exclusively owned namespace, despite the read-only role. The verified supervisor PID 44574 received SIGTERM; process-table checks found no remaining matching benchmark processes. All 66 frozen inputs remained unchanged, but no prior /tmp inventory exists to establish unrelated cleanup impact. Further Haiku attempts remain canceled pending separately approved containment. No containment implementation or broader harness changes were made.

Report bench/review/results/haiku55-test-review.md preserves all 21 planned outcomes, seven reviews/judgments, the unsafe-command/result excerpt and intervention distinction. At least three completed reviews contain demonstrated harmful deletion advice, counting affected reviews once: Python-defect integer guards, Python-clean integer guards and TypeScript-clean deferred-payment coverage. Local counterprobes confirmed a 3000-cent production price still passes all 15 Python defect tests, and result-only float leakage passes after Haiku's proposed guards are removed. The remaining counterexamples reuse the prior verified probes on identical fixtures. Completed-review median 75 seconds and mean 63 seconds exclude judging; no general speed/cost claim.

README now states the actual host-access boundary; FINDINGS records that a temp repo and prompt do not contain bash. Deadline regressions passed 5/5 after the stop. No routing, downstream installation, merge or push changed. Specialist delegation is unavailable; evidence and documentation review are performed directly. Linux runtime evidence for AC #1 is still missing.

Direct documentation review completed because specialist delegation is unavailable.

## Verdict
clean

## Findings
### must-fix
- none
### minor
- none in the final state. Clarified that historical Flash notification sp3 was manually scored after a judge quota failure; no new judging was performed. Removed duplicated future-work status from the README and kept the durable finding focused on its practical safety consequence.

## Good
- The report preserves the operator-aborted attempt and all unstarted cases, with the executed cleanup evidence and external-impact uncertainty.
- Scored matches, harmful-deletion lower bounds and advisory false positives remain separate.

## Coverage
- Checked: all seven completed reviews, role and documentation guidance, current routing specification, 26 report links, all first-round seeded comparator scores, seven new high-effort CSV rows and raw judgments, 66 frozen input hashes, local counterprobes, five deadline regressions and whitespace/process checks.
- Unverified: the other 14 Haiku outcomes, which were interrupted or unstarted; unrelated cleanup impact without a prior namespace inventory; Linux execution. These limits are explicit rather than inferred as successful outcomes.
- Turns: 5 of 20 for the direct review, followed by local prose corrections; timed-out reviewer checks: none.
<!-- SECTION:NOTES:END -->
