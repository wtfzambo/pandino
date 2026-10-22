## Verdict
changes needed

## Findings
### must-fix
- `test_notifier.py:7-16` | demonstrated defect | The fake supplies a JSON-body delay, but the documented provider contract supplies a `Retry-After` header; the passing test agrees with the implementation’s wrong response shape. | Use a header-shaped boundary fake and assert the returned delay. | Promise: provider retry timing comes from the header; a provider response with only that header would expose the defect.
- `test_rejections.sh:4` | incomplete coverage | Shell `!` treats any Python failure as success, including an import error or exception before the 400 result is checked. | Assert the negative result inside Python and let failures propagate. | Promise: status 400 is not retried; making `retryable_status(400)` raise would falsely pass this test.
- `test_notifier.py:12` | incomplete coverage | The newly supported 429 status has no test. | Assert that a 429 schedules a retry. | Promise: 429 triggers retry; removing `429` from `retryable_status` would leave the tests green.
- `test_notifier.py:15` | incomplete coverage | The attempt-two expectation calls `retry_delay(2)`, so it cannot verify the specified 20 seconds. | Compare the scheduled delay with the independent value `20`. | Promise: attempt two waits 20 seconds; returning 999 for attempt two would leave this assertion green.

### minor
- `test_notifier.py:17-19` | plausible risk | File existence, source-text, and annotation assertions duplicate checks or pin the test to implementation details. | Delete these assertions. | Deleting them removes excess without losing observable-behavior protection.
- `test_notifier.py:20` | plausible risk | Exact message wording is not part of the documented contract. | Check that the reported retry and delay are conveyed without requiring this sentence verbatim. | Changing only the wording would otherwise fail a test despite preserving the promise.

## Good
- The attempt-one and attempt-three checks use independent expected delays, and the existing 503 check still exercises a retryable status.

## Coverage
- Checked: Working diff, baseline tests, notification contract, and both test scripts; both scripts pass.
- Unverified: No live provider integration was available; the documented header contract was used to assess the fake.
- Turns: 7 of unspecified budget; timed-out commands: none.
