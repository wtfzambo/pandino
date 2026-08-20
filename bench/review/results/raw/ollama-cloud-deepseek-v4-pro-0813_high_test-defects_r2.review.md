## Test review: notifier retry helpers

The diff adds four functions and expands the tests. The documented contract is `docs/notification-spec.md`. Findings ordered by severity.

### Must-fix

**1. The new 429 behavior has no regression protection — `test_notifier.py:12`**
The only observable behavior change in `retryable_status` is that 429 became retryable (`status in (429, 503)` vs the old `status == 503`). The test asserts only `retryable_status(503)`, which was already true before the change; `test_rejections.sh` asserts only that 400 is *not* retryable. Nothing asserts `retryable_status(429)`.
- Concrete mutation: revert to `return status == 503`. Every test still passes, so the headline change is unguarded.
- Fix: add `assert retryable_status(429)` (and ideally `assert not retryable_status(400)` in the same file, so the "do not retry other statuses" promise is covered at the unit boundary too).

**2. `provider_retry_delay` test invents a fixture shape that contradicts the documented contract — `test_notifier.py:7-9,16`**
The spec states the provider exposes its delay through the `Retry-After` response header and that "its JSON response body is not part of our contract." The fake returns `{"body": {"retry_after_seconds": 20}}` and the implementation reads `response["body"]["retry_after_seconds"]`. The test derives its expectation from the implementation, not from the independent source of truth, so it locks in a behavior the spec explicitly excludes. It agrees with the defect rather than preventing it.
- Concrete mutation: fix the implementation to read the header (per spec) — the test fails, but the test is the wrong party. Conversely, any body-shape change the spec permits breaks the test for no product reason.
- Fix: model the real provider (a `Retry-After` header on the response) or drop this test until the function's contract is corrected. (The function itself reading the body is a spec violation for `spec-reviewer`; the test's job is not to enshrine it.)

**3. `schedule_retry` expectation recomputes the implementation — `test_notifier.py:15`**
`assert schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}` uses `retry_delay(2)` as the expected value. That is implementation-derived, not independent: any defect in `retry_delay` propagates into both sides of the comparison.
- Concrete mutation: change `retry_delay` to `10 * 2 ** attempt` (off-by-one). `retry_delay(2)` becomes 40, `schedule_retry` also returns 40, and the test still passes — the delay value is never actually pinned.
- Fix: assert against the hand-derived value from the spec: `{"retry": True, "delay": 20}`.

### Minor excess

**4. `assert Path("notifier.py").exists()` — `test_notifier.py:17`**
An existence check, not a product promise. The import on line 4 already proves the module exists and imports. Delete.

**5. `assert get_type_hints(retryable_status)["status"] is int` — `test_notifier.py:18`**
Duplicates what a type checker/static analysis already guarantees, and asserts on an internal annotation rather than a visible effect. Brittle and non-behavioral. Delete.

**6. `assert "def retry_message" in Path("notifier.py").read_text()` — `test_notifier.py:19`**
Internal-structure assertion; a rename or refactor that preserves behavior breaks it. Protects nothing observable. Delete.

**7. `assert retry_message(20) == "Retry scheduled in 20 seconds"` — `test_notifier.py:20`**
The spec explicitly says "the exact wording is not part of the product contract." This test pins wording that the contract permits changing, so it is brittle by definition. Delete (or, at most, assert the message is non-empty and mentions the delay — but even that is weak given the spec).

**8. Convoluted rewrite of `test_rejections.sh:4`**
The original `python3 -c '...; assert not retryable_status(400)'` was simpler and equivalent. The new `! python3 -c '...; raise SystemExit(0 if retryable_status(400) else 1)'` works (verified: it fails if 400 becomes retryable) but adds indirection with no benefit — `assert` in `-c` already produces a non-zero exit under `set -e`. Revert to the plain form.

### Good

- `retry_delay(1) == 10` and `retry_delay(3) == 40` (`test_notifier.py:13-14`) are hand-derived from the spec's 10/20/40 table and independent of the implementation. Attempt 2 (20) is untested, but the two endpoints adequately pin the formula; not worth a separate assertion.
- `test_rejections.sh` still genuinely protects the "400 is not retryable" promise (the negation logic is correct, just needlessly ornate).

Net: the new 429 behavior and the provider-delay contract are the two real promises here, and neither is currently protected by an independent test. The rest of the added assertions are mostly non-promise or implementation-derived and should be trimmed.
