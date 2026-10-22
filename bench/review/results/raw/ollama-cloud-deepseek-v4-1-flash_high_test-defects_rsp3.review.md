## Verdict
changes needed

## Findings
### must-fix
- `test_notifier.py:12` | incomplete coverage | The new behavior the spec names first — retry on 429 — has no test at all; `429` appears only in `notifier.py` and `docs/notification-spec.md`. Mutation: change `retryable_status` back to `return status == 503`; `test_notifier.py` and `test_rejections.sh` both still pass, so the entire change's headline promise is unprotected. | Add `assert retryable_status(429)` next to the 503 case. | Promise: HTTP 429 is retryable; mutation: drop 429 from the tuple.
- `test_notifier.py:7-9,16` | false protection | `FakeMailProvider` and its assertion are shaped by the implementation (`response["body"]["retry_after_seconds"]`), while `docs/notification-spec.md:5` says the retry delay comes from the `Retry-After` header and the JSON body is "not part of our contract". The test therefore agrees with the defect it should catch and would have to be rewritten when the provider call is corrected. | Give the fake a response carrying `Retry-After` per the documented provider contract and assert that value is returned. | Promise: provider delay read from the documented header; mutation: none needed — the test currently locks in the wrong source.
- `test_rejections.sh:4` | false protection | `! python3 -c ...` turns *any* nonzero exit from the interpreter into a pass, not just "status 400 is not retryable". Demonstrated: `bash -c 'set -euo pipefail; ! python3 -c "import surely_missing_module"; echo PASSED'` prints `PASSED` and exits 0. An import break, syntax error, or renamed symbol makes the rejection test vacuously green. | Put the rejection inside the interpreter (`assert not retryable_status(400)`, as before) so a broken import fails loudly. | Promise: non-retryable statuses are rejected; mutation: break the import to see the test still pass.

### minor
- `test_notifier.py:15` | false protection | The expected value is `retry_delay(2)`, computed by the code under test, so the documented 20-second delay for attempt two is never pinned independently. Mutation: `return 30 if attempt == 2 else 10 * 2 ** (attempt - 1)` passes every assertion. The same line also never checks the non-retryable branch of `schedule_retry`, so `{"retry": True, ...}` unconditionally would survive. | Assert `schedule_retry(503, 2) == {"retry": True, "delay": 20}` and add one `schedule_retry(400, 1)` case expecting `retry` false. | Promise: delays 10/20/40 seconds and "do not retry other statuses"; mutation: special-case attempt two.
- `test_notifier.py:20` | excess | Asserts exact wording, which `docs/notification-spec.md:6` explicitly excludes from the contract; a wording change that users cannot rely on breaks the test. | Delete it, or assert only that the message mentions the delay. | Promise: none (wording is out of contract); change: reword the message to `Retry in 20s` and the test fails for no product reason.
- `test_notifier.py:17-19` | excess | Three assertions protect nothing a user observes: file existence is already guaranteed by the import on line 4 (the test would error first), `get_type_hints` duplicates what a type checker enforces, and the source-text grep for `def retry_message` pins module internals and breaks on any benign restructuring. | Delete lines 17-19. | Promise: none; change: move `retry_message` to a helper module or reformat it, and the test fails.

## Good
- `retry_delay` gets two concrete, independently-derived values (10 and 40) driven through its public signature.
- The rejection path is kept as a separate negative check rather than folded into a positive assertion.

## Coverage
- Checked: `git diff`, `git status`, and `git show HEAD:` for the before/after shape; read `notifier.py`, `test_notifier.py`, `test_rejections.sh`, `docs/notification-spec.md`; ran `python3 test_notifier.py` (PASS, exit 0) and `bash test_rejections.sh` (PASS, exit 0) under Python 3.12.15; demonstrated the shell false-pass with a live import failure; grepped tests for `429`, `Retry-After`, and `retry_after_seconds` (only the last appears, in the fake).
- Unverified: no lint/type-check configuration exists in the repository, so I did not run formatters or type checkers; `timeout` is unavailable on this machine, so scripts were run directly (both finish immediately).
- Turns: 6 of 10; timed-out commands: none.
