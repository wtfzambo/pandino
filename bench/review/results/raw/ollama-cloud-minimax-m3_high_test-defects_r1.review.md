Confirmed: dropping 429 from `retryable_status` — the central behavior change — passes the entire suite green. That is the headline regression-protection failure.

## Findings

### Must-fix

**`test_notifier.py:6` — `retryable_status(429)` not exercised**
The diff's primary behavior change is widening `retryable_status` from `{503}` to `{429, 503}`. No test asserts that 429 is retryable. The spec explicitly lists 429 as retryable. A plausible mutation (`return status == 503`) makes this regress with zero test failure. Add `assert retryable_status(429)`.

**`test_notifier.py:7` — `retry_delay(2)` not exercised against the spec value**
The test pins attempt 1 (=10) and attempt 3 (=40), which happen to flank the `2 ** (attempt - 1)` formula at non-adjacent points, but the spec calls out attempts one, two, and three with values 10, 20, 40. Attempt 2 is the only one whose expected value the test does not independently state. Add `assert retry_delay(2) == 20`.

**`test_notifier.py:8` — `schedule_retry` expectation is implementation-derived**
`assert schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}` recomputes the expected `delay` via the function-under-test. This passes by construction for `delay` and only exercises `retry` by accident. Pin both fields to independent values, e.g. `{"retry": True, "delay": 20}`. Also add the non-retry case: `assert schedule_retry(400, 1) == {"retry": False, "delay": 10}` — the existing `test_rejections.sh` covers `retryable_status(400)` in isolation but `schedule_retry` composes both halves and is not covered for the negative path.

### Minor excess

**`test_notifier.py:11` — `Path("notifier.py").exists()`**
The test imports `notifier` two lines above; the import itself fails if the file is missing. This is a tautological existence check. Delete.

**`test_notifier.py:12` — `get_type_hints(retryable_status)["status"] is int`**
A runtime re-check of what `mypy`/the type checker already guarantees at zero cost. This is exactly the "duplicate a cheaper static guarantee with a test" pattern. Delete.

**`test_notifier.py:13` — substring grep for `def retry_message`**
Brittle internal-structure assertion that breaks on any cosmetic edit (a comment, a docstring quoting the name) and is already covered by `retry_message(20) == ...` four lines below. Delete.

**`test_notifier.py:14` — `retry_message(20) == "Retry scheduled in 20 seconds"`**
Spec: "the exact wording is not part of the product contract." Pinning the exact string creates a brittle test for a promise the spec explicitly disclaims, and pushes future harmless wording tweaks into test failures. Either delete the assertion or relax to a contains-check on the delay number, e.g. `assert "20" in retry_message(20)`.

**`test_notifier.py:10` — `provider_retry_delay` test pins the wrong boundary**
The fake returns `{"body": {"retry_after_seconds": 20}}` and the implementation reads that body field. The spec states retry delay is exposed via the `Retry-After` *header* and explicitly says the JSON body shape is not part of the contract. This test entrenches an implementation that contradicts the spec. Not a test-reviewer call to fix the implementation, but the test should not be the thing that locks in the wrong contract shape — note it for the spec reviewer and consider dropping the test until the boundary matches the spec.

### Good

`test_rejections.sh` correctly inverts the python exit status and still proves 400 is not retryable. The `assert retry_delay(3) == 40` choice of attempt 3 is a genuine independent cross-check against the spec table (it would fail under `10 * attempt` or `10 * 2 ** attempt`).

### Summary

Headline issue: the central behavior change in this diff (adding 429) has **zero** regression protection. Three must-fix items (the 429 gap, the missing attempt-2 value, and the implementation-derived `schedule_retry` expectation) plus a false-protection issue (the wording assertion pinned against a spec that disclaims it) and four disproportionate existence/type/grep checks that should be deleted.
