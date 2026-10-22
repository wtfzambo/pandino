## Verdict
changes needed

## Findings
### must-fix

- `test_rejections.sh:4` | demonstrated defect | The rewritten guard can never fail: under `set -e`, a pipeline prefixed with `!` is exempt from `errexit`, so the script prints PASS and exits 0 no matter what the command returns. Demonstrated: `bash -c 'set -euo pipefail; ! python3 -c "raise SystemExit(0)"; echo PASSED_ANYWAY'` prints `PASSED_ANYWAY`, exit 0. The old form (`python3 -c '... assert not retryable_status(400)'`) aborted with exit 1 on a false condition, which I reproduced with `python3 -c "assert False"`. The double negation silently removed the only existing regression guard for "do not retry other statuses" (spec line 3). | Replace it with a construct `set -e` can see: `python3 -c 'from notifier import retryable_status; raise SystemExit(0 if not retryable_status(400) else 1)'` with no `!`, or an explicit `if ...; then exit 0; else exit 1; fi`. | Promise: a 400 response schedules no retry. Mutation: make `retryable_status` retry 400 — current suite still exits 0.

- `test_notifier.py:12` (and absent around line 15) | incomplete coverage | The new retryable status 429 has no assertion in any test, and the false branch of `schedule_retry` is never exercised. Mutation `return status == 503` and mutation `{"retry": True, "delay": ...}` both leave the whole suite green, so the shipped change's headline promise (spec line 3) is unprotected. Missing regression protection for a reproducible behavior change. | Add `assert retryable_status(429)` and a `schedule_retry(<non-retryable status>, 1)["retry"] is False` case, paired with the existing positive cases. | Promise: retry exactly on 429/503. Mutation: `return status == 503` — suite passes today.

- `test_notifier.py:7-9` with `:16` | false protection (invented provider fixture) | `FakeMailProvider` returns `{"body": {"retry_after_seconds": 20}}`, i.e. exactly the shape `provider_retry_delay` reads, while the spec (line 5) says the provider exposes the delay through the `Retry-After` **header** and the JSON **body is not part of our contract**. The fixture is derived from the implementation rather than the documented provider contract, so it certifies the contract-violating access and would reject a spec-correct header-reading implementation. | Shape the fake from the documented contract (a response exposing `Retry-After`) and assert the parsed delay from it; the corresponding read in `notifier.py:16-18` is spec-reviewer's finding. | Promise: the retry delay comes from the provider's `Retry-After` header. Mutation: keep body access — test passes today; switch to the header — test fails.

### minor

- `test_notifier.py:15` | false protection (implementation-derived expectation) | `{"retry": True, "delay": retry_delay(2)}` computes the expected value with the code under test, so the assertion cannot detect a broken delay formula. | Use the spec literal `20`. | Promise: attempt two backs off 20 seconds. Mutation: `retry_delay` returns half the correct value — this assertion still passes.

- `test_notifier.py:20` | brittle over-pinning | Asserts the exact sentence while the spec says "the exact wording is not part of the product contract"; any rewording fails without an observable promise breaking. | Assert that the delay appears in the reported message (e.g. `"20" in retry_message(20)`), not the full wording. | Promise: a scheduled retry is reported with its delay. Test change: replace the exact-string assertion.

- `test_notifier.py:17-19` | excess | Three assertions nothing can break: `Path("notifier.py").exists()` is guaranteed by the import on line 4; `get_type_hints(retryable_status)["status"] is int` restates the annotation a type checker already enforces; `"def retry_message" in ...read_text()` asserts internal source text, fails on any refactor, and is already covered behaviorally by line 20. | Delete lines 17-19. | Excess: these protect no product promise.

- `test_notifier.py:12-20` | pre-existing | Module-level `assert`s all disappear under `python3 -O` / `PYTHONOPTIMIZE=1` (`python3 -c 'assert False'` under optimized mode exits 0; `test_notifier.py` still prints PASS). Pre-existing style, but the entire file's evidence evaporates in optimized runs — likely the reason the shell script was touched. | Express checks with explicit `SystemExit` codes or run them under a test runner instead of bare module-level `assert`s.

## Good
- `retry_delay` is pinned against spec literals hand-derived from the 10/20/40 schedule (`:13-14`), so a wrong base or exponent is caught, and the checks drive the public functions with concrete input.
- The `set -euo pipefail` shebang and the intent to make the negative check immune to optimized-mode assert stripping are the right instincts; the mechanism just needs to be one `set -e` honors.

## Coverage
- Checked: read `AGENTS.md`, `.pandino/playbooks/reviewing.md`, `.pandino/playbooks/testing.md`, `docs/notification-spec.md`; read the full working diff against `HEAD`; ran `python3 test_notifier.py` (PASS, exit 0) and `./test_rejections.sh` (PASS, exit 0, also PASS under `PYTHONOPTIMIZE=1`); probed the `!`-under-`set -e` neutralization and the old `assert` form for comparison; grepped for `429`/`Retry-After`/`headers` to confirm no header-based coverage exists; removed the `__pycache__/` my run created so the tree is exactly as found (only the three modified files).
- Unverified: no automated runner config exists (no pytest/CI config), so I could not check CI wiring; `pytest` is not required by the repo. Whether `provider_retry_delay` should read a `requests`-style header object is spec-reviewer's scope.
- Turns: 6 of budget; timed-out commands: none (`timeout` binary is absent on this host, so I ran commands bounded by the tool timeout instead).
