# TASK-9 manual audit

Raw `*.judge.json` files are automatic output for the original test benchmark. This manual audit is the current authority and controls the final scores.

## Oracle and scoring corrections

The final clean integration fixture observes ordering and return values and has both a direct runner and pytest collection. All 12 high-r1 reviews were rerun. The five-defect oracle adds the verified always-retry `schedule_retry` mutation.

An independent read-only audit scored the original 25 defect reviews by exact-failure matching. Later tuning and language reviews were manually audited under the same exact-failure rules. Different genuine issues do not inflate planted recall and are not false positives. Self-dismissed or `Good` notes are not false positives. Minor item 7 requires source-text plus wording.

## Language oracle and manual scoring

The final Python and TypeScript defect tasks each have five must-fix items and two minor items; each clean task has zero items. Multiple legitimate contestant and auditor findings corrected the fixtures rather than being forced into the ground truth. The final Python freeze audit had 15/15 baselines and 58 mutation cases with 0 mismatches; the TypeScript final audit was GO with stable explicit async signals. Stale contestant artifacts were overwritten after fixture changes.

Fable judge repeatedly failed with HTTP 429. No substitute was used, no language judge JSON exists, and independent exact manual audits control these scores.

## Final high-r1 screen

| Model | must/5 | minor/2 | defect FP | integration FP | no-test FP |
| --- | ---: | ---: | ---: | ---: | ---: |
| Haiku | 2/5 | 1/2 | 1 | 0 | 0 |
| Sonnet | 4/5 | 2/2 | 0 | 0 | 0 |
| Opus | 4/5 | 2/2 | 0 | 1 | 0 |
| Terra | 3/5 | 2/2 | 0 | 0 | 0 |
| Sol | 4/5 | 2/2 | 0 | 0 | 0 |
| Luna | 3/5 | 2/2 | 0 | 0 | 0 |
| Kimi2.6 | 2/5 | 1/2 | 1 | 0 | 0 |
| Kimi2.7 | 3/5 | 1/2 | 0 | 0 | 0 |
| GLM | 3/5 | 2/2 | 0 | 0 | 0 |
| Flash | 3/5 | 2/2 | 0 | 0 | 0 |
| MiniMax | 4/5 | 2/2 | 0 | 0 | 0 |
| Pro | 4/5 | 2/2 | 0 | 0 | 0 |

## Final language r1 screen

| Model | must/10 | minor/4 | defect FP | clean FP |
| --- | ---: | ---: | ---: | ---: |
| Sol high | 9/10 | 4/4 | 0 | 3 |
| Sol medium | 9/10 | 4/4 | 1 | 2 |
| Flash | 5/10 | 4/4 | 2 | 3 |
| Pro | 7/10 | 4/4 | 1 | 2 |

## Finalists and tuning

- Sol high: 13/15 must-fix, 6/6 minor, and 0 defect FP; 0 FP across three integration and three no-test runs. Defect median: 120s/$0.250017; integration: 43s/$0.132578; no-test: 17s/$0.080294.
- Sol medium: 13/15 must-fix, 6/6 minor, and 0 defect FP, but its run floor is 3/5; defect median: 84s/$0.164063. Sol low is 4/5 and incorrectly calls the Bash assertion good. Prefer Sol high because it catches Bash in all three runs and has a 4/5 floor.
- Sonnet high: 12/15 must-fix, 6/6 minor, 0 defect FP, and 0 clean-case FP; defect median: 203s/$0.267189. Medium is 3/5. It is slower, slightly costlier on defects, and has lower recall than Sol high.
- MiniMax high was 4/5 at 35s/$0.017658, but xhigh regressed to 1/5 and 1/2 at 78s/$0.045126, so it was rejected without clean repeats.
- DeepSeek Pro high is 10/15; medium is 3/5. Its zero transcript cost is missing metadata, not free. GLM xhigh is 3/5. Flash xhigh timed out after more than 600s and has no row.

## Finalist language repeats

- Sol high: 27/30 must, 12/12 minor, defect FP 1, and clean FP 6; defect median: 102.5s/$0.233783; clean median: 114s/$0.233742.
- Sol medium: 27/30 must, 12/12 minor, defect FP 2, and clean FP 5; defect median: 70.5s/$0.162485; clean median: 68s/$0.168769.

Both levels miss the Python successful save-before-send order in all three runs; TypeScript is 15/15 in each.

## Combined evidence

Combined with the earlier test-defects repeats, both Sol levels reach 40/45 must-fix items. High has a 4/5 floor across nine defect runs; medium has a 3/5 floor because of the earlier Bash miss. Language defect FP is 1 for high and 2 for medium; language clean FP is 6 for high and 5 for medium.

## Routing gate

Recommend a separate `openai-codex/gpt-5.6-sol` high test-reviewer over shared Flash: comparable r1 across the original and language tasks is Sol 13/15 versus Flash 8/15. Prefer high over medium because recall is equal but high has a stronger floor and one fewer defect FP, while medium is materially faster and cheaper and has one fewer clean FP. Operator approved the separate Sol high test-reviewer on 2026-08-20.
