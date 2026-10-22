## Verdict
changes needed

## Findings
### must-fix
- `test_rejections.sh:4` | demonstrated defect | The rewritten check can never fail. Under `set -e`, errexit is ignored for a pipeline that begins with `!`, so the script prints PASS whatever `retryable_status(400)` returns. The original `assert not retryable_status(400)` (HEAD) did fail. Mutation A (`status in (400, 429, 503)`) makes `retryable(400)` return `True` and the script still passes, and the mutant run exits 0. A bare `set -e` probe confirms it: `! false` is reached and the script continues. | Restore the HEAD line, or move the 400 check into `test_notifier.py` as `assert not retryable_status(400)`. | Promise: "Do not retry other statuses." Breaking it must turn the check red. Role field: false protection.
- `test_notifier.py:12` | plausible risk | The 429 half of the new contract has no assertion. Only `retryable_status(503)` is checked. Mutation G (`status == 503`, which drops 429 retries) passes `test_notifier.py` with exit 0. | Add `assert retryable_status(429)` next to the 503 check. | Promise: "Retry delivery after HTTP 429 or 503." Role field: missing protection.
- `test_notifier.py:15` | plausible risk | The attempt-2 delay has no literal check. The spec lists 10, 20, and 40 seconds, but the test asserts only attempts 1 and 3. Line 15, `schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}`, takes its expected value from `retry_delay`, the code under test, so it is tautological. Mutation H (`[10, 30, 40][attempt - 1]`) passes. | Assert `retry_delay(2) == 20` and `schedule_retry(503, 2)["delay"] == 20` with literal expected values. | Promise: "The retry delays for attempts one, two, and three are 10, 20, and 40 seconds." Role field: missing protection and false protection.
- `test_notifier.py:7-9` and `test_notifier.py:16` | plausible risk, contract mismatch | `FakeMailProvider` returns the delay in a JSON body (`body.retry_after_seconds`), and `notifier.py:17-18` reads it from there. The spec says the delay comes from the `Retry-After` response header and that the JSON body "is not part of our contract." The fake invents a provider shape the contract excludes, and the test agrees with it. Mutation C (read `headers["Retry-After"]`, which matches the spec) fails with `KeyError: 'headers'`, so the test rejects the spec-conforming implementation. Whether the production code should read the header is a spec-reviewer question. This finding is that the test cannot currently protect the documented promise. | Make the fake return the documented shape, e.g. `{"headers": {"Retry-After": "20"}}`, and assert `provider_retry_delay` parses the header. Drop the body fixture. | Promise: the provider's delay is read from `Retry-After`. Role field: invented external fixture shape.

### minor
- `test_notifier.py:17` | excess | `Path("notifier.py").exists()` duplicates the import on line 4, which already fails if the module is missing. | Delete the line.
- `test_notifier.py:18` | excess | `get_type_hints(...)["status"] is int` checks an annotation. A type checker covers this, and the test would break if the hint changed without any behavior change. | Delete the line.
- `test_notifier.py:19` | brittle, internal-structure | `"def retry_message" in Path("notifier.py").read_text()` greps source text. It fails on any refactor that keeps behavior, and it protects no product promise. | Delete the line.
- `test_notifier.py:20` | brittle wording | `retry_message(20) == "Retry scheduled in 20 seconds"` pins exact wording. The spec says "the exact wording is not part of the product contract." Mutation E (wording change only) fails the test. | Delete it, or assert only that the message contains `"20"`. The spec's promise, that a retry was reported, has no test. Pick one assertion for it, not wording.

## Good
- `test_notifier.py` uses concrete literal expectations for the 503 and 20-second cases, and it reads the spec's delay values for attempts 1 and 3 correctly.
- Mutation D (linear delays) and mutation B (NameError in `retryable_status`) are both caught by `test_notifier.py` and `test_rejections.sh` respectively. The HEAD version of `test_rejections.sh` also fails under B.

## Coverage
- Checked:
  - `python3 test_notifier.py` (run with `PYTHONDONTWRITEBYTECODE=1`): PASS, exit 0.
  - `bash test_rejections.sh`: PASS, exit 0.
  - HEAD `test_rejections.sh` against current code: PASS.
  - Mutation runs in scratch copies under `/tmp`, all removed afterward:
    - A, 400 retryable: rejections PASS (should fail).
    - B, NameError: rejections PASS (should fail; the HEAD version fails correctly).
    - C, `Retry-After` header per spec: KeyError (test rejects the correct implementation).
    - D, linear delay: caught.
    - E, wording only: caught (brittle).
    - G, drop 429: PASS (missed).
    - H, attempt-2 delay wrong: PASS (missed).
  - Shell probe: `set -euo pipefail; ! false` reaches the next line, so errexit does not fire.
  - `git status --short` shows only the three modified files; the repo is unchanged.
- Unverified:
  - Whether the production delay should come from the header is a spec-reviewer decision. I did not judge it.
  - No pytest or lint config exists in the repo, so I did not run a type checker or linter.
  - `timeout` is not installed on this macOS host, so I ran each command without a timeout. All finished quickly.
- Turns: not stated in the brief; the budget is unknown. Timed-out commands: none.
