## Verdict
changes needed

## Findings
### must-fix
- `test_rejections.sh:4` | demonstrated defect | The negated Python command is exempt from `set -e`, so the script prints PASS and exits zero even when HTTP 400 is retryable or Python raises an exception. | Use a normal Python assertion whose failure propagates to the script’s exit status. | Promise: non-retryable statuses are rejected; substituting `True` for `retryable_status(400)` still passes.
- `test_notifier.py:9` | demonstrated defect | The provider fake supplies a JSON-body field that `docs/notification-spec.md` explicitly excludes from the contract, making the test agree with the implementation’s wrong data source. A header-only response instead raises `KeyError`. | Use a provider-boundary fixture exposing `Retry-After` and assert that its value determines the delay independently of the body. | Promise: obtain the delay from the response header; reading a body field instead must fail the test.
- `test_notifier.py:12` | incomplete coverage | No test covers the newly supported HTTP 429 response; reverting the implementation to retry only 503 leaves both scripts passing. | Add an explicit assertion that HTTP 429 is retryable. | Promise: rate-limited deliveries are retried; mutation: remove 429 from the accepted statuses.
- `test_notifier.py:15` | demonstrated defect | The scheduling expectation calls the same delay helper as the implementation, leaving the specified second-attempt delay unprotected. Returning 999 for attempt two passes both scripts. | Assert the independently specified result `{"retry": True, "delay": 20}`. | Promise: the second retry delay is 20 seconds; mutation: make `retry_delay(2)` return 999.

### minor
- `test_notifier.py:17–19` | plausible risk | File-existence, annotation-introspection, and source-text checks add structural constraints without protecting additional observable behavior; imports and behavioral calls already establish availability. | Delete these three assertions and their unused imports. | Excess removal: retain behavioral tests rather than file, annotation, or function-definition spelling checks.
- `test_notifier.py:20` | demonstrated defect | Exact wording is explicitly outside the product contract; a contract-preserving rewording fails this assertion. | Assert that the message communicates a scheduled retry without requiring the exact sentence. | Promise: report that a retry was scheduled; harmless wording changes should remain valid.

## Good
- Concrete first- and third-attempt expectations independently protect the specified 10- and 40-second delays.
- The small helper surface allows focused tests without elaborate mocking infrastructure.

## Coverage
- Checked: both existing scripts pass; in-memory mutations demonstrated missed 429 support, incorrect second-attempt delay, swallowed shell failures, and brittle wording. A header-only provider probe exposed the false fixture protection. `git diff --check` passed; repository files were unchanged.
- Unverified: no live provider integration was exercised; its concrete response-object API is not documented here. The required pickup skill file is absent.
- Turns: 9 of 12 (self-imposed); timed-out commands: none.
