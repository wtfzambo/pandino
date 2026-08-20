## Test review: notification retry diff

The diff adds retry helpers (`retryable_status` 429/503, `retry_delay`, `schedule_retry`, `provider_retry_delay`, `retry_message`) and rewrites both test files. The documented contract is `docs/notification-spec.md`. Findings ordered by severity.

### Must-fix

**1. `test_rejections.sh:4` — the rejection assertion is neutralized and always passes.**
The `!` prefix combined with `set -e` means the script never fails. `set -e` does not abort on a command whose exit status is inverted with `!`, so both outcomes fall through to `echo "test_rejections: PASS"` and exit 0. I verified this empirically: with the bug simulated (`raise SystemExit(0)`, i.e. `retryable_status(400)` returning `True`), the script still prints `PASS` and exits 0. The original `assert not retryable_status(400)` correctly failed under `set -e` (verified: `assert not True` → exit 1). The observable promise "400 is not retryable" now has no effective evidence.
Concrete mutation: change `retryable_status` to `return True` — the test still passes. Fix: drop the `!` and keep the Python process exiting non-zero on the bug (e.g. `raise SystemExit(1 if retryable_status(400) else 0)`), or restore the original `assert not retryable_status(400)`.

**2. `test_notifier.py:12` — the new 429 behavior has no positive test.**
The behavior change is `status == 503` → `status in (429, 503)`, but the only positive assertion is `retryable_status(503)`, and the rejection test only covers 400. Nothing asserts `retryable_status(429)` is `True`.
Concrete mutation: revert to `return status == 503` — every test still passes. Add `assert retryable_status(429)`.

**3. `test_notifier.py:7-9,16` — `provider_retry_delay` test invents a fixture shape that contradicts the documented contract.**
The spec states the provider exposes its retry delay through the `Retry-After` response header and that "its JSON response body is not part of our contract." The `FakeMailProvider` returns `{"body": {"retry_after_seconds": 20}}`, and the code reads `response["body"]["retry_after_seconds"]`. The test locks in the body-based behavior and would *fail* if the code were corrected to read the header (`KeyError: "body"`), so it actively resists the correct fix. This is an invented external-provider shape, not a real boundary fixture.
Concrete mutation: fix `provider_retry_delay` to read `response.headers["Retry-After"]` — the test fails, proving it protects the wrong promise. The fake should model the documented header contract.

### Minor excess

**4. `test_notifier.py:15` — `schedule_retry` expectation recomputes the implementation.**
`{"retry": True, "delay": retry_delay(2)}` derives the expected delay by calling the very function under test, so the delay half passes by construction. Use the independent literal `20` (the spec's attempt-two value).

**5. `test_notifier.py:17` — `assert Path("notifier.py").exists()`** is an existence check protecting no product promise. Delete.

**6. `test_notifier.py:18` — `get_type_hints(retryable_status)["status"] is int`** duplicates what static typing already guarantees. Delete.

**7. `test_notifier.py:19` — `"def retry_message" in Path("notifier.py").read_text()`** is an internal-structure assertion that breaks on any refactor and protects no observable behavior. Delete.

**8. `test_notifier.py:20` — exact wording of `retry_message` is over-constrained.** The spec explicitly says "the exact wording is not part of the product contract." Asserting `== "Retry scheduled in 20 seconds"` turns a non-promise into a brittle contract. If kept at all, assert only the promise (a retry was reported, with the delay), e.g. `"Retry scheduled" in retry_message(20) and "20" in retry_message(20)`.

### Good

- `retry_delay(1) == 10` and `retry_delay(3) == 40` use independent literal expected values matching the spec's enumerated delays (10/20/40); attempt 2 is untested but the two points pin the exponential formula adequately.
- `retryable_status(503)` is a valid positive check, just incomplete without the 429 case (finding 2).

Net: the rejection test is currently dead evidence (must-fix), the headline 429 change is unprotected (must-fix), and the provider-delay test protects behavior that contradicts the documented contract (must-fix). The remaining assertions are mostly excess that should be deleted rather than fixed.
