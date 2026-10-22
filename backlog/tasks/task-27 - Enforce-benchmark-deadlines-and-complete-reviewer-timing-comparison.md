---
id: TASK-27
title: Enforce benchmark deadlines and complete reviewer timing comparison
status: In Progress
assignee:
  - '@zambo'
created_date: '2026-10-22 14:36'
updated_date: '2026-10-22 15:00'
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
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Regression-first evidence: existing review smoke failed without the absent timeout executable. Added tests for command output/status, hung process trees, and SIGTERM cleanup. Source inspection found Pi bash uses detached process groups; a new detached-child regression failed under group-only cleanup and now passes with descendant group discovery before termination. Four tests and the full review smoke pass without the shim. Stopped orphan benchmark process groups 13844 and 16421 from the interrupted run. Limits cover descendants still attached in the parent tree at cleanup, including Pi tool groups; a process that deliberately double-forks and reparents before cleanup is outside this guarantee. Reviewer comparison resumes only missing cells and one third round, at one active review per provider.

Implemented deadline repair in commit referenced by git history. Five regression tests now cover output/status, ordinary process-tree timeout, cancellation, detached tool timeout, and cancellation where the parent exits before an uncooperative detached child. Review smoke and installer tests pass without PATH shims. Self-reviewed scope and evidence against reviewer definitions because this harness exposes no specialist delegation tool. Full guarantee is POSIX attached descendant groups, not already-reparented daemons; Linux remains untested in this macOS session. Timing completion is supervised with a 30-minute overall cap and incremental progress in /tmp/pandino-speed-progress.log. The judge is rate-limited (HTTP 429); completed contestant reviews are preserved and will be inspected manually instead of rerunning contestants solely for judge failure.

Comparison completed on 2026-10-22. Report: bench/review/results/sol61-flash41-timing.md. All 72 logical reviews completed (12 cases x 2 models x 3 samples), plus two interrupted original Flash attempts preserved as incomplete rather than normal latency samples. The continuation took about 16 minutes with two concurrent providers and no remaining benchmark processes. The third, low-concurrency round reverses the earlier ranking: approximate transcript wall median Sol 61s versus Flash 43s, means 61s versus 50s, ranges 31-95s versus 7-198s. Flash faster in 11/12 paired cases in this round. Only one full low-concurrency round exists; pooling it with the two high-concurrency rounds would confound the comparison. Judge 429 failures leave 12 completed reviews unscored; raw reviews retained and selected quality findings manually checked. Sol identifies a valid docstring violation that the clean oracle penalizes. A temporary-copy TypeScript probe confirmed baseline exit 0 and save-before-charge mutation exit 124 after 3s; Flash correctly identified the unbounded deferred waits. No claim of equivalent accuracy or a routing winner. Future benchmark redesign is TASK-28. Pstack role files checked against upstream eb4db2b; same relevant content as local checkout. Writer recommendations remain Sol 6.1 medium, reviewer routing unchanged. Removed /tmp/tshim/timeout.

Final local checks pass: five deadline regressions, full review benchmark smoke, installer suite, diff whitespace check and report-link validation. AC #1 retains its Linux verification gap because this session only ran macOS. Main implementation and reviewer test/evidence inspection were performed directly under the role definitions because no specialist delegation tool is exposed. No reviewer defaults were changed, and no merge or push was performed.
<!-- SECTION:NOTES:END -->
