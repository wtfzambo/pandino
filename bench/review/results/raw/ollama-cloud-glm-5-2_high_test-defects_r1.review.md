## Test review: uncommitted diff

Behavioral changes in the diff: `retryable_status` now also returns `True` for 429 (was 503-only); new functions `retry_delay`, `schedule_retry`, `provider_retry_delay`, `retry_message`. The authoritative contract is `docs/notification-spec.md`.

### Must-fix

**`test_notifier.py` — no positive test for the 429 behavior change.** The only behavioral change in `notifier.py` is "retry after HTTP 429", yet no assertion exercises `retryable_status(429)`. `test_rejections.sh` covers the negative 400 case; the existing 503 assertion predates this diff. A regression that reverts the tuple to `(503,)` would pass every current test. **Fix:** add `assert retryable_status(429)`. (Mutation that exposes the gap: `return status == 503` — every test stays green.)

**`test_notifier.py:provider_retry_delay` + `FakeMailProvider` — false protection via an invented provider shape.** The spec states the mail provider exposes its retry delay through the `Retry-After` *response header* and that "its JSON response body is not part of our contract." The test fakes the provider with `{"body": {"retry_after_seconds": 20}}` — the exact body path the implementation itself reads — and asserts `== 20`. The expectation is derived from the implementation, not from a real boundary fixture or the contract, so it proves only that the function echoes the field it chose to read. Mutation that passes this test while breaking real providers: change the function to read `response["body"]["retry_after_seconds"]` from any other body key and update the fake identically. This is the "invented external-provider fixture shape" the review standard rejects. **Fix:** delete the test, or rewrite `provider_retry_delay` and its fake against a shape the contract actually guarantees (a `Retry-After` header) — the latter belongs with spec-reviewer, but the test as written should not stand.

**`test_notifier.py:schedule_retry` — implementation-derived expectation.** `schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}` recomputes `retry_delay` in the assertion, so it passes by construction and detects nothing. The spec gives an independent value: attempt 2 → 20 seconds. Mutation that passes: change `retry_delay` to `10 * 3 ** (attempt-1)` and the test still agrees. **Fix:** assert `== {"retry": True, "delay": 20}` (and ideally a `schedule_retry(503, 3) == {..., "delay": 40}` case), values drawn from the spec, not the function.

### Minor excess

**`test_notifier.py:assert Path("notifier.py").exists()`** — existence is already guaranteed by the `from notifier import ...` line succeeding. Delete.

**`test_notifier.py:get_type_hints(retryable_status)["status"] is int`** — asserts a type annotation, i.e. internal structure, not an observable product promise; static type checking is the cheaper guarantee. Delete.

**`test_notifier.py:"def retry_message" in Path("notifier.py").read_text()`** — source-text structure; the import already proves the function exists. Delete.

**`test_notifier.py:retry_message(20) == "Retry scheduled in 20 seconds"`** — over-specifies exact wording that the spec explicitly marks as *not* part of the product contract ("the exact wording is not part of the product contract"). A legitimate rewording preserving behavior would break this test. **Fix:** relax to a contract-relevant property (e.g. `assert "20" in retry_message(20)`) or drop the assertion.

### Good

- `test_rejections.sh` rewrite is correct: `! python3 -c '...raise SystemExit(0 if retryable_status(400) else 1)'` fails precisely when 400 becomes retryable, and the `!` + `set -e` interaction is sound (negated non-zero does not trip `errexit`). It exercises an observable promise at a stable cut point and would fail under the plausible mutation `return True`.
- The 503 positive case remains covered and derives its expectation from the contract.
