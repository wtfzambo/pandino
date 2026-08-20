## Must-fix

- `test_notifier.py:12` — Retry must include HTTP 429. No test exercises the newly added status. Mutating `retryable_status` back to `return status == 503` passes all current tests. Add a direct 429 assertion.
- `test_notifier.py:13-15` — Attempts 1, 2, and 3 must delay 10, 20, and 40 seconds. Attempt 2 is never independently asserted; the schedule expectation calls the implementation under test. Mutating `retry_delay(2)` to return `30` passes these tests. Assert the documented literal `20` (and use an independent literal in the schedule assertion if retained).
- `test_notifier.py:16` — Provider delay must come from the documented `Retry-After` response header. The fake invents a JSON-body contract that the specification explicitly excludes, so it protects the current defect and would reject a correct header-based implementation. Replace it with a coarse response fixture exposing the header and assert its parsed value.

## Minor excess

- `test_notifier.py:17-19` — File existence, runtime annotation inspection, and source-text search do not protect observable behavior; import already establishes file/function availability, and type/source structure is not a product promise. Delete these assertions.
- `test_notifier.py:20` — Exact retry-message wording is explicitly outside the product contract. Delete this assertion rather than freezing incidental wording.

## Good

- `test_rejections.sh:4` still effectively protects the “do not retry 400” case; the tests currently pass.
