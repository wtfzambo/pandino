## Must-fix

- **`test_notifier.py:12`, `test_rejections.sh:4` — status allowlist is under-tested.** No test asserts 429 retries, and only 400 is checked as non-retryable. Reverting `retryable_status` to 503-only, or making 500 retryable, would pass. Add independent assertions for 429 and representative other statuses.

- **`test_notifier.py:15` — delay expectation is implementation-derived.** `retry_delay(2)` is used to construct the expected result. A defect affecting attempt 2 could pass. Assert the documented literal `20` and test attempts 1, 2, and 3 independently.

- **`test_notifier.py:7-10` — provider fixture validates the wrong contract.** The specification says `Retry-After` response headers, but the fake invents a JSON body shape matching the implementation. A header-based implementation or regression would not be meaningfully tested. Use a header fixture such as `{"headers": {"Retry-After": "20"}}`.

## Minor excess

- **`test_notifier.py:17-19` — tests implementation/source details rather than behavior.** Module existence, annotations, and source-text checks add brittleness without protecting a product promise. Remove them.

- **`test_notifier.py:20` — exact message wording is explicitly non-contractual.** This test creates unnecessary coupling and should be removed or replaced with a looser observable assertion if the message itself matters.

## Good

- Existing tests pass, and the shell rejection test correctly fails if status 400 becomes retryable.
