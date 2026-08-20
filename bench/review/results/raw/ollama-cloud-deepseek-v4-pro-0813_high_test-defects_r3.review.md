## Test-evidence review

The diff adds retry helpers (`retryable_status` now includes 429, plus `retry_delay`, `schedule_retry`, `provider_retry_delay`, `retry_message`) and extends the two test files. The authoritative contract is `docs/notification-spec.md`.

### Must-fix

**1. The 429 branch — the core behavior change — is never exercised.**
`test_notifier.py:12` asserts only `retryable_status(503)`; `test_rejections.sh:4` asserts only that 400 is rejected. The spec's first promise is "retry after 429 **or** 503." A mutation of `notifier.py:5` back to `return status == 503` (or `status in (503,)`) passes every test in the suite, silently dropping the 429 behavior this diff introduces. Add an independent `assert retryable_status(429)` (or a `schedule_retry(429, …)` case) so the new branch is protected.

**2. `provider_retry_delay` test invents a fixture shape that contradicts the documented contract.**
`test_notifier.py:7-9,16` fake returns `{"body": {"retry_after_seconds": 20}}`, and the assertion certifies that the implementation reads the JSON body. But the spec states the delay comes from the `Retry-After` response **header** and that "its JSON response body is not part of our contract." The test's expectation is derived from the implementation's invented shape, not from the contract, so it provides false protection: it passes precisely because the implementation (`notifier.py:18`) violates the spec. Concrete exposure: change `provider_retry_delay` to read `response["headers"]["Retry-After"]` (the contract-correct behavior) and the test fails with `KeyError: "body"` — the test is locked to the wrong shape. The fake should expose a `Retry-After` header and the assertion should verify the header is read.

**3. `schedule_retry` assertion is self-referential and leaves attempt 2 unprotected.**
`test_notifier.py:15` asserts `schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}`. The expected value recomputes the implementation, so it proves nothing about the delay. The spec fixes attempts 1/2/3 as 10/20/40; attempt 2 (20) is only "covered" by this tautology. A mutation making `retry_delay(2)` return 25 (e.g., a lookup table `{1:10, 2:25, 3:40}`) passes all tests. Replace the right-hand side with the independent literal `{"retry": True, "delay": 20}`.

### Minor excess

**4. `test_notifier.py:20`** — `assert retry_message(20) == "Retry scheduled in 20 seconds"` pins exact wording that the spec explicitly excludes from the contract ("the exact wording is not part of the product contract"). Brittle; assert only that a retry was reported (e.g., non-empty / contains the delay) or drop it.

**5. `test_notifier.py:17`** — `assert Path("notifier.py").exists()` is a trivial existence check, not a product promise.

**6. `test_notifier.py:18`** — `assert get_type_hints(retryable_status)["status"] is int` asserts an internal annotation; this duplicates what a type checker already guarantees and protects no observable behavior.

**7. `test_notifier.py:19`** — `assert "def retry_message" in Path("notifier.py").read_text()` is a source-text search redundant with the import on line 4 (the import would fail if the function were absent). Internal-structure assertion, no product promise.

**8. `test_rejections.sh:4`** — the rewrite to `! python3 -c '… raise SystemExit(0 if retryable_status(400) else 1)'` is functionally identical to the original `assert not retryable_status(400)` but strictly harder to read. No added value; revert to the plain assertion.

### Good

- `retry_delay(1) == 10` and `retry_delay(3) == 40` (`test_notifier.py:13-14`) are hand-derived from the spec's 10/20/40 table and independent of the implementation.
- The 503-positive / 400-negative pair correctly brackets the retryable-status contract (once 429 is added per finding 1).

Net: the new behavior is real and mostly testable, but the suite currently misses the 429 branch entirely, certifies a spec-violating provider shape, and contains one tautological assertion plus several non-promise checks. Findings 1–3 are must-fix; 4–8 are removable noise.
