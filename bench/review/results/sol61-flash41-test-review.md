# Sol 6.1 versus DeepSeek Flash 4.1 as test reviewers

2026-10-22. Flash recognized more seeded problems and usually finished sooner. Sol produced fewer mistaken recommendations and completed every attempt. The previous historical recall advantage for Sol does not hold in this sample. These results expose a trade-off rather than establish a universal winner. Routing remains unchanged.

## Protocol and outcome

- Contestants were `openai/gpt-6.1-sol` and `ollama-cloud/deepseek-v4.1-flash`, both at high effort with the canonical test-reviewer prompt.
- Seven cases, three attempts per model and case. The completed low-concurrency `sp3` round was reused; `tr4` and `tr5` added 28 attempts. Total outcome was 41 completed reviews and one timeout across 42 attempts.
- There was at most one active review per provider. The new rounds traversed cases in opposite orders. The new launch took approximately 25 minutes, including automatic judging.
- Each review had a tested 600-second process-tree deadline. The new launch had a 2100-second overall supervisor. No replacement attempt was run after the timeout.
- Inputs were frozen at branch revision `d6fbbe7`. The 65 prompt, playbook, runner and fixture files were hashed before launch and checked before each new attempt and after completion. Their content remained unchanged. The sorted JSON path/hash manifest had SHA-256 `ec2397851bc34a6861f983cec1a0c54be0ce0fe925faa11c5ab8df0998ee0653`. The reused round has identical relevant source content.
- All 41 completed reviews were inspected against their fixtures and contracts. Targeted counterexample probes below were performed separately in disposable copies after the contestant inputs were frozen. The orchestrator knew model identities; this adjudication was not blinded.
- Automatic judging used the existing Fable judge. Its original outputs are linked below. Flash's notification review in `sp3` has no automatic judgment because of the earlier judge quota failure; its five product-level matches were checked directly. Missing judging is separate from contestant failure.

## Summary

| Measurement | Sol 6.1 | Flash 4.1 |
|---|---:|---:|
| Completed attempts | 21/21 | 20/21 |
| Timeouts | 0 | 1 at 600 seconds |
| Seeded problem matches | 39/45 | 42/45 |
| Clearly incorrect recommendations verified below | 0 observed | At least 6 |
| Median completed-review time | 65 s | 46 s |
| Mean completed-review time | 66 s | 62 s |
| Mean time across all attempts, including timeout | 66 s | 87 s |
| Completed-review range | 24–111 s | 7–305 s |

Flash was faster in 17 of the 20 pairs where both reviews completed. Its remaining attempt timed out. Typical latency favors Flash; including the failed attempt reverses the mean waiting-time comparison. This measures wall time, including reasoning and tool execution, and establishes no billing-cost ranking.

The recall denominator is 15 seeded problem groups repeated three times, giving 45 matching opportunities per model. It represents neither 45 distinct bugs nor a statistical equivalence test. Credit follows the affected product promise and a useful diagnosis/fix, regardless of finding count or severity heading. A combined finding can match two groups. Credit does not require enumerating every manifestation of the same defect. This is narrower than claiming that every compound fixture detail was explicitly discussed.

The incorrect-recommendation count is a conservative lower bound based on concrete counterexamples. It excludes debatable requests for extra cases, naming changes and shared test helpers. Raw judge false-positive totals are unsuitable for ranking because they penalize genuine unplanted concerns.

## Seeded problem coverage

| Case | Expected groups | Sol `sp3 / tr4 / tr5` | Flash `sp3 / tr4 / tr5` |
|---|---|---|---|
| [Notification](../tasks/test-defects/expected.md) | 429 coverage; shell failure propagation; independent retry-delay oracle; provider-header fixture; negative scheduling | 4/5 · 4/5 · 4/5 | 5/5 · 5/5 · 5/5 |
| [Python booking](../tasks/test-python-defects/expected.md) | Four-seat boundary; independent price; ValueError; returned booking ID; explicit successful save/send ordering evidence | 4/5 · 4/5 · 4/5 | 4/5 · 4/5 · 4/5 |
| [TypeScript ordering](../tasks/test-typescript-defects/expected.md) | Ten-unit boundary; independent price; RangeError; saved transaction ID; returned order ID | 5/5 · 5/5 · 5/5 | 5/5 · 5/5 · 5/5 |

Sol omitted the independent negative `schedule_retry` case in all three notification reviews. Flash requested it each time. This one repeatedly recognized gap accounts for the entire three-match recall difference. In `sp3`, Flash demonstrated a real shell false-pass path but did not explain the additional `errexit` exemption as precisely as Sol; its proposed direct assertion would repair the seeded defect. Its `tr5` explanation names the exemption explicitly.

Both models omitted a finding requesting explicit successful save-before-send ordering evidence in the Python defect case. Existing save-failure coverage already kills the simple unconditional send-before-save mutation. The oracle's fifth group asks for stronger success-path evidence across the member/non-member scenarios; a 4/5 score should not be read as absence of all ordering protection.

Severity still matters. Flash placed the independent retry-delay oracle under minor in `sp3` and `tr5`, and the negative scheduling gap was grouped under minor in `sp3`. Those receive recall credit but weaker blocking treatment than the expected must-fix classification. All six verified mistaken recommendations below were minor findings.

## Verified mistaken recommendations

| Flash review | Claim | Independent counterexample |
|---|---|---|
| [Python clean `sp3`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-clean_rsp3.review.md) | Runtime result/boundary integer checks “restate guarantees” and should be deleted. | Return `float(total)` only from `confirm_booking`. The original suite fails two cases; removing the result integer assertion makes all 15 pass. Price-calculation type checks remain present. |
| [Python defects `tr4`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-defects_rtr4.review.md) | Integer equality already checks type; delete the `isinstance` assertions. | Python considers `9000.0 == 9000` true. A boundary-only float conversion is detected by the original guard and passes after that guard is removed. |
| [Python clean `tr4`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-clean_rtr4.review.md) | Keep one integer check on a returned or emitted total and drop the remaining checks. | Convert only the repository argument to `float(total)`, keeping the returned total an integer. The original suite fails; removing boundary type guards makes all 15 pass while the result type guard remains. Distinct boundaries can leak floats independently. |
| [TypeScript clean `tr4`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-clean_rtr4.review.md) | The deferred test “adds no protection” and can be deleted. | Replace the awaited charge with `await Promise.race([payment.charge(totalCents), Promise.resolve("cached-transaction")])`. All seven other tests pass. The deferred test fails on the wrong transaction ID, protecting behavior with a genuinely pending payment. |
| [TypeScript defects `tr5`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-defects_rtr5.review.md) | NaN/Infinity exercise the fractional-input branch and add no distinct protection; deletion is offered. | Replace the integer guard with `quantity !== Math.floor(quantity)`. Fractional quantities still reject, but positive infinity is accepted. The non-finite test is the only failing test in the clean fixture with the same implementation. Combining cases while retaining infinity would be safe; deleting its coverage is unsafe. |
| [Python defects `tr5`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-defects_rtr5.review.md) | Keep the returned-value integer assertion and drop the two boundary-argument guards. | Convert only the mailer argument to `float(total)`. The original defect fixture fails; removing the boundary guards makes all 15 pass while the returned-value guard remains. |

These probes used the real pytest runner through an ephemeral `uv` environment for Python and `node --test` for TypeScript, with the shared deadline wrapper. They left contestant inputs untouched. They establish that the proposed removals lose observable protection; they do not require treating every optional cleanup suggestion as an error.

Flash also suggested extra integration fixtures or future automatic discovery and repeatedly suggested merging invalid-input test functions. Those suggestions are outside this conservative count. Its `tr5` integration review supplies a concrete selective-rounding counterexample and explicitly marks currency semantics as unverified; that deserves contract consideration rather than automatic rejection based on the clean label.

## Genuine concerns omitted by the clean oracle

### Unbounded asynchronous test

[Flash TypeScript clean `tr4`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-clean_rtr4.review.md) correctly reports the unbounded deferred waits. Swapping save before charge in a temporary copy again reached the external three-second deadline with status 124. Earlier assertions report failures, but the suite does not terminate because its final test remains pending. This is a real test-infrastructure problem. The same review's proposed deletion of the deferred test is separately wrong, as shown above. Bounding the useful test preserves its protection.

The two completed Sol reviews after `sp3` and Sol's reused review did not flag this hang. Flash's `sp3` review also omitted it; `tr5` delivered no review.

### Preserving dependency-error causes

[Sol TypeScript clean `tr4`](raw/openai-gpt-6-1-sol_high_test-typescript-clean_rtr4.review.md) correctly connects broad rejection assertions to the core rule requiring preservation of the original exception when translating errors. Replacing a payment error with `new Error("order failed")` without a cause leaves all eight tests green. The automatic judge calls Sol's finding a false positive because the fixture is labeled clean; that judgment is incorrect under the loaded `AGENTS.md` rule.

Several Flash reviews also notice dependency-error matching gaps, including [TypeScript clean `sp3`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-clean_rsp3.review.md), [TypeScript defects `tr4`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-defects_rtr4.review.md) and [TypeScript clean `tr4`](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-clean_rtr4.review.md). Their exact-error remedies can be stronger than necessary: an allowed wrapper retaining the original cause should remain acceptable. The useful concern is cause preservation, distinct from requiring identity in every case.

## Incomplete attempt

Flash `test-typescript-clean`, `tr5`, started at 17:37:27 CEST on 2026-10-22 and stopped at 17:47:27. The wrapper returned status 124 after approximately 600.1 seconds. The preserved stderr is:

```text
Benchmark command timed out after 600s: pi
```

Its final outstanding tool command applied mutations in `/tmp/mutcheck` and executed this loop without a command deadline:

```sh
if node --test orders.test.ts >/tmp/mutcheck/out.txt 2>&1; then
    echo "SURVIVED: $name"
else
    echo "killed: $name"
fi
```

The mutation sequence reached `save_before_charge`, which creates the reproduced suite hang. No final review or judge score was produced. The supervisor continued with the remaining cases; this attempt was kept as failed and received no replacement. A process-table check after timeout found no surviving command for that scratch directory or fixture. A final check after the launch found no active benchmark supervisor, reviewer or `orders.test.ts` test process.

The canonical role explicitly permits proposing mutations while prohibiting file-changing mutation execution. Multiple Flash attempts, including this one and the successful `tr4` TypeScript clean review, nevertheless mutated temporary copies. This is an observed role-compliance problem as well as the source of the latency tail. Sol's inspected reviews used static or in-memory mutation reasoning. The benchmark did not enforce a tool-level read-only sandbox, so it measures behavior under the written instruction.

## Every attempt

Times exclude automatic judging. They are approximate wall intervals from creation to final modification of the original JSONL transcripts on this macOS filesystem, rounded to seconds. The failed attempt uses its enforced 600-second deadline. Reconstructed times need the original local transcripts; the committed table preserves the measurements across checkouts. `J` links the original automatic judgment, whose false-positive counts retain the oracle problems described above.

| Case / model | `sp3` | `tr4` | `tr5` |
|---|---|---|---|
| test-defects / Sol | [90 s](raw/openai-gpt-6-1-sol_high_test-defects_rsp3.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-defects_rsp3.judge.json)) | [71 s](raw/openai-gpt-6-1-sol_high_test-defects_rtr4.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-defects_rtr4.judge.json)) | [109 s](raw/openai-gpt-6-1-sol_high_test-defects_rtr5.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-defects_rtr5.judge.json)) |
| test-defects / Flash | [21 s, judged directly](raw/ollama-cloud-deepseek-v4-1-flash_high_test-defects_rsp3.review.md) | [41 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-defects_rtr4.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-defects_rtr4.judge.json)) | [63 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-defects_rtr5.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-defects_rtr5.judge.json)) |
| test-integration / Sol | [45 s](raw/openai-gpt-6-1-sol_high_test-integration_rsp3.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-integration_rsp3.judge.json)) | [57 s](raw/openai-gpt-6-1-sol_high_test-integration_rtr4.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-integration_rtr4.judge.json)) | [42 s](raw/openai-gpt-6-1-sol_high_test-integration_rtr5.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-integration_rtr5.judge.json)) |
| test-integration / Flash | [44 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-integration_rsp3.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-integration_rsp3.judge.json)) | [34 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-integration_rtr4.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-integration_rtr4.judge.json)) | [37 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-integration_rtr5.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-integration_rtr5.judge.json)) |
| test-no-test / Sol | [31 s](raw/openai-gpt-6-1-sol_high_test-no-test_rsp3.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-no-test_rsp3.judge.json)) | [31 s](raw/openai-gpt-6-1-sol_high_test-no-test_rtr4.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-no-test_rtr4.judge.json)) | [24 s](raw/openai-gpt-6-1-sol_high_test-no-test_rtr5.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-no-test_rtr5.judge.json)) |
| test-no-test / Flash | [7 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-no-test_rsp3.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-no-test_rsp3.judge.json)) | [10 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-no-test_rtr4.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-no-test_rtr4.judge.json)) | [8 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-no-test_rtr5.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-no-test_rtr5.judge.json)) |
| test-python-defects / Sol | [74 s](raw/openai-gpt-6-1-sol_high_test-python-defects_rsp3.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-python-defects_rsp3.judge.json)) | [88 s](raw/openai-gpt-6-1-sol_high_test-python-defects_rtr4.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-python-defects_rtr4.judge.json)) | [111 s](raw/openai-gpt-6-1-sol_high_test-python-defects_rtr5.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-python-defects_rtr5.judge.json)) |
| test-python-defects / Flash | [55 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-defects_rsp3.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-defects_rsp3.judge.json)) | [31 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-defects_rtr4.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-defects_rtr4.judge.json)) | [50 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-defects_rtr5.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-defects_rtr5.judge.json)) |
| test-python-clean / Sol | [95 s](raw/openai-gpt-6-1-sol_high_test-python-clean_rsp3.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-python-clean_rsp3.judge.json)) | [97 s](raw/openai-gpt-6-1-sol_high_test-python-clean_rtr4.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-python-clean_rtr4.judge.json)) | [62 s](raw/openai-gpt-6-1-sol_high_test-python-clean_rtr5.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-python-clean_rtr5.judge.json)) |
| test-python-clean / Flash | [51 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-clean_rsp3.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-clean_rsp3.judge.json)) | [62 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-clean_rtr4.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-clean_rtr4.judge.json)) | [48 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-clean_rtr5.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-python-clean_rtr5.judge.json)) |
| test-typescript-defects / Sol | [62 s](raw/openai-gpt-6-1-sol_high_test-typescript-defects_rsp3.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-typescript-defects_rsp3.judge.json)) | [73 s](raw/openai-gpt-6-1-sol_high_test-typescript-defects_rtr4.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-typescript-defects_rtr4.judge.json)) | [65 s](raw/openai-gpt-6-1-sol_high_test-typescript-defects_rtr5.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-typescript-defects_rtr5.judge.json)) |
| test-typescript-defects / Flash | [58 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-defects_rsp3.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-defects_rsp3.judge.json)) | [43 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-defects_rtr4.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-defects_rtr4.judge.json)) | [67 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-defects_rtr5.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-defects_rtr5.judge.json)) |
| test-typescript-clean / Sol | [46 s](raw/openai-gpt-6-1-sol_high_test-typescript-clean_rsp3.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-typescript-clean_rsp3.judge.json)) | [68 s](raw/openai-gpt-6-1-sol_high_test-typescript-clean_rtr4.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-typescript-clean_rtr4.judge.json)) | [41 s](raw/openai-gpt-6-1-sol_high_test-typescript-clean_rtr5.review.md) ([J](raw/openai-gpt-6-1-sol_high_test-typescript-clean_rtr5.judge.json)) |
| test-typescript-clean / Flash | [198 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-clean_rsp3.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-clean_rsp3.judge.json)) | [305 s](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-clean_rtr4.review.md) ([J](raw/ollama-cloud-deepseek-v4-1-flash_high_test-typescript-clean_rtr4.judge.json)) | [600 s, timeout](#incomplete-attempt) |

## Limits and decision relevance

These are small frozen fixtures, three attempts per configuration, and one reused round from an earlier launch. The comparison does not isolate provider load, establish significance, measure cost, or measure same-family writer/reviewer effects. Default system Python lacks pytest. Reviews variously used ephemeral pytest environments, in-memory probes or handwritten shims; native pytest execution remained unverified in several Sol reviews. This environment limitation and each model's response to it are visible in their coverage reports.

The useful current distinction is higher observed seeded recall and lower median latency for Flash versus fewer verified mistaken recommendations, better observed mutation restraint and complete delivery for Sol. Flash's six verified bad suggestions were minor, while its genuine hang finding was must-fix. The trade-off depends on how the operator values review noise and reliability. The broader benchmark redesign remains TASK-28. No prompts, fixtures, model defaults, downstream projects, merge state or remote branches were changed by this comparison.
