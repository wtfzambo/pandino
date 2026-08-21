---
id: TASK-9
title: Add evidence-based test review workflow
status: Done
assignee:
  - '@wtfzambo'
created_date: '2026-08-19 16:01'
updated_date: '2026-08-21 00:19'
labels: []
dependencies: []
references:
  - 'https://grugbrain.dev/#grug-on-testing'
  - AGENTS.md
  - agents/
  - bench/review/
priority: high
type: feature
ordinal: 9000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make Pandino treat tests as maintained product evidence rather than a coverage quota. Codify a Grug-inspired preference for stable integration cut points, small critical end-to-end suites, focused unit tests, independent oracles, and mutation-minded regression checks. Add a conditional read-only test-reviewer that challenges both missing protection and excessive or ineffective tests. Benchmark the role before choosing its model routing.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The default AGENTS.md explains when unit, integration, and end-to-end tests earn their place and requires each meaningful test to protect an observable promise not already guaranteed by cheaper tooling
- [x] #2 A read-only test-reviewer reviews current diffs for missing protection, false protection, and excessive or brittle tests, proposes concrete mutations without editing files, and has a non-overlapping boundary with spec-reviewer
- [x] #3 The test-reviewer runs conditionally for behavior changes, test changes, test-infrastructure changes, and bug fixes rather than for every documentation-only or trivial diff
- [x] #4 The reviewer benchmark covers planted test defects and clean cases, screens the existing reviewer model set plus MiniMax M3 and dated DeepSeek V4 Pro, and evaluates promising model/thinking-level pairs over repeated runs
- [x] #5 Model routing follows the benchmark evidence; any new saved model role is introduced only when a material quality difference justifies it and is explicitly documented
- [x] #6 Every supported harness installs the test-reviewer with the correct inspection-only boundary and model behavior, while fallback-runner remains unpinned
- [x] #7 README, benchmark notes, installer regression coverage, and authoritative project documentation describe the final workflow consistently
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Establish the durable testing contract and decision record through Backlog CLI, then tighten AGENTS.md around stable integration cut points, small critical end-to-end coverage, focused pure-logic unit tests, independent oracles, cheaper static guarantees, regression-first bug fixes, coarse boundary mocks, and plausible mutations.
2. Add a canonical read-only test-reviewer prompt, narrow spec-reviewer to requirement correctness rather than test quality, and extend the review benchmark with planted missing, false, excessive, provider-fixture, and clean-test cases.
3. Screen the previous ten reviewer candidates plus ollama-cloud/minimax-m3 and ollama-cloud/deepseek-v4-pro:0813 once at high thinking; manually inspect judge verdicts, test lower supported levels for perfect candidates and xhigh only for promising high-level misses, then repeat finalist model/level pairs to three runs.
4. Choose routing from quality, false positives, stability, cost, and latency. Keep the shared reviewer role when it is sufficient; if evidence materially favors a separate test-reviewer role, stop and get explicit approval before adding it.
5. Integrate the benchmarked agent into all four harness outputs, the self-hosted Pi setup, installer assertions, README workflow/counts, NOTES results, and authoritative documentation without pinning fallback-runner.
6. Run focused benchmark checks, the full installer suite, shell syntax and diff hygiene; run taste, spec, and the new test review before each non-trivial commit, then docs review and whole-branch final review.
7. Repair the clean integration benchmark fixture so its test observes the documented save-before-receipt sequence, mutation-check the corrected oracle, and regenerate the affected integration-case evidence before final routing.
8. Add the independently verified missing negative schedule_retry case to test-defects ground truth, rescore existing reviews without rerunning contestants, and resume level/finalist selection from the corrected five-defect oracle.

9. Add mutation-verified pure-Python defect and clean test-review tasks with five must-fix evidence gaps and two minor excess items, then obtain an independent oracle audit before model runs.

10. Add mutation-verified TypeScript defect and clean test-review tasks using Node 24 built-in TypeScript execution and node:test, then obtain an independent oracle audit before model runs.

11. Screen Sol high, Sol medium, dated DeepSeek V4 Flash high, and dated DeepSeek V4 Pro high once across all four language tasks; manually audit every verdict and preserve raw automatic judge output.

12. Repeat only configurations whose first-pass quality can still change routing until finalist language/task combinations have three runs, then compare recall, clean-case precision, stability, latency, and cost before requesting routing approval.

13. Correct the independently discovered Python one-argument API compatibility gap by preserving member=False, add direct regression evidence in both Python fixtures, re-certify the oracle, and regenerate only the stale Python contestant reviews before routing.

14. Add confirmation-level invalid-input/no-side-effect evidence to both Python fixtures after three finalist runs exposed the clean oracle gap; then run an open adversarial oracle audit before regenerating Python artifacts again.

15. Protect the documented runtime int-cent totals and dictionary confirmation result in both Python fixtures within existing behavioral tests, after open mutation audit showed float and non-dict Mapping implementations survived; re-run the open oracle audit before contestant regeneration.

16. Close the remaining open-audit Python gaps with a larger flat-discount case, integrated integer checks on emitted/returned totals, opaque clean repository IDs, and save-failure/no-mail evidence; preserve the defect fixture's intentional ID gap and re-audit before reruns.

17. Replace the redundant four-seat regular-total example with the valid one-seat lower boundary in both Python fixtures, preserving implementation-derived price evidence only in the defect fixture, then run one final oracle audit.

18. Protect both omission mechanics and non-member semantics by parameterizing the one-argument regular-total test at seats 1 and 4; narrow planted booking-ID scoring back to the intended unasserted returned-ID concept rather than string identity/coercion.

19. With operator approval, add a separate test-reviewer model role recommended as openai-codex/gpt-5.6-sol at high thinking, resolved per harness through the existing availability/fallback machinery; then finish harness generation, installer coverage, docs, reviews, commit, and push.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-08-19 slice A: added the evidence-based testing and conditional test-review policy to AGENTS.md; added canonical read-only agents/test-reviewer.md and narrowed spec-reviewer to requested-behavior correctness; added test benchmark prompts/tasks and model+thinking/minor-excess scoring support. The corrected test-defects ground truth has five must-fix gaps: missing 429 regression, Bash top-level ! false protection, implementation-derived schedule delay oracle, invented provider fixture, and missing negative schedule_retry protection. Minor excess covers duplicate type/existence checks and brittle source/copy assertions. test-integration is valid coarse-fake integration coverage; test-no-test is docs-only and requires no new test.

Initial high screening used anthropic/claude-fable-5 as judge. Automatic verdicts were manually audited because the judge was intermittently unreliable; raw judge JSON remains preserved and the manual audit is authoritative.

2026-08-20 integration-fixture correction: repeated Sonnet high reviews exposed that the original test-integration fixture did not observe its documented save-before-receipt sequence. The final fixture uses a shared ordered event log, explicitly documents the returned total, has a tracked direct runner, and is pytest-collectable. All twelve high r1 integration reviews were rerun against the final fixture.

2026-08-20 oracle correction: Sol medium identified a real unlisted gap, not a false positive. A temporary mutation making schedule_retry always return retry=true violates the documented no-retry-for-other-statuses promise while both fixture tests remain green. Routing is paused until all existing defect reviews are rescored against the corrected five-defect oracle and Sol level/finalist runs are complete.

2026-08-20 operator approved the expanded language benchmark: defect plus clean tasks for pure Python and TypeScript, four requested configurations, one full screening run followed by finalist-only repeats. Every planted mutation and both clean oracles must be independently audited before paid contestant runs.

2026-08-20 finalist repeat correction: Sol high r2 found that the supposedly clean Python fixture broke the pre-existing calculate_total(seats) call by requiring member. Treat this as a valid oracle defect, not a false positive; Python artifacts must be regenerated after preserving the default and testing the one-argument path. TypeScript artifacts remain valid.

2026-08-20 second Python oracle correction: Sol high r3 and Sol medium r2/r3 independently found that calculate_total validation tests did not prove confirm_booking validates before repository/mailer side effects. The documented compute-then-save sequence makes this a real clean-fixture gap, not a false positive.

2026-08-20 open Python audit found two additional valid gaps: float/Decimal-like totals compare equal to integer expectations and non-dict mappings satisfy key assertions. Because no static checker runs and the public contracts promise int cents and a dictionary result, add proportionate runtime shape assertions rather than separate type-only tests.

2026-08-20 second open Python audit: min/capped arithmetic, float coercion at confirmation boundaries, string-only repository IDs, and mail-after-save-failure mutations survived. These violate explicit arithmetic/data-flow/sequence promises; address them without standalone type tests or exact exception identity.

2026-08-20 final open-audit blocker: both suites allowed rejecting one seat or charging it as two. The one-seat case protects the positive lower boundary; non-member behavior above the discount threshold remains independently covered by Bea's five-seat confirmation.

2026-08-20 contestant-driven final correction: every Sol repeat identified that member=True as the default survives the one-seat-only compatibility test. This is valid. Also, booking-ID ground truth had become over-compound: with string fixture IDs, str coercion is not a distinct product failure; credit the intended finding when reviewers identify that the repository ID is never asserted.

2026-08-20 operator explicitly approved Sol high as the default test-reviewer recommendation, with per-harness model availability and fallback behavior matching the other specialists. The single-page benchmark authority is bench/review/results/manual-audit.md; NOTES.md will carry the concise product-facing recap and link.

2026-08-20 integration: added the persisted `test` model role with Sol-first per-harness resolution, installed test-reviewer across Pi/Claude/opencode/Codex, kept fallback-runner unpinned, expanded installer/model persistence regression coverage, generated the self-hosted Pi agent, documented the seven-helper workflow and benchmark recap, added decision-2, and ignored `.pytest_cache/`. A regression test now protects non-Ollama `run_one.sh` under Bash nounset after the empty-array failure observed during benchmarking. Full installer, launcher, fixture, syntax, prompt, CSV/artifact, link, and diff checks pass.

Final pre-commit reviews: taste, spec, test-evidence, and documentation passes completed. Findings fixed: legacy CSV normalization, benchmark invocation/scoring/retry/grouping evidence, stale approval prose, README matrix drift, and taste/spec/current-row preservation. Final installer, launcher, all benchmark fixtures, shell syntax, prompt parity, CSV/model integrity, documentation links, ignore behavior, and diff hygiene pass.

Final branch review returned merge-after-fixes. Closed both composition findings: parallel-agent instructions now include conditional test review, and the full-screen benchmark transactionally restores or removes results.csv after any failed or interrupted cell. Also synchronized all reviewer prompts, removed stale derived artifacts before reruns, documented score provenance, semantically tested the model matrix, and covered rollback with and without a prior CSV. Follow-up taste, spec, and test-evidence reviews all pass.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Established the evidence-based testing policy and conditional read-only test review; built and mutation-audited original, Python, and TypeScript benchmark cases; selected operator-approved Sol high from manual benchmark evidence; installed the separate test role across Pi, Claude Code, opencode, and Codex while leaving fallback-runner unpinned; and documented the workflow and single-page audit. Verified with tests/test_install.sh, tests/test_review_bench.sh, every final fixture runner, syntax checks, prompt/CSV/model integrity checks, documentation review, and all three pre-commit reviewers.
<!-- SECTION:FINAL_SUMMARY:END -->
