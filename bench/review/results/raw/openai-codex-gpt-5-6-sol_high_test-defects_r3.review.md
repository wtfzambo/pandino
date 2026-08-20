## Must-fix

- **`test_rejections.sh:4` — non-retryable statuses must be rejected.** Bash disables `set -e` handling for commands preceded by `!`, so the script prints `PASS` whether Python exits successfully or unsuccessfully. Mutating `retryable_status()` to return `True` for HTTP 400 still passes. Restore a direct Python assertion or use an explicit `if ...; then exit 1; fi`.

- **`test_notifier.py:12-15` — HTTP 429 and 503, but no other statuses, must trigger retry at the scheduling boundary.** Only 503 is tested, and rejection only targets the helper. Removing 429 support or hardcoding `schedule_retry(...)[“retry”]` to `True` survives the current suite. Add independently expected scheduling assertions for 429 and a non-retryable status.

- **`test_notifier.py:15` — attempt two must delay exactly 20 seconds.** The expected value calls `retry_delay(2)`, the same implementation used by `schedule_retry`; returning an incorrect value specifically for attempt two still passes. Assert the contract value `20` directly.

- **`test_notifier.py:7-16` — provider delay comes from the `Retry-After` response header.** The fake invents a JSON-body contract and therefore validates the implementation defect rather than the documented provider boundary. A real-shaped response such as `{"headers": {"Retry-After": "20"}, "body": {}}` raises `KeyError`. Use a fixture derived from the documented header contract.

## Minor excess

- **`test_notifier.py:17-19` — module/function existence and annotations.** Imports already prove file and symbol availability; source-text inspection is brittle, and type checking is the cheaper annotation guarantee. Delete these assertions and their imports.

- **`test_notifier.py:20` — retry reporting.** Exact wording is explicitly outside the product contract. A harmless wording change would fail this test. Assert only stable semantics, such as communicating that retry is scheduled and including the delay.

## Good

- **`test_notifier.py:13-14`** uses hand-derived literal expectations for attempts one and three and would catch plausible backoff calculation defects.
- Existing test commands complete successfully, though the shell rejection test currently gives false protection.
