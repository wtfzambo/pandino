## Test review

The diff adds retry helpers (`retryable_status` extended to 429, `retry_delay`, `schedule_retry`, `provider_retry_delay`, `retry_message`) and their tests. The governing contract is `docs/notification-spec.md`.

### Must-fix

**1. `test_notifier.py:16` — `provider_retry_delay` test invents a fixture shape that contradicts the documented contract (false protection).**

The spec states: *"The mail provider exposes its retry delay through the `Retry-After` response header; its JSON response body is not part of our contract."* The `FakeMailProvider` returns `{"body": {"retry_after_seconds": 20}}`, and the implementation reads `response["body"]["retry_after_seconds"]`. The fake is shaped to match the (incorrect) implementation, not the real provider, so the test passes by construction and masks the defect — the code reads the body instead of the header.

Concrete mutation that exposes the gap: change the fake to return a header-based response (e.g. `{"headers": {"Retry-After": "20"}}`). The test then fails, revealing that `provider_retry_delay` reads the wrong field. The fake must be derived from the real provider's documented shape, not invented to agree with the code.

**2. `test_notifier.py:12` / `test_rejections.sh:4` — the new 429 behavior is unprotected.**

The observable behavior change is "retry after 429 **or** 503." The only positive assertion is `retryable_status(503)` (pre-existing), and the shell test asserts 400 is *not* retryable. No test asserts `retryable_status(429)` is `True`. A mutation reverting `status in (429, 503)` to `status == 503` passes every test. This is the core new promise and it has no regression protection.

Concrete mutation: revert to `return status == 503` — all tests still pass. Add `assert retryable_status(429)`.

### Minor excess

**3. `test_notifier.py:17` — `assert Path("notifier.py").exists()`** protects no product promise; it's an existence check that can never meaningfully fail in a runnable repo.

**4. `test_notifier.py:18` — `assert get_type_hints(retryable_status)["status"] is int`** duplicates the type checker, which already proves the annotation. Per AGENTS.md, static analysis is the cheaper guarantee.

**5. `test_notifier.py:19` — `assert "def retry_message" in Path("notifier.py").read_text()`** is an internal-structure assertion; it breaks on any rename/refactor without protecting a visible behavior.

**6. `test_notifier.py:20` — `assert retry_message(20) == "Retry scheduled in 20 seconds"`** asserts exact wording that the spec explicitly declares *"not part of the product contract."* Brittle; a wording change is not a bug.

**7. `test_notifier.py:15` — `schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}`** recomputes `retry_delay(2)` inside the expectation, so the `delay` half passes by construction. The `retry: True` half is fine; the delay half should use a literal `20` (hand-derived from the spec) or be dropped.

**8. `test_rejections.sh:4` — the rewrite is needless complexity.** The original `assert not retryable_status(400)` was simpler and equivalent; the `! ... raise SystemExit(0 if ... else 1)` form adds indirection without adding protection.

### Good

- `retry_delay(1) == 10` and `retry_delay(3) == 40` are independent, hand-derived from the spec's 10/20/40 contract and would fail under a plausible formula defect.
- `retryable_status(503)` and the 400-rejection check correctly cover the "do not retry other statuses" half of the contract.

Net: the 429 regression protection (must-fix #2) and the header-vs-body fixture (must-fix #1) are the substantive gaps; the rest is removable noise.
