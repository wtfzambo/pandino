# Astra 6 test-review follow-up

2026-10-22. Astra completed all 21 attempts and matched Sol 6.1's seeded recall in every repetition. No clearly incorrect recommendation was observed. This sample gives no quality advantage for replacing Sol with Astra. Flash retains its higher observed seeded recall and its previously documented noise/completion trade-off.

## Protocol

- Contestant was `openai/gpt-6-astra` at high effort, using the same canonical test-reviewer prompt and seven unchanged cases as the [Sol 6.1 versus Flash 4.1 comparison](sol61-flash41-test-review.md).
- Three attempts per case, identified as `ar1`, `ar2` and `ar3`. The second round reversed case order. One review was active at a time.
- Each review had the existing 600-second process-tree deadline; a 2100-second supervisor bounded the launch. All attempts completed on their first launch, with no replacements. The launch ran from 18:11:00 to 18:33:10 CEST, approximately 22 minutes including judging. No benchmark processes remained afterward.
- Inputs were frozen at source revision `17fab63`. All 66 hashes for prompts, playbooks, runners, judge and fixtures were unchanged before each attempt and after completion. The sorted JSON path/hash manifest had SHA-256 `b2b2ef6f0e7e0fa44df230febbef6549b93f03c68b4d4fc3d4230d6729f8efde`.
- The automatic judge was `anthropic/claude-opus-5-5` at the existing low judge effort. The retained Sol/Flash launch used Fable. The orchestrator inspected all 21 new reviews against the same product-level matching rubric used in the earlier report, separately from the automatic scores. Model identities were visible during this inspection.
- Sol and Flash were retained historical references, with no new calls to either model. Their review inputs are unchanged, but execution conditions differ. Earlier Sol/Flash rounds had one active review per provider, allowing two contestants concurrently; this launch had one contestant. Timing comparisons are historical references rather than contemporaneous paired measurements.
- Model routing, prompts, fixtures, downstream installations and merge/push state remained unchanged.

## Comparison

| Measurement | Astra 6, new | Sol 6.1, retained | Flash 4.1, retained |
|---|---:|---:|---:|
| Completed attempts | 21/21 | 21/21 | 20/21 |
| Timeouts | 0 | 0 | 1 at 600 s |
| Seeded product-level matches | 39/45 | 39/45 | 42/45 |
| Clearly incorrect recommendation occurrences | 0 observed | 0 observed | At least 6 |
| Median completed-review time | 67 s | 65 s | 46 s |
| Mean completed-review time | 60 s | 66 s | 62 s |
| Mean across all attempts, including timeout | 60 s | 66 s | 87 s |
| Completed-review range | 25–87 s | 24–111 s | 7–305 s |

The 45 matching opportunities are 15 seeded problem groups repeated three times. They represent neither 45 distinct bugs nor independent observations for a significance claim. Credit follows a useful diagnosis and fix for the same product-level problem, regardless of finding count or severity grouping. The previous report documents this rubric and the six verified erroneous Flash recommendations. Its error count is a conservative lower bound; the new zero means no clearly incorrect recommendation was observed, rather than a universal false-positive guarantee.

Astra's automatic outputs agree with direct inspection on the seeded matches and show zero automatic false positives. Both minor excess groups were recognized in all nine defect reviews, giving 18/18 minor-group matches. Changing the judge does not make the existing clean labels an exhaustive correctness oracle.

## Coverage and omissions

| Seeded case | Astra `ar1 / ar2 / ar3` | Retained Sol | Retained Flash |
|---|---|---|---|
| [Notification](../tasks/test-defects/expected.md) | 4/5 · 4/5 · 4/5 | 4/5 · 4/5 · 4/5 | 5/5 · 5/5 · 5/5 |
| [Python booking](../tasks/test-python-defects/expected.md) | 4/5 · 4/5 · 4/5 | 4/5 · 4/5 · 4/5 | 4/5 · 4/5 · 4/5 |
| [TypeScript orders](../tasks/test-typescript-defects/expected.md) | 5/5 · 5/5 · 5/5 | 5/5 · 5/5 · 5/5 | 5/5 · 5/5 · 5/5 |

Astra omitted the same two seeded groups as Sol in every repetition:

1. Notification item 5 requires an independent negative `schedule_retry` case. Astra correctly identified the broken shell guard, missing 429 coverage, implementation-derived delay oracle and unsupported provider fake, but did not ask for the negative public scheduling assertion. Its [third review](raw/openai-gpt-6-astra_high_test-defects_rar3.review.md) proposes “Restore the direct Python assertion without `!`”; that repairs the predicate guard without observing a separately broken scheduler branch.
2. Python item 5 requires maintained evidence of successful save-before-send ordering, including the member-specific success scenario. Astra caught the independent-price, threshold, exception-type and returned-ID gaps, but did not raise the unobserved successful-call-order gap. Its [third review](raw/openai-gpt-6-astra_high_test-python-defects_rar3.review.md) correctly observes that the existing failure case catches a straightforward send-before-save mutation. Directly probing current correct ordering does not replace a maintained regression assertion for the unobserved variant.

All four control cases received no findings in every repetition. These cover proportionate checkout integration, documentation requiring no test, the Python booking control and the TypeScript ordering control. Astra did not ask to remove the useful integer-cent guards, non-finite-number cases or deferred test that Flash challenged. Native edit/write tool calls were absent, and inspection of the traces found no file-changing mutation execution. Its mutation checks were static or in-memory, preserving the role's explicit restriction.

Quiet control reviews still omit genuine concerns. The TypeScript control contains the previously reproduced unbounded deferred wait and lacks test protection for the core error-cause-preservation rule. All three Astra reviews called it clean without either finding. Sol also missed the hang, although it identified the cause-preservation gap once. Flash identified the hang in its completed `tr4` review. The [earlier report](sol61-flash41-test-review.md#genuine-concerns-omitted-by-the-clean-oracle) preserves the counterexamples and distinguishes those valid concerns from erroneous deletion advice. Zero observed spurious findings should therefore be considered alongside these omissions.

## Every new attempt

Each cell links the review and its original Opus judgment (`J`). Times exclude judging and use the interval from creation to final modification of the original local JSONL transcript, rounded to seconds, as in the earlier report. The committed table preserves these approximate wall measurements across checkouts. Every attempt below completed with status 0.

| Case | `ar1` | `ar2` | `ar3` |
|---|---|---|---|
| test-defects | [76 s](raw/openai-gpt-6-astra_high_test-defects_rar1.review.md) ([J](raw/openai-gpt-6-astra_high_test-defects_rar1.judge.json)) | [77 s](raw/openai-gpt-6-astra_high_test-defects_rar2.review.md) ([J](raw/openai-gpt-6-astra_high_test-defects_rar2.judge.json)) | [75 s](raw/openai-gpt-6-astra_high_test-defects_rar3.review.md) ([J](raw/openai-gpt-6-astra_high_test-defects_rar3.judge.json)) |
| test-integration | [36 s](raw/openai-gpt-6-astra_high_test-integration_rar1.review.md) ([J](raw/openai-gpt-6-astra_high_test-integration_rar1.judge.json)) | [45 s](raw/openai-gpt-6-astra_high_test-integration_rar2.review.md) ([J](raw/openai-gpt-6-astra_high_test-integration_rar2.judge.json)) | [42 s](raw/openai-gpt-6-astra_high_test-integration_rar3.review.md) ([J](raw/openai-gpt-6-astra_high_test-integration_rar3.judge.json)) |
| test-no-test | [31 s](raw/openai-gpt-6-astra_high_test-no-test_rar1.review.md) ([J](raw/openai-gpt-6-astra_high_test-no-test_rar1.judge.json)) | [25 s](raw/openai-gpt-6-astra_high_test-no-test_rar2.review.md) ([J](raw/openai-gpt-6-astra_high_test-no-test_rar2.judge.json)) | [30 s](raw/openai-gpt-6-astra_high_test-no-test_rar3.review.md) ([J](raw/openai-gpt-6-astra_high_test-no-test_rar3.judge.json)) |
| test-python-defects | [87 s](raw/openai-gpt-6-astra_high_test-python-defects_rar1.review.md) ([J](raw/openai-gpt-6-astra_high_test-python-defects_rar1.judge.json)) | [85 s](raw/openai-gpt-6-astra_high_test-python-defects_rar2.review.md) ([J](raw/openai-gpt-6-astra_high_test-python-defects_rar2.judge.json)) | [85 s](raw/openai-gpt-6-astra_high_test-python-defects_rar3.review.md) ([J](raw/openai-gpt-6-astra_high_test-python-defects_rar3.judge.json)) |
| test-python-clean | [81 s](raw/openai-gpt-6-astra_high_test-python-clean_rar1.review.md) ([J](raw/openai-gpt-6-astra_high_test-python-clean_rar1.judge.json)) | [77 s](raw/openai-gpt-6-astra_high_test-python-clean_rar2.review.md) ([J](raw/openai-gpt-6-astra_high_test-python-clean_rar2.judge.json)) | [70 s](raw/openai-gpt-6-astra_high_test-python-clean_rar3.review.md) ([J](raw/openai-gpt-6-astra_high_test-python-clean_rar3.judge.json)) |
| test-typescript-defects | [83 s](raw/openai-gpt-6-astra_high_test-typescript-defects_rar1.review.md) ([J](raw/openai-gpt-6-astra_high_test-typescript-defects_rar1.judge.json)) | [67 s](raw/openai-gpt-6-astra_high_test-typescript-defects_rar2.review.md) ([J](raw/openai-gpt-6-astra_high_test-typescript-defects_rar2.judge.json)) | [48 s](raw/openai-gpt-6-astra_high_test-typescript-defects_rar3.review.md) ([J](raw/openai-gpt-6-astra_high_test-typescript-defects_rar3.judge.json)) |
| test-typescript-clean | [43 s](raw/openai-gpt-6-astra_high_test-typescript-clean_rar1.review.md) ([J](raw/openai-gpt-6-astra_high_test-typescript-clean_rar1.judge.json)) | [59 s](raw/openai-gpt-6-astra_high_test-typescript-clean_rar2.review.md) ([J](raw/openai-gpt-6-astra_high_test-typescript-clean_rar2.judge.json)) | [37 s](raw/openai-gpt-6-astra_high_test-typescript-clean_rar3.review.md) ([J](raw/openai-gpt-6-astra_high_test-typescript-clean_rar3.judge.json)) |

## Limits and disposition

This is a small-fixture follow-up with three repetitions and historical comparators. It establishes neither statistical superiority nor an intrinsic speed or billing-cost ranking. Default Python lacks pytest; Astra disclosed that framework execution was unverified and used dependency-free probes for Python behavior. TypeScript and the direct checkout runner were executed normally. Native pytest remained unverified in several retained Sol reviews too.

The observed result is similar seeded recall and restraint for Astra and Sol. Flash's additional negative-scheduling detection, mistaken-removal recommendations, role violations and failed attempt remain the documented trade-off. The current evidence supplies no quality reason to adopt Astra instead of Sol for this role. The broader benchmark redesign remains TASK-28. No further model matrix or routing change was performed.
