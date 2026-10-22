## Verdict
changes needed

## Findings
### must-fix
- `test_rejections.sh:4` | demonstrated defect | The negated command cannot enforce rejection: Bash exempts `!` commands from `set -e`, so the script reaches its successful final `echo` even when the predicate incorrectly accepts HTTP 400. | Restore a direct assertion whose failure exits the script nonzero. | Promise: non-retryable statuses are rejected; mutation: make `retryable_status(400)` return `True`.

- `test_notifier.py:8-9` | demonstrated defect | The fake invents a JSON-body retry field, contradicting the documented `Retry-After` header contract; the passing test endorses the implementation’s incorrect source. | Replace the fixture with a contract-backed header response, using the actual provider interface, and assert the returned delay without requiring a JSON body. | Promise: provider retry delays come from `Retry-After`; mutation: read the body instead of the header, as the current implementation does.

- `test_notifier.py:12` | incomplete coverage | No test exercises HTTP 429, the changed retry-status behavior; reverting the implementation to its original 503-only predicate would leave the tests green. | Add an assertion that HTTP 429 is retryable, preferably through `schedule_retry`. | Promise: rate-limited deliveries retry; mutation: remove 429 from the accepted statuses.

- `test_notifier.py:15` | incomplete coverage | The expected second-attempt delay is computed using `retry_delay(2)`, the same helper used by `schedule_retry`; neither independent delay assertion covers attempt two. | Use the contract’s literal expected delay of 20 in the schedule assertion. | Promise: the second retry waits 20 seconds; mutation: return 30 only for attempt two, which currently changes both actual and expected values together.

### minor
- `test_notifier.py:17-20` | plausible risk | File-existence, annotation-introspection, and source-text assertions add no observable protection beyond the imports and behavior checks; the exact message assertion freezes wording explicitly excluded from the contract. | Delete the three structural assertions and replace exact message equality with a check of the promised scheduled-retry meaning. | Remove redundant structural checks and allow equivalent wording such as “Retry scheduled after 20 seconds” without a false failure.

## Good
- The first- and third-attempt delay assertions use independent values from the documented contract.
- The tests are small and exercise real helper behavior rather than mocking internal calls.

## Coverage
- Checked: Read the full working diff, all source/tests, and the notification contract. Both test scripts pass with bytecode writes disabled; `git diff --check` passes. A read-only shell probe confirms the negated-command failure is swallowed. A header-only boundary probe exposes the implementation’s mandatory body access (`KeyError: 'body'`).
- Unverified: No actual provider SDK/interface is present to validate its concrete response shape; the documented header requirement is clear. Regression-first test history cannot be established from the working diff. The referenced pickup skill is absent. No files were changed.
- Turns: 6 of unspecified budget; timed-out commands: none.
