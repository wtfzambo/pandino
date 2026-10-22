## Verdict
changes needed

## Findings
### must-fix
- `test_notifier.py:12` | incomplete coverage | No test covers the newly supported HTTP 429 status. Reverting `retryable_status` to its original implementation would leave all current tests passing. | Add a positive 429 case, preferably through `schedule_retry`. | Promise: rate-limited deliveries are retried; mutation: accept only 503.

- `test_rejections.sh:4` | demonstrated defect | The negated command is exempt from Bash’s `set -e`; even when it fails, execution reaches the successful `echo`. The script therefore passes whether 400 is retryable or not, and also hides Python errors. | Restore the direct Python assertion without `!`, so assertion failures and interpreter errors fail the script. | Promise: other statuses are not retried; mutation: make `retryable_status(400)` return `True`.

- `test_notifier.py:15` | incomplete coverage | The expected attempt-two delay comes from `retry_delay(2)`, the same function used by `schedule_retry`; no independent assertion establishes the documented 20-second result. | Replace the computed expected delay with the contract’s literal `20`. | Promise: attempt two waits 20 seconds; mutation: return an incorrect delay only for attempt two.

- `test_notifier.py:7–9` | demonstrated defect | The provider fake supplies an invented JSON-body field, whereas the documented contract specifies the `Retry-After` header. This test agrees with the implementation’s incorrect body lookup rather than detecting it. | Use a provider-contract-backed response fixture containing `Retry-After`, with no required JSON body, and assert its parsed delay. | Promise: provider delay comes from the response header; mutation: read the body instead of the header—the current implementation already does this.

### minor
- `test_notifier.py:17–19` | demonstrated defect | File-existence, annotation-introspection, and source-text assertions add no observable retry protection beyond importing and exercising the functions; they also constrain harmless restructuring. | Delete these three assertions and their unused imports. | Excess removal: remove checks of file layout, annotation spelling, and function-definition text.

- `test_notifier.py:20` | demonstrated defect | Exact message equality freezes wording that the notification contract explicitly leaves unspecified. | Check that the result communicates a scheduled retry without requiring this exact sentence. | Excess removal: allow equivalent wording while retaining protection against an empty or unrelated report.

## Good
- The attempt-one and attempt-three delay assertions use independent, contract-derived values and would catch incorrect backoff results.
- The small function-level checks are proportionate to these shipping helpers; no elaborate test infrastructure is needed.

## Coverage
- Checked: complete working diff, notification contract, implementation, and both test scripts. Both scripts currently pass with bytecode writes disabled; `git diff --check` passes. A read-only Bash probe confirmed that `!` followed by `echo` masks failure under `set -e`.
- Unverified: the provider SDK’s concrete response representation is not documented here; a corrected fixture needs that authoritative shape. Regression-first history cannot be established from the working diff. No files were changed.
- Turns: 6 of unspecified budget; timed-out commands: none.
