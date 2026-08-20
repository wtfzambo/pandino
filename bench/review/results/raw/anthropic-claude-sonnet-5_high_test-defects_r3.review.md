## Test Review — `notifier.py` / `test_notifier.py` / `test_rejections.sh`

### Must-fix

**1. `test_rejections.sh:4` — shell negation swallows all failures, including crashes.**
The line negates the exit status of a `python3 -c` call. I verified this masks *any* exception, not just a wrong boolean result:
```
$ notifier.retryable_status raises RuntimeError → shell still prints "test_rejections: PASS", exit 0
```
Mutation that survives undetected: replace `notifier.py:5` with `raise RuntimeError("broken")`, or with `return True` unconditionally — both still report `test_rejections: PASS`. This gives zero protection for the "reject non-retryable statuses" promise.
Fix: don't negate a command that can raise; assert explicitly inside Python, e.g. `python3 -c 'from notifier import retryable_status; import sys; sys.exit(0 if retryable_status(400) is False else 1)'` without the leading `!`, or catch the specific boolean value rather than the process exit code.

**2. No test asserts `retryable_status(429)` is `True`.**
The diff's actual behavior change (`notifier.py:5`, widening retry to 429+503 per `docs/notification-spec.md:2`) is never exercised. `test_notifier.py:12` only checks 503; `test_rejections.sh` only checks 400 (rejected). Concrete mutation that passes both files unnoticed: revert `notifier.py:5` to `return status == 503`. Add `assert retryable_status(429)`.

**3. `test_notifier.py:7-9,16` — `FakeMailProvider` fixture shape is invented from the implementation, not the documented contract.**
`docs/notification-spec.md:4` states the provider exposes its retry delay via the `Retry-After` response **header**, and explicitly that "its JSON response body is not part of our contract." `notifier.py:16-18` reads `response["body"]["retry_after_seconds"]` — a JSON-body shape that contradicts the spec — and the fake mirrors that same made-up shape instead of a header. The test therefore agrees with the defect it should catch: it can't fail even though `provider_retry_delay` is built against a contract the spec disallows. This needs either a fixture built around `Retry-After` header semantics, or should be raised as a spec/implementation conflict rather than left as passing "evidence."

**4. `test_notifier.py:20` — pins exact wording the spec disclaims.**
`docs/notification-spec.md:5`: "the exact wording is not part of the product contract." The test asserts the literal string `"Retry scheduled in 20 seconds"`. Any harmless rewording (e.g. "Retry in 20s") is spec-compliant but breaks this test — a brittle assertion on a promise the spec says doesn't exist. Weaken to check only the delay value is present/derivable, or drop it.

### Minor excess

**5. `test_notifier.py:15`** — `schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}` recomputes the expected delay by calling `retry_delay` again instead of hardcoding the spec value (20, per the 10/20/40 sequence). This passes by construction for the `delay` field. Use `{"retry": True, "delay": 20}`.

**6. `test_notifier.py:17`** — `assert Path("notifier.py").exists()` is redundant; the `import` on line 4 already requires the file to exist and protects nothing further.

**7. `test_notifier.py:18`** — `get_type_hints(retryable_status)["status"] is int` checks a signature annotation at runtime. This is a static-typing concern a type checker proves more thoroughly; it verifies no observable behavior.

**8. `test_notifier.py:19`** — `assert "def retry_message" in Path("notifier.py").read_text()` is a raw source-text grep, brittle to any harmless reformatting, and redundant with the successful import on line 4.

### Good
`test_notifier.py:13-14` (`retry_delay(1) == 10`, `retry_delay(3) == 40`) are hand-derived from the documented 10/20/40 sequence in `docs/notification-spec.md:3` — an independent source of truth, and would correctly fail under a plausible off-by-one or growth-rate mutation.
