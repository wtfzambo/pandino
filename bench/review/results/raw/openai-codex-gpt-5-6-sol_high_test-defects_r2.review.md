## Must-fix

- **`test_rejections.sh:4` — non-retryable statuses must be rejected.**  
  The leading `!` suppresses `errexit`; the script prints PASS and exits 0 even when `retryable_status(400)` returns `True`. Mutation: add `400` to the retryable statuses—the test still passes. Restore a direct failing assertion such as `assert not retryable_status(400)`.

- **`test_notifier.py:12` — HTTP 429 must be retryable.**  
  The newly added behavior has no regression evidence. Mutation: revert `retryable_status` to `status == 503`; every current test passes. Add an independently expected 429 case, preferably through the stable scheduling boundary.

- **`test_notifier.py:15` — attempt two must delay 20 seconds.**  
  The expected value calls `retry_delay(2)`, so it reproduces the implementation. Mutation: return `30` specifically for attempt two; both actual and expected become 30. Assert the documented literal `20`, e.g. `{"retry": True, "delay": 20}`.

- **`test_notifier.py:7-16` — provider delay comes from the `Retry-After` header.**  
  The fake invents a JSON-body contract and therefore confirms the current defect rather than the documented boundary. Mutation: continue reading `body.retry_after_seconds`—the test passes despite violating the specification. Use a contract-backed response fixture containing only `Retry-After` (normally a string) and assert it becomes integer `20`.

## Minor excess

- **`test_notifier.py:17-19` — module existence, annotation, and source-text checks.**  
  These do not protect observable behavior and are brittle or duplicated by imports/static tooling. Delete them.

- **`test_notifier.py:20` — retry-report wording.**  
  Exact wording is explicitly outside the product contract. A harmless copy edit would fail this test. Weaken it to durable semantics, such as including the delay, or test reporting at its observable boundary.

## Good

The direct 503 check and independently derived 10/40-second assertions protect documented behavior. Both test scripts currently run, though the shell rejection test is a false pass as noted above.
