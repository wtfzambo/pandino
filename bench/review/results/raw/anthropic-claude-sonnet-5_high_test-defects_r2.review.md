## Review of uncommitted diff (test evidence only)

**Files touched:** `notifier.py`, `test_notifier.py`, `test_rejections.sh`
**Doc contract:** `docs/notification-spec.md` — retry on 429/503 only; delays 10/20/40 for attempts 1/2/3; provider delay comes from `Retry-After` **header**, JSON body not in contract; exact retry-message wording not in contract.

### Must-fix

**1. `test_rejections.sh:4` — negated command silently defeats `set -e`; the test can never fail.**
The rewrite `! python3 -c '...raise SystemExit(...)'` relies on bash negating the exit status under `set -euo pipefail`. POSIX/bash explicitly exempt `!`-negated commands from triggering `errexit` on failure. I verified this directly:
```
mutated notifier.py: retryable_status(status) -> True   # 400 now "retryable" — a real regression
$ bash test_rejections.sh
test_rejections: PASS   # exit 0
```
The old script (`assert not retryable_status(400)` inside `python3 -c`, no negation) correctly failed (exit 1) on the same mutation. This is a regression in test-infrastructure quality, not just style — the script now provides **zero protection**, contrary to its own name and echoed "PASS". Fix: revert to a form where failure actually propagates, e.g. `python3 -c 'from notifier import retryable_status; assert not retryable_status(400)'`.

**2. `test_notifier.py` — missing protection for the actual bug fix (429 added as retryable).**
The diff's core behavior change is `retryable_status` now accepting 429. No test asserts `retryable_status(429)` is true. I mutated `notifier.py` back to `status == 503` only (429 unsupported) and reran both suites — both still printed PASS:
```
test_notifier.py mutation(no 429) -> exit 0  PASS
test_rejections.sh mutation(no 429) -> exit 0 PASS
```
Combined with finding 1, there is currently **no automated evidence at all** for the 429 behavior this diff introduces. Add `assert retryable_status(429)`.

**3. `test_notifier.py` — `FakeMailProvider` invents an external-provider fixture shape that contradicts the documented contract.**
`docs/notification-spec.md` states the provider exposes retry delay via the `Retry-After` response **header**; "its JSON response body is not part of our contract." The test's fixture (`{"body": {"retry_after_seconds": 20}}`) and `provider_retry_delay`'s implementation both invent a body-based shape that isn't the documented external contract. This is exactly the "invented external-provider fixture shapes" pattern called out as false protection — it passes by construction against a shape nobody has confirmed the real provider uses, and it doesn't match the actual documented contract. This is also a likely spec bug (worth flagging to spec-reviewer), but as test evidence it proves nothing about real integration behavior.

**4. `test_notifier.py` — `retry_message` wording assertion tests a promise the docs explicitly disclaim.**
`assert retry_message(20) == "Retry scheduled in 20 seconds"` pins exact copy, but the spec says "the exact wording is not part of the product contract." This test will break on any non-buggy wording change, asserting an unpromised behavior as if it were guaranteed.

### Minor excess

- `assert Path("notifier.py").exists()` — redundant; the preceding `from notifier import ...` already requires the module to exist, or the whole script would have failed at import time.
- `assert get_type_hints(retryable_status)["status"] is int` — duplicates what a type checker (mypy/pyright) already guarantees; per AGENTS.md this should not be re-proven by a runtime test.
- `assert "def retry_message" in Path("notifier.py").read_text()` — brittle internal-structure/text assertion, not an observable promise; the functional assertion on the next line already exercises `retry_message` directly and is a strictly stronger check.
- `schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}` — the `"delay"` half recomputes the implementation via the same `retry_delay` function rather than the doc-derived value (20 seconds for attempt 2), so it passes by construction for that half. Only `"retry": True` is independently meaningful here. Recommend `{"retry": True, "delay": 20}` using the doc's hand-derived value.

### Good

- `retry_delay(1) == 10` and `retry_delay(3) == 40` are correctly hand-derived from the documented delay sequence (10/20/40) and would catch a plausible mutation in the base delay or exponent.
- Keeping the pre-existing `assert retryable_status(503)` check is appropriate — cheap, still valid regression coverage.

Net: this diff needs a fix to `test_rejections.sh`'s negation bug, a positive assertion for `retryable_status(429)`, and either removal or rework of the provider/message assertions before it provides real protection for the stated behavior change.
