## Verdict
changes needed

## Findings
### must-fix
- `test_rejections.sh:4` | demonstrated defect | The negated command is exempt from `set -e`; even when it fails because HTTP 400 is incorrectly retryable, the following `echo` returns success. A read-only probe confirmed exit 0 and `PASS` with the Python command forced to return 0. | Restore a direct Python assertion whose failure propagates to the script exit status. | Promise: HTTP 400 is not retried; mutation: make `retryable_status(400)` return `True`.

- `test_notifier.py:12` | incomplete coverage | Nothing exercises the newly supported HTTP 429 case; reverting the implementation to support only 503 still passes the Python tests. | Add an explicit assertion that HTTP 429 is retryable. | Promise: rate-limited deliveries are retried; mutation: replace the status predicate with `status == 503`.

- `test_notifier.py:15` | demonstrated defect | The expected scheduled delay is calculated using the same helper as the implementation, and attempt two has no independent expectation. An in-memory mutation returning 999 seconds for attempt two passes all Python tests. | Assert the contract’s literal 20-second delay for attempt two, preferably through `schedule_retry`. | Promise: retry delays are 10, 20, and 40 seconds; mutation: return 999 for attempt two.

- `test_notifier.py:7-16` | demonstrated defect | The fake supplies a JSON-body field expressly excluded from the documented provider contract, so the test endorses the implementation’s wrong source for retry timing. | Use an independently verified provider response fixture exposing `Retry-After` and assert that its value determines the delay without requiring a JSON-body field. | Promise: provider retry timing comes from the response header; mutation: read `body.retry_after_seconds` instead of `Retry-After`—the current test already accepts this defect.

### minor
- `test_notifier.py:17-20` | demonstrated defect | File existence, source-text matching, and annotation introspection add no behavioral protection beyond importing and exercising the API; exact message wording is explicitly outside the product contract. | Remove the structural checks and replace exact wording equality with a check of the promised scheduled-retry report. | Remove lines 17–19 and relax line 20 so an equivalent public import or wording change does not fail otherwise-correct behavior.

## Good
- The attempt-one and attempt-three assertions use independent, contract-derived expected values.
- The tests exercise public helper functions without mocking their internal implementation.

## Coverage
- Checked: shipping-code purpose and documented retry contract; complete working diff; both test scripts passed; shell syntax and `git diff --check` passed. Read-only probes demonstrated surviving status/delay mutations and the shell’s false success.
- Unverified: the real provider’s response-object shape is not documented here; its fixture must be verified independently rather than invented. No repository files were changed.
- Turns: 6 of unspecified; timed-out commands: none.
