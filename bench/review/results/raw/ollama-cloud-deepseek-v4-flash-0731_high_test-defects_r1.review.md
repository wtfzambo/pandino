All findings verified by running the suite against mutations. Ordered by severity:

## Must-fix

**1. The diff's core behavior change (429 retryable) is completely unpinned — the pre-diff defect passes the whole suite.** `notifier.py:5`, `test_notifier.py:12`
The only behavioral change to `retryable_status` is adding 429, yet no test asserts `retryable_status(429)`. I ran the full suite against the base implementation (`return status == 503`): `test_notifier: PASS`, rejection check passes. Concrete mutation: revert line 5 to `return status == 503` — every test is green while the spec promise "Retry delivery after HTTP 429 or 503" is broken. The negative case (`test_rejections.sh`) covers 400 only, and the 503 positive covers the pre-existing case. Add `assert retryable_status(429)`.

**2. The `test_rejections.sh` rewrite neutralized crash detection — a broken module now passes.** `test_rejections.sh:4`
Old form (`python3 -c '...; assert not retryable_status(400)'` under `set -e`) failed on any Python crash, since python exits nonzero. The new `! python3 -c '...'` inverts *every* nonzero exit: an import error, syntax error, or module deletion now exits 1 → `!` → 0 → `echo "test_rejections: PASS"`. Verified: with `notifier.py` replaced by `raise ImportError`, the script exits 0 (old form exited 1). The inversion is asymmetric — it can't distinguish "400 correctly non-retryable" from "module is broken." Concrete mutation: delete `notifier.py`; the script still prints PASS. Keep the plain `assert` form, or restructure so failure is an explicit exit code that doesn't invert crash paths.

**3. `schedule_retry` test recomputes the implementation — passes by construction.** `test_notifier.py:15`
`{"retry": True, "delay": retry_delay(2)}` derives its expectation from the function under test, so a wrong `retry_delay` sails through: change the formula to `10 * 3 ** (attempt - 1)` (→ 10, 30, 90) and the assertion still holds, because both sides call the same buggy function. The spec's independent value for attempt two is 20 seconds — assert `{"retry": True, "delay": 20}` directly. (The adjacent `retry_delay(1) == 10` / `retry_delay(3) == 40` at lines 13–14 are the only independent pins on the exponential interpretation.)

**4. `provider_retry_delay` test certifies an invented provider shape the spec explicitly excludes.** `test_notifier.py:7-9, 16`, `notifier.py:16-18`
The spec says the delay comes from the `Retry-After` response header and "its JSON response body is not part of our contract." The implementation reads `response["body"]["retry_after_seconds"]`, and `FakeMailProvider` returns exactly that invented body — the test agrees with the defect rather than the contract. A real provider per the documented contract (header-based) would not work, and the test can't tell. Concrete mutation: keep the fake, change the implementation to read `response["body"]["retry_after_milliseconds"]` — the test still passes. The fake should expose a `Retry-After` header per the spec (this also exposes that the implementation itself reads the wrong source; that's a spec finding, but the evidence must not ratify it).

## Minor excess

- `test_notifier.py:20` — `retry_message(20) == "Retry scheduled in 20 seconds"` pins wording the spec explicitly declares non-contractual ("exact wording is not part of the product contract"). A spec-compliant reword breaks it. Delete, or assert only that a message was produced (e.g., truthy).
- `test_notifier.py:19` — `assert "def retry_message" in Path("notifier.py").read_text()` is implementation-derived source-text inspection; a rename or refactor breaks it with behavior intact. Delete.
- `test_notifier.py:18` — `get_type_hints(retryable_status)["status"] is int` duplicates what the annotation itself guarantees; static analysis is the cheaper guarantee. Delete.
- `test_notifier.py:17` — `Path("notifier.py").exists()` is an existence check with no observable promise. Delete.

## Good

- `test_notifier.py:13-14` — `retry_delay(1) == 10` and `retry_delay(3) == 40` use independent hand-derived spec values and pin the exponential interpretation (a linear 10/20/30 reading fails `retry_delay(3)`).
- `test_notifier.py:12` — `retryable_status(503)` protects the positive case at a stable cut point.
- The 400-negative rejection survives as a distinct check.

Net: the suite needs the four must-fix repairs before it earns its place; the remaining assertions are cheap to delete.
