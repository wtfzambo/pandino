## Must-fix

- `test_rejections.sh:4` — **Non-retryable statuses must remain rejected.** The command is under `!`, where Bash suppresses `errexit`; if `retryable_status(400)` mutates to `True`, the inverted command fails but the script continues and prints PASS. Replace this with a direct assertion/explicit conditional that exits nonzero. Mutation exposing the gap: `return status in (400, 429, 503)`.

- `test_notifier.py:7-16` — **Provider delay must come from the documented `Retry-After` header.** The fake invents a JSON-body shape explicitly excluded by `docs/notification-spec.md:5`, so the test endorses the current contract violation. Use a fixture shaped like the documented header and assert its parsed value. Mutation currently protected as “correct”: continue reading `response["body"]["retry_after_seconds"]`.

- `test_notifier.py:12-15` — **429 and non-retry scheduling behavior lack effective evidence.** Only 503 is tested positively, and `schedule_retry` is never tested with a rejected status. Add observable scheduling cases for 429 and a representative non-retry status. Mutations that currently pass: remove 429 from `retryable_status`, or make `schedule_retry` always return `"retry": True`.

- `test_notifier.py:15` — **Attempt two must produce 20 seconds.** The expected delay calls `retry_delay(2)`, reproducing the implementation rather than using the documented value. Assert the literal contract value `20`. Mutation currently passing: special-case attempt 2 to return 30; both actual and expected become 30.

## Minor excess

- `test_notifier.py:17-19` — File existence, runtime inspection of a type annotation, and source-text search do not protect product behavior and duplicate guarantees already implied by importing/calling the module. Delete these assertions and their imports.

- `test_notifier.py:20` — The exact retry-message wording is explicitly not contractual (`docs/notification-spec.md:6`). Replace the exact-string assertion with a coarse semantic check at the reporting boundary, or remove it until such a stable boundary exists.

## Good

- Attempts one and three have independently derived expected delays.
- Existing 503 retry behavior remains protected.
- Both current test scripts pass, though the shell rejection test is demonstrably false protection.
