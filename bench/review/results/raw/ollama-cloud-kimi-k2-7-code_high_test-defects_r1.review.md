Findings from the working diff.

## Must-fix

**`test_rejections.sh:3` — the negated shell command masks Python failures**
The new line
```bash
! python3 -c 'from notifier import retryable_status; raise SystemExit(0 if retryable_status(400) else 1)'
```
inverts the exit code. With `set -e`, any Python crash (syntax error, import failure, typo) exits non-zero, `!` flips it to `0`, and the script prints `PASS`. I verified this by making the inner command import a non-existent module: the script still continued and exited `0`.

Concrete mutation: change the inner command to `import nonexistent; from notifier import retryable_status; ...` — the test passes.

Use a straightforward assertion instead, e.g.:
```bash
python3 -c 'from notifier import retryable_status; assert not retryable_status(400)'
```

**`test_notifier.py` — no test for the new `429` retryable behavior**
The implementation changed `retryable_status` to accept both `429` and `503`. `test_notifier.py` only asserts `retryable_status(503)`, and `test_rejections.sh` only checks `400`. A plausible regression that drops `429` would leave every test green.

Concrete mutation: revert `retryable_status` to `return status == 503` — all tests still pass.

## Minor / excess

**`test_notifier.py:14` — `schedule_retry` expected value is derived from the implementation**
```python
assert schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}
```
This passes by construction. It also omits the non-retryable branch.

Change to independent literals and add the negative case:
```python
assert schedule_retry(503, 2) == {"retry": True, "delay": 20}
assert schedule_retry(400, 1) == {"retry": False, "delay": 10}
```

**`test_notifier.py:16` — `assert Path("notifier.py").exists()` is an existence check**
The file system already guarantees this. It does not protect an observable product promise; remove it.

**`test_notifier.py:17` — type-hint assertion duplicates static analysis**
```python
assert get_type_hints(retryable_status)["status"] is int
```
A type checker already verifies annotations. Remove this or rely on `mypy`/`pyright`.

**`test_notifier.py:18` — source-text assertion is brittle**
```python
assert "def retry_message" in Path("notifier.py").read_text()
```
This breaks on benign refactors (renaming, moving the function to another module). The existing `assert retry_message(20) == "Retry scheduled in 20 seconds"` already tests the behavior; remove the source-text check.

## Good

- `retry_delay(1) == 10` and `retry_delay(3) == 40` use hand-derived literals that would catch an incorrect exponential formula.
- `retry_message(20)` asserts the visible output, not the implementation.
- `provider_retry_delay` uses a coarse fake at a narrow boundary.
