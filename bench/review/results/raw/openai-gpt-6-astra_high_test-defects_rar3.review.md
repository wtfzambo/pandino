## Verdict
changes needed

## Findings
### must-fix
- `test_rejections.sh:4` | demonstrated defect | Bash exempts commands prefixed with `!` from `set -e`; even when the negated check fails, execution reaches the successful `echo`. The script therefore reports success whether HTTP 400 is retryable or not. | Restore the direct Python assertion without `!`. | Promise: other statuses must not retry; mutating `retryable_status` to always return `True` would currently pass both test scripts.

- `test_notifier.py:12` | incomplete coverage | No test exercises HTTP 429, the existing retry policy’s newly added behavior. | Add a positive assertion for HTTP 429 alongside the 503 and rejection cases. | Promise: HTTP 429 retries; reverting `retryable_status` to `return status == 503` would pass every current test.

- `test_notifier.py:15` | incomplete coverage | The expected second-attempt delay comes from `retry_delay(2)`, the same function used by `schedule_retry`; no independent assertion establishes the documented 20-second value. | Assert the scheduled result against `{"retry": True, "delay": 20}`. | Promise: attempt two waits 20 seconds; making `retry_delay(2)` return 30 while preserving attempts one and three would pass.

- `test_notifier.py:7–9` | demonstrated defect | The provider fake supplies an invented JSON-body field, so the passing test endorses the implementation’s body lookup even though the documented contract specifies the `Retry-After` response header. | Shape the fake using the provider’s actual response interface, supply `Retry-After`, and assert its value is returned without depending on the body. | Promise: provider delay comes from the header; replacing a correct header lookup with the current body lookup must fail the regression test.

### minor
- `test_notifier.py:17–19` | demonstrated defect | File-existence, annotation-reflection, and source-text assertions add no observable retry protection beyond the imports and behavior checks, while pinning file layout and implementation details. | Delete these assertions and their unused imports; leave annotation enforcement to static tooling. | Excess removed: three structural checks that can fail under behavior-preserving refactoring.

- `test_notifier.py:20` | demonstrated defect | Exact message equality freezes wording explicitly excluded from the product contract. | Replace exact equality with a wording-tolerant check that the message communicates a scheduled retry. | Excess removed: changing the message to “A retry has been scheduled” should not fail while the observable promise remains satisfied.

## Good
- The first- and third-attempt delay assertions use independent, contract-derived values.
- Tests exercise public helpers directly without mocking internal helper calls.

## Coverage
- Checked: complete working diff, notification contract, and review/testing instructions. Both test scripts pass; `git diff --check` passes. A read-only shell probe confirmed that a failed negated check continues under `set -e`. No files were changed.
- Unverified: actual provider response interface; no provider integration or authoritative interface definition is supplied. Mutations above were reasoned through, not executed. The required pickup skill file is absent.
- Turns: 7 of unspecified budget; timed-out commands: none.
