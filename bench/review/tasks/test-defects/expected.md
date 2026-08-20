# Ground truth

## Must-fix

1. `test_notifier.py` does not add a regression case for the changed 429 retry behavior. The observable contract explicitly adds 429; a mutation that removes 429 from `retryable_status` still passes.
2. `test_rejections.sh` uses a top-level `!` assertion under `set -e`. Bash does not exit for that negated command when it unexpectedly returns failure, so a mutation that makes status 400 retryable still lets the script print PASS.
3. `test_notifier.py` derives `schedule_retry`'s expected delay by calling production `retry_delay`. A mutation that makes `retry_delay` return the wrong value changes both sides together; the test must use the documented hand-derived delay of 20 seconds.
4. `test_notifier.py`'s `FakeMailProvider` invents a JSON `body.retry_after_seconds` shape even though the contract only defines the `Retry-After` header. The fake makes an unsupported integration assumption pass and cannot protect the real provider boundary.
5. `test_notifier.py` exercises `schedule_retry` only with retryable status 503. A mutation that changes `schedule_retry` to always return `{"retry": True, "delay": retry_delay(attempt)}` survives both test files because `test_rejections.sh` calls `retryable_status` directly. This leaves the documented “do not retry other statuses” promise unprotected at the public scheduling boundary; add an independent negative assertion such as `assert schedule_retry(400, 2)["retry"] is False`.

## Minor excess

6. `test_notifier.py` duplicates cheaper guarantees with a source-file existence check and runtime type-hint check. Neither protects notification behavior.
7. `test_notifier.py` reads production source for the `retry_message` function name and asserts its exact non-contract wording. Those assertions are brittle implementation/copy checks, not observable promises.

Scoring: `found` and `total` count the five must-fix defects. `minor_found` and `minor_total` count the two minor excess items. A must-fix finding not in either list is a false positive; a minor finding not in the minor list is also a false positive. A review may combine related assertions only when it identifies each listed defect.
