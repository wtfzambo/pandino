## Test Review — Working Diff Analysis

### Observable Behavior Changes

The diff adds five new functions to the notifier module and expands the behavior of one existing function:

1. **`retryable_status()` expansion**: Now recognizes both 429 (rate limit) and 503 (service unavailable), not just 503.
2. **`retry_delay(attempt)` (new)**: Computes exponential backoff: 10 * 2^(attempt-1).
3. **`schedule_retry()` (new)**: Combines status and attempt into a structured retry decision.
4. **`provider_retry_delay()` (new)**: Extracts retry delay from a provider's response object.
5. **`retry_message()` (new)**: Formats a delay as a human-readable string.

### Test Evidence Review

**must-fix: `test_notifier.py:14–15` — False protection via implementation-derived test**

`test_notifier.py:14` asserts `retry_delay(1) == 10` and line 15 asserts `retry_delay(3) == 40`. These expectations are recomputed directly from the implementation (`10 * 2 ** (attempt - 1)`), not from an independent specification or contract. If the implementation's formula is wrong, the test passes by construction. 

**Mutation that would evade these tests**: Change the formula to `return 11 * 2 ** (attempt - 1)` — both assertions would fail with different values (11 and 44), and a developer could "fix" them by recomputing inside the test. The test does not protect a documented delay contract; it only confirms internal consistency.

Expected values for backoff functions should derive from their intended behavior, not their implementation. What is the actual business promise? Is it "10-second base with exponential growth" or "something that roughly doubles"? Until that's specified, the test provides no independent protection.

---

**must-fix: `test_notifier.py:16–17` — Mocked external boundary untested; invented fixture**

Line 16 asserts `schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}`. The expectation reinvokes `retry_delay(2)` inside the test, recomputing the exact same value. This is not independent verification; it confirms only that `schedule_retry()` correctly wraps and calls `retry_delay()`.

More critically, line 17: `provider_retry_delay(FakeMailProvider(), "hello") == 20`. The test uses `FakeMailProvider`, which is an invented mock that returns a hardcoded shape `{"body": {"retry_after_seconds": 20}}`. This shape is never validated against a real provider's contract. If the actual mail provider returns a different key, structure, or field name, the code would fail in production. The test passes only because it confirms `provider_retry_delay()` calls `provider.post()` and indexes into the invented structure—this is a mock that only confirms internal call structure, not a coarse boundary fixture that validates against a real system.

**Mutation**: Rename the provider's response key from `"retry_after_seconds"` to `"retry_delay_seconds"`. The test still passes because it doesn't consult reality; production code breaks.

---

**minor excess: `test_notifier.py:19–20` — Static checks duplicated as tests**

Lines 19–20 assert:
- `Path("notifier.py").exists()` — file existence
- `get_type_hints(retryable_status)["status"] is int` — type annotation presence

Both are guaranteed by static analysis. The file must exist for the import on line 2 to succeed (would raise `ModuleNotFoundError`). The type annotation `status: int` is checked by `mypy` or the IDE. These are redundant; a broken module fails the test run before these assertions execute.

**Proposal**: Remove these two assertions. They add no value over static guarantees already cheaper.

---

**minor excess: `test_notifier.py:21` — Implementation structure assertion**

`assert "def retry_message" in Path("notifier.py").read_text()` checks for the presence of the string `"def retry_message"` in the source file. This protects nothing about behavior. It only confirms that a function with that name exists as text in the file. If the function is dead code, removed entirely, or renamed without updating the module's public exports, this test's failure would not correspond to a broken promise.

This is brittle wording that couples the test to implementation detail (the source file's exact structure). It would survive a refactor that renamed the function or moved it to a different module, as long as the string remains in some file.

**Proposal**: Remove this assertion. If `retry_message()` is truly part of the contract, it should be tested by calling it and checking its output—which is already done on line 22.

---

**good**: `test_notifier.py:22` and `test_rejections.sh` — Core behavior protected

- `test_notifier.py:22` (`assert retry_message(20) == "Retry scheduled in 20 seconds"`) is a proper call-and-assert; it's independent, observable, and would catch a typo in the string format.
- `test_rejections.sh` now correctly inverts the test to verify that status 400 is **not** retryable (refactored from the old version that would have silently passed if `retryable_status(400)` returned `True`). The `!` operator ensures the assertion fails if retryable_status returns True. This protects the observable promise that 400 is rejected.

---

## Summary

**Must-fix issues:**
1. **`test_notifier.py:14–15`** — Delay formula expects are recomputed from implementation; no independent contract. Mutation: change formula to `11 * 2 ** (attempt - 1)`.
2. **`test_notifier.py:17`** — `provider_retry_delay()` tested with invented mock shape never validated against real provider. Mutation: rename response key to `"retry_delay_seconds"`.

**Minor excess to remove:**
3. **`test_notifier.py:19–20`** — File existence and type-hint assertions are redundant (static guarantees). Proposal: delete.
4. **`test_notifier.py:21`** — String-match assertion on source file is brittle and tests implementation, not behavior. Proposal: delete.

The diff contains real regression protection (the 429/503 distinction and the rejection of other statuses), but the new function tests are weakened by recomputed expectations and invented external fixtures.
