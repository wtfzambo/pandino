## Must-fix

- `test_notifier.py:12` — **HTTP 429 must be retryable.** No test exercises the newly added 429 behavior. Mutating `retryable_status` back to `status == 503` passes all tests. Add an assertion for 429 based on `docs/notification-spec.md:3`.

- `test_notifier.py:7-16` — **Provider delay comes from the `Retry-After` response header.** The fake invents a JSON-body shape and therefore validates the implementation defect instead of the documented boundary contract. A mutation reading `response["body"]["retry_after_seconds"]` currently passes—as the implementation demonstrates. Use a representative header-based response fixture and assert its parsed delay.

- `test_notifier.py:15` — **Scheduling must preserve the documented retry decision and 20-second second-attempt delay.** The expected delay is recomputed through `retry_delay(2)`, so changing attempt two to any wrong value passes both sides; hard-coding `schedule_retry` to always return `"retry": True` also survives current tests. Assert the independent literal result for `(503, 2)` and add a non-retryable scheduling case.

## Minor excess

- `test_notifier.py:17-19` — File existence, source-text inspection, and runtime annotation inspection do not protect observable product behavior and are brittle or cheaper to guarantee through normal tooling. Delete these assertions and their imports.

- `test_notifier.py:20` — The exact message wording is explicitly not contractual (`docs/notification-spec.md:6`). Replace this with a coarse assertion that reporting occurred, if that behavior has a stable public cut point; otherwise remove it.

## Good

- `test_rejections.sh:4` does fail when status 400 becomes retryable; shell negation is not neutralizing the assertion.
- The attempt-one and attempt-three delay assertions use independent documented literals and protect plausible exponential-backoff defects.
