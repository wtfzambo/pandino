## Findings

### Must-fix

**1. `test_rejections.sh:4` — assertion is inert, script always reports PASS**
The `!`-prefixed command disables bash's `set -e` for that statement regardless of the exit code it produces, so a failing assertion no longer aborts the script. Verified empirically: mutating `retryable_status` to always return `True` (so status 400 is wrongly treated as retryable) still produces `test_rejections: PASS`.
```
$ sed 's/status in (429, 503)/True/' notifier.py > notifier.py  # simulate bug
$ ./test_rejections.sh
test_rejections: PASS   # should have failed
```
Fix: drop the negation and rely on `assert`'s own failure to trip `set -e`, as the pre-diff version did:
`python3 -c 'from notifier import retryable_status; assert not retryable_status(400)'`.

**2. Missing coverage for the actual behavior change: `retryable_status(429)`**
`notifier.py:5` changes `status == 503` to `status in (429, 503)` — per `docs/notification-spec.md`, "Retry delivery after HTTP 429 or 503." No assertion anywhere exercises 429. Concrete mutation: revert `notifier.py:5` to `return status == 503`; `test_notifier.py` and `test_rejections.sh` both still pass, silently losing protection for the one new behavior this diff introduces.

**3. `test_notifier.py:7-9,16` — fake provider shape contradicts the documented contract**
`docs/notification-spec.md` states: "The mail provider exposes its retry delay through the `Retry-After` response header; its JSON response body is not part of our contract." `FakeMailProvider` and the assertion invent a body shape (`{"body": {"retry_after_seconds": 20}}`) that matches `notifier.py:16-18`'s (spec-contradicting) implementation rather than the documented external contract. This is a self-referential fixture: it can't fail under the actual defect it should be guarding against (reading the wrong field of the provider response) because both fixture and implementation share the same invented shape. Flag to spec-reviewer as a likely spec violation in `provider_retry_delay`; as evidence, this test currently proves nothing about real provider behavior.

### Minor excess

**4. `test_notifier.py:20` — pins exact wording the spec disclaims**
The spec: "the exact wording is not part of the product contract," yet the test asserts `retry_message(20) == "Retry scheduled in 20 seconds"` verbatim. Any copy change breaks a passing test. Weaken to something that reflects the actual promise (e.g., the delay value appears in the message) or drop.

**5. `test_notifier.py:17` — `Path("notifier.py").exists()` is dead weight**
The `from notifier import ...` at the top of the file already fails loudly if the module is missing; this assertion can never catch anything the import wouldn't.

**6. `test_notifier.py:18` — `get_type_hints(...)["status"] is int` duplicates the type checker**
This is a static-typing claim checked more cheaply and completely by mypy/pyright; it doesn't protect a runtime promise and should be removed per AGENTS.md ("do not duplicate cheaper guarantees with a test").

**7. `test_notifier.py:19` — source-text grep is a brittle internal-structure check**
`"def retry_message" in Path("notifier.py").read_text()` tests file contents, not behavior, and is already subsumed by the successful `from notifier import ... retry_message` import at the top of the file.

**8. `test_notifier.py:15` — expected delay derived from the implementation, not the spec**
`schedule_retry(503, 2)`'s expected delay is computed as `retry_delay(2)` instead of the spec-documented value `20`. It still catches wiring bugs (e.g., swapped arguments), so not false protection, but hardcoding `20` from the documented contract (10/20/40 for attempts 1/2/3) would be a strictly independent oracle.

### Good
`test_notifier.py:13-14` (`retry_delay(1) == 10`, `retry_delay(3) == 40`) derive expectations directly from the documented contract and would fail under a plausible off-by-one mutation (e.g. `10 * 2 ** attempt`).
