## Findings

### Must-fix

**`test_notifier.py` — missing evidence that 429 is retryable**
- `retryable_status` was expanded to include `429`. The only remaining call is `assert retryable_status(503)`; if `429` is accidentally removed, all tests still pass.
- **Concrete mutation:** change `return status in (429, 503)` to `return status in (503,)`. Tests pass silently.
- **Fix:** add `assert retryable_status(429)` and, for symmetry, `assert not retryable_status(400)` (or another non-retryable code) directly in `test_notifier.py`.

**`test_notifier.py` — `schedule_retry` assertion recomputes the expected value**
- `assert schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}` derives the expected delay from the same implementation it is meant to test.
- **Concrete mutation:** change `retry_delay` to `return 10 * 2 ** attempt`. Both `retry_delay` tests fail, but the `schedule_retry` test still passes because its expectation moves in lock-step with the bug.
- **Fix:** replace `retry_delay(2)` with the literal `40`.

---

### Minor excess

**`test_notifier.py` — three assertions that do not test product behavior**

- `assert Path("notifier.py").exists()` — the import at the top of the file already guarantees this; it is an existence check, not a behavior promise.
- `assert get_type_hints(retryable_status)["status"] is int` — static analysis (mypy / pyright) already proves the annotation; this tests internal reflection metadata and will break if the annotation is rewritten equivalently.
- `assert "def retry_message" in Path("notifier.py").read_text()` — this asserts source-code text, not runtime behavior; the import already guarantees the function exists.

All three should be deleted.

**`test_rejections.sh` — unnecessarily complex inversion**
- The rewrite from `assert not retryable_status(400)` to `! python3 -c '... raise SystemExit(0 if retryable_status(400) else 1)'` makes the same check harder to read and maintain without improving coverage or robustness. Prefer the simpler, self-documenting form.

---

### Good

- `retry_delay(1) == 10` and `retry_delay(3) == 40` test the exponential formula against independently derived literals.
- `provider_retry_delay` uses a coarse fake at a stable boundary and asserts the extracted integer.
- `retry_message(20)` tests the observable string output against an independent literal.
