## Findings

### Must-fix

**1. `test_notifier.py` — no test for `retryable_status(429)`**
`notifier.py:5` adds 429 to the retryable set (the actual observable behavior change in this diff), but the test suite still only asserts `retryable_status(503)` (unchanged from before) and `test_rejections.sh` only checks 400. Revert the 429 addition in `retryable_status` and every test still passes — the primary change of this diff has zero protection.
Mutation: change `status in (429, 503)` back to `status == 503`. Nothing fails.

**2. `test_notifier.py:15` — `schedule_retry` assertion is tautological, not independently derived**
```python
assert schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}
```
The expected `delay` is computed by calling the very function under test (`retry_delay`) rather than a hand-derived value from the spec (`docs/notification-spec.md:2`: attempt 2 → 20 seconds). This violates the "independent source of truth" requirement and hides bugs specific to `attempt=2`.
Mutation: make `retry_delay` special-case `attempt == 2` to return a wrong value (e.g. `99`) while keeping `retry_delay(1)==10` and `retry_delay(3)==40` correct. The `schedule_retry` assertion still passes because both sides call the same buggy function.
Fix: assert `schedule_retry(503, 2) == {"retry": True, "delay": 20}`, using the spec's literal value.

**3. `test_notifier.py:7-9,16` and `notifier.py:16-18` — `provider_retry_delay` is tested against an invented fixture shape that contradicts the documented contract**
`docs/notification-spec.md:4` states: "The mail provider exposes its retry delay through the `Retry-After` response header; its JSON response body is not part of our contract." The implementation reads `response["body"]["retry_after_seconds"]`, and `FakeMailProvider.post` is hand-built to match exactly that shape. This is a classic invented-provider-fixture: the fake only confirms the implementation's own assumption, not real provider behavior, so it proves nothing about the actual integration and would pass even though the code reads a contractually-unsupported field. (Correctness of the choice is spec-reviewer's call, but as evidence this test is worthless — it can't fail under the real defect it's meant to guard against.)
Mutation: none needed — the test is falsely protective by construction; it agrees with the very defect it should catch.

### Minor excess

**4. `test_notifier.py:17` — `Path("notifier.py").exists()`**
Trivial existence check with no behavioral value; if the module didn't exist the imports on line 4 would already fail with `ImportError`. Delete.

**5. `test_notifier.py:18` — `get_type_hints(retryable_status)["status"] is int`**
Duplicates what a type checker (mypy/pyright) already guarantees statically for an unchanged signature, and the annotation isn't part of any product promise. Not a behavior test. Delete.

**6. `test_notifier.py:19` — `"def retry_message" in Path("notifier.py").read_text()`**
A textual/structural grep against source code, not a call-and-assert on behavior. Brittle (breaks on any harmless reformatting, e.g. adding a type alias or moving the function) and redundant with the next line, which actually calls `retry_message` and checks its result. Delete.

**7. `test_notifier.py:20` — asserts exact wording of `retry_message`**
`docs/notification-spec.md:5` explicitly says "the exact wording is not part of the product contract." Asserting `retry_message(20) == "Retry scheduled in 20 seconds"` locks in wording the spec disclaims, making the test needlessly brittle to a copy change that is not a bug. Loosen to something that only checks the promised content, e.g. that the string contains `"20"`, or drop the literal-text assertion and just assert `isinstance(retry_message(20), str)` if the only real promise is "something is reported."

**8. `test_rejections.sh` — needlessly convoluted double-negation**
```bash
! python3 -c 'from notifier import retryable_status; raise SystemExit(0 if retryable_status(400) else 1)'
```
The original `assert not retryable_status(400)` was simpler and equally effective (an `AssertionError` on a wrong result gives a non-zero exit, which is what `set -e` needs to fail the script). The rewrite adds a `SystemExit`/`!` double negation with no gain in protection or clarity — same coverage, harder to read.

### Good
`retry_delay(1) == 10` and `retry_delay(3) == 40` (test_notifier.py:13-14) are correctly hand-derived from the spec's documented attempt/delay table and would catch a real formula defect (e.g. wrong base or exponent).
