## Verdict
changes needed

## Findings
### must-fix
- `test_notifier.py:7-9` | demonstrated defect | The provider fake invents a JSON-body retry field even though `docs/notification-spec.md` explicitly requires `Retry-After` and excludes the body from the contract; the passing test therefore endorses the defect. | Replace this fixture with a documented provider response exposing `Retry-After`, and assert the returned delay independently of the body. | Promise: honor the provider’s retry header; mutation: read a conflicting body delay instead of the header—the test must fail.

- `test_rejections.sh:4` | demonstrated defect | Negating the Python command suppresses `set -e`, and the following `echo` makes the script succeed regardless of the check’s result; both an unexpected retry and a Python failure produced exit 0 in probes. | Restore a direct Python assertion whose failure propagates to the script’s exit status. | Promise: reject non-retryable statuses; mutation: make status 400 retryable—the script must exit nonzero.

- `test_notifier.py:12` | incomplete coverage | No test exercises the newly supported status 429; reverting the implementation to “503 only” leaves the Python tests passing. | Add a contract-based assertion that 429 is retryable, alongside the positive and rejection cases. | Promise: retry HTTP 429; mutation: remove 429 from the accepted statuses.

- `test_notifier.py:15` | demonstrated defect | The expected schedule calculates its delay using the same production helper as the implementation, leaving the documented second-attempt delay unprotected; changing that delay to 999 still passes. | Assert the independently specified schedule `{"retry": True, "delay": 20}` for attempt two. | Promise: the second retry waits 20 seconds; mutation: return an incorrect delay for attempt two.

### minor
- `test_notifier.py:17-19` | demonstrated defect | File existence, annotation introspection, and source-text searches add no observable behavioral protection beyond importing and exercising these functions; they also pin tests to file layout and implementation form. | Delete these assertions and their unused imports. | Excess removal: delete the existence, type-hint, and source-definition checks while retaining behavioral tests.

- `test_notifier.py:20` | demonstrated defect | Exact message wording is explicitly outside the product contract, so this assertion rejects valid wording changes. | Check that the result communicates a scheduled retry without requiring the complete sentence verbatim. | Excess removal: replace exact-string equality with a focused check of the promised message meaning.

## Good
- The first- and third-attempt delay tests use independent, documented values.
- Tests exercise public helpers directly without extensive internal mocking.

## Coverage
- Checked: required review/testing guidance, notification contract, and entire working diff; both supplied test scripts pass; `git diff --check` passes.
- Checked: file-free mutation probes demonstrated surviving 429 and second-delay defects, plus swallowed shell failures. A header-only provider probe exposed the body dependency. The first mutation probe needed correction to preserve annotations before reaching the behavioral assertions.
- Unverified: the external provider’s concrete response-object API is not supplied; the contract establishes the header requirement, but the replacement fixture’s precise shape needs authoritative provider evidence.
- Turns: 8 of an unspecified budget; timed-out commands: none.
