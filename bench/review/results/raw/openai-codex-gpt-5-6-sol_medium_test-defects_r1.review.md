## Must-fix

- **`test_rejections.sh:4` — non-retryable statuses must be rejected.**  
  `!` suppresses `set -e` handling, so the script prints PASS regardless of the Python command’s result. Mutating `retryable_status(400)` to return `True` still passes. Replace this with a direct Python assertion or explicitly inspect the exit status.

- **`test_notifier.py:12` — HTTP 429 must trigger retries.**  
  The new 429 behavior has no evidence. Reverting `retryable_status` to only accept 503 leaves all tests green. Add an independent assertion for 429.

- **`test_notifier.py:15` — attempt two must delay exactly 20 seconds.**  
  The expected delay calls `retry_delay(2)`, reproducing the implementation rather than the documented contract. A mutation returning 30 for attempt two passes. Assert the hand-derived value `20`.

- **`test_notifier.py:15` — scheduling must preserve rejection behavior.**  
  Only a positive schedule is tested. Mutating `schedule_retry` to always return `"retry": True` passes. Exercise a non-retryable status through `schedule_retry` and assert its retry decision is false.

- **`test_notifier.py:7-16` — provider delay comes from the `Retry-After` header.**  
  The fake invents a JSON body contract explicitly contradicted by `docs/notification-spec.md:5`, so it validates the implementation defect. Use a boundary fixture exposing `headers["Retry-After"]`; the current implementation should then fail.

## Minor excess

- **`test_notifier.py:17-19` — file existence, annotation introspection, and source-text checks.**  
  Importing and behavior tests already establish availability; source inspection is brittle and annotations are not an observable product promise here. Delete these assertions.

- **`test_notifier.py:20` — exact retry-message wording.**  
  `docs/notification-spec.md:6` explicitly says wording is not contractual. A harmless punctuation or phrasing change would fail. Assert only the promised semantics, not exact text.

## Good

- **`test_notifier.py:13-14`** independently checks documented delays for attempts one and three with fixed expected values. Existing tests execute successfully, but the gaps above currently allow major contract violations to pass.
