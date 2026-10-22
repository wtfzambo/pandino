## Verdict
changes needed

## Findings
### must-fix
- `test_rejections.sh:4` | demonstrated defect | The negated command is exempt from `set -e`, and the final `echo` makes the script succeed even when the rejection check fails. Stand-ins returning either 0 (incorrectly retrying HTTP 400) or 2 (Python failure) both produced PASS and exit 0. | Restore a direct assertion whose failure propagates to the script’s exit status. | Promise: non-retryable statuses are rejected; mutation: make `retryable_status(400)` return `True`.

- `test_notifier.py:7-9,16` | demonstrated defect | The provider fake invents a JSON-body contract, although the specification explicitly requires the `Retry-After` response header. The test passes alongside the implementation’s incorrect body lookup; a header-only probe raises `KeyError('body')`. | Use a fake reflecting the documented header boundary and assert that its value determines the returned delay, without requiring a JSON body. | Promise: provider retry delays come from `Retry-After`; mutation: read the body instead of the header, as the current implementation does.

- `test_notifier.py:12` | incomplete coverage | The newly supported HTTP 429 path has no assertion; the only positive status case remains 503. | Add a contract-derived assertion that HTTP 429 is retryable. | Promise: rate-limited deliveries are retried; mutation: revert `retryable_status` to `status == 503`, and the existing tests still pass.

- `test_notifier.py:15` | incomplete coverage | The second-attempt expectation calls `retry_delay(2)`, the same helper used by `schedule_retry`, so it cannot independently establish the specified 20-second delay. Attempts one and three are checked independently, but attempt two is not. | Assert the literal contract result `{"retry": True, "delay": 20}` for this case. | Promise: the second retry waits 20 seconds; mutation: return 30 only for attempt two, and all current assertions still pass.

### minor
- `test_notifier.py:17-19` | demonstrated defect | File-existence, annotation-identity, and source-text assertions add no observable behavioral protection beyond imports, calls, and appropriate static tooling; the source-text assertion also blocks valid refactoring. | Delete these assertions and their unused imports. | Excess removal: delete the three structural assertions while retaining behavioral checks.

- `test_notifier.py:20` | demonstrated defect | Exact message equality freezes wording that the specification explicitly leaves unconstrained. | Check only that the message communicates a scheduled retry, without requiring this exact sentence. | Promise: users are told a retry was scheduled; change: allow equivalent wording such as “Retry scheduled; waiting 20 seconds.”

## Good
- The first- and third-attempt delay assertions use independent values from the specification.
- The behavioral checks exercise public functions through small, direct inputs.

## Coverage
- Checked: full working diff, notification contract, implementation, and tests. Both existing test scripts pass; the header-only probe exposes the provider mismatch; shell stand-ins confirm swallowed failures. `git diff --check` passes.
- Unverified: live-provider integration and regression-first history. No repository files were changed.
- Turns: 4 of unspecified budget; timed-out commands: none.
