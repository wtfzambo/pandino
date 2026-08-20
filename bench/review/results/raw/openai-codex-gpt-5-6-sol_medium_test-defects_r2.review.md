## Must-fix

- `test_notifier.py:12-15` — **429 responses and the documented second-attempt delay lack independent protection.** A mutation restoring `retryable_status` to `status == 503` passes every test. Likewise, returning an incorrect delay only for attempt 2 passes because `schedule_retry` derives its expected value from `retry_delay(2)`. Add literal expectations for HTTP 429 and attempt 2 (`20`), preferably through `schedule_retry(429, 2)`.

- `test_notifier.py:7-16` — **The provider test encodes behavior contrary to the documented contract.** The specification says delay comes from the `Retry-After` header, while the fake and implementation agree on an invented JSON body field. Replace the fake with the documented header-shaped boundary response and assert the parsed delay. That change exposes the current implementation’s `response["body"]["retry_after_seconds"]` defect.

## Minor excess

- `test_notifier.py:17-19` — File existence, type-hint introspection, and source-text inspection do not protect observable behavior. Importing already guarantees the module/function exists, while typing belongs to static tooling. Delete these assertions and their imports.

- `test_notifier.py:20` — Exact message wording is explicitly outside the product contract. A harmless mutation such as `"Will retry after 20s"` would fail. Replace this with a coarser contract-level assertion, such as a non-empty report containing the delay, or remove it if reporting is protected at a stronger boundary.

## Good

- `test_rejections.sh:4` effectively rejects a representative non-retryable status and fails if status `400` becomes retryable.
- Attempts 1 and 3 use independent literal delay expectations.
