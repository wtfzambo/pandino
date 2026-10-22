## Verdict
changes needed

## Findings

### must-fix
- `test_rejections.sh:4` | demonstrated defect | The `!` prefix makes the command's failure exempt from `set -e`, so the script exits 0 whether or not 400 is retried. Verified: with `status in (400, 429, 503)` the script still prints `test_rejections: PASS` (rc=0), while the `HEAD` version correctly failed with `AssertionError`. The one non-retryable-status assertion in the suite is now vacuous. | Restore `python3 -c 'from notifier import retryable_status; assert not retryable_status(400)'` (`set -e` already aborts on failure) or use an explicit `if ...; then exit 1; fi`. | Promise: "Do not retry other statuses"; mutation `status in (400, 429, 503)` passes today.
- `test_notifier.py:12` | incomplete coverage | Adding 429 is the behavior change under review, yet only 503 is asserted. Verified: mutating `notifier.py` to `status in (503,)` leaves both suites passing. | Assert `retryable_status(429)` (plus `not 400` as the paired case) through the public function. | Promise: "Retry delivery after HTTP 429"; mutation `status in (503,)` passes.
- `test_notifier.py:7-9,16` | false protection | `FakeMailProvider` returns `{"body": {"retry_after_seconds": 20}}`, a shape the spec explicitly excludes ("its JSON response body is not part of our contract"). The fake licenses the wrong implementation and blocks the right one: switching `provider_retry_delay` to read the documented `Retry-After` header makes the suite raise `AttributeError: 'dict' object has no attribute 'headers'` instead of validating it. | Rebuild the fake from the provider's documented contract (a response carrying a `Retry-After` header, string value like `"20"`) and assert the converted `20`. | Promise: delay comes from the `Retry-After` header; mutation to body-JSON passes, spec-correct header read fails.

### minor
- `test_notifier.py:15` | false protection | The expected delay is computed by the code under test (`retry_delay(2)`), so the promised 20 s for attempt two is never compared to the spec; verified that special-casing attempt two to `25` still passes. The same line never exercises a non-retryable status, so `"retry": True` unconditionally also passes. | Assert `schedule_retry(429, 2) == {"retry": True, "delay": 20}` and `schedule_retry(400, 1)["retry"] is False`. | Promise: attempts one/two/three are 10/20/40 and only 429/503 retry; both mutations above pass today.
- `test_notifier.py:20` | excess | The spec states the exact wording is not part of the contract, so this assertion pins a free choice and fails on a harmless reword. | Assert only a contract-relevant aspect (e.g. the delay appears in the message) or delete the assertion. | Change: delete/replace the wording assertion.
- `test_notifier.py:17,19` | excess | `Path("notifier.py").exists()` and the `"def retry_message" in read_text()` substring duplicate what a successful import already proves and pin file layout; neither can detect a broken `retry_message`. | Delete both assertions and the `Path` import. | Change: delete the existence and source-text checks.
- `test_notifier.py:18` | excess | Asserting on `get_type_hints(...)["status"] is int` checks an annotation, not observable behavior; it also fails on a legitimate parameter rename and substitutes for a type checker. | Delete the assertion and the `get_type_hints` import. | Change: delete; contract typing belongs to the type checker.

## Good
- `retry_delay(1) == 10` and `retry_delay(3) == 40` take their expectations directly from the spec, so the exponential rule is genuinely protected at both ends.
- Both suites run fast and need no external services; the negative-status check belonged in the suite before this change and still does.

## Coverage
- Checked: working diff against `docs/notification-spec.md` and `HEAD`; ran `python3 test_notifier.py` and `bash test_rejections.sh` (both PASS); ran five mutations in throwaway copies outside the repository — drop 429, replace body read with `Retry-After` header, special-case attempt two, force `"retry": True`, retry 400 — only the attempt-two and forced-retry mutations were detected, and the 400 mutation was *not* detected by the new shell script but *was* by the `HEAD` script.
- Unverified: no linter, type checker, or pytest config exists in the repo, so annotation/typing claims are unsupported by tooling; the provider's real response type (header casing, string vs numeric header value) is only known from the spec line, not a fixture.
- Turns: 9 tool calls, brief specifies no budget; timed-out commands: none. The first test run created `__pycache__/`; I deleted it, so the tree is back to the three modified files.
