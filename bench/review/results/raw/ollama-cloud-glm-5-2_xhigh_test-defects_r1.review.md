I have everything needed. Here is my test-evidence review of the uncommitted working diff.

---

## Test review — `notifier.py` + `test_notifier.py` + `test_rejections.sh`

The diff's headline behavior change is adding HTTP **429** to `retryable_status` (per `docs/notification-spec.md`: "Retry delivery after HTTP 429 or 503"). It also adds `retry_delay`, `schedule_retry`, `provider_retry_delay`, and `retry_message`. Below, ordered by severity.

### Must-fix

**1. `test_notifier.py` (whole file) + `test_rejections.sh` — no test protects the new 429 behavior.**
The diff's one observable behavior change is `retryable_status` now returns `True` for 429. No assertion checks `retryable_status(429)`. `test_notifier.py:12` only checks 503 (pre-existing); `test_rejections.sh` only checks the negative 400. I confirmed by replaying the suite under **mutation A** (`retryable_status` reverted to `status == 503`): every assertion still passes. The 429 regression is invisible to the entire suite.
Fix: `assert retryable_status(429)` in `test_notifier.py` (and, for symmetry, a 429-positive vs. a non-retryable like 200 in the rejection script if desired).

**2. `test_notifier.py:15` — `schedule_retry` expectation is implementation-derived (circular).**
`assert schedule_retry(503, 2) == {"retry": True, "delay": retry_delay(2)}`. The expected `delay` is computed by calling the function under test (`retry_delay(2)`), so it passes by construction. I confirmed under **mutation B** (`retry_delay` exponent wrong: `10 * 2**attempt`): the real contract value for attempt 2 is 20, the bug returns 40, yet this assertion still passes because both sides use the same buggy function. The `retry: True` half is independent (503→True from the contract); the `delay` half proves nothing.
Fix: derive the delay from the contract — `{"retry": True, "delay": 20}`.

**3. `test_notifier.py:7-9,16` — `provider_retry_delay` fake invents a fixture shape that contradicts the authoritative contract, with a circular expectation.**
`FakeMailProvider.post` returns `{"body": {"retry_after_seconds": 20}}` and the assertion expects `== 20`. Per `docs/notification-spec.md`: "The mail provider exposes its retry delay through the `Retry-After` response header; its JSON response body is **not part of our contract**." So the `body`/`retry_after_seconds` shape is invented, not a real boundary fixture, and contradicts the spec. Worse, the expected value (20) is the very value the fake returns — the test confirms only that the implementation can read a key it chose to read; any key name would pass if the fake matched. This is false protection and locks in a contract-violating shape. (Whether the impl *should* read the header is the spec-reviewer's call; the *test* provides no independent evidence either way.)
Fix: drive the fake from the contracted boundary (`Retry-After` header) with an independently derived expected value, or drop the test until the impl matches the contract.

**4. `test_notifier.py:20` — `retry_message` assertion locks exact wording the contract explicitly frees.**
`assert retry_message(20) == "Retry scheduled in 20 seconds"` pins the full string, but `docs/notification-spec.md` states: "Report that a retry was scheduled, but the exact wording is **not part of the product contract**." A contract-compliant reword (e.g. "Retrying in 20s") would break this test though the product promise is preserved — the test fights the freedom the spec deliberately grants.
Fix: assert only the contracted observable (a retry is reported and the delay is conveyed, e.g. message is non-empty and contains `"20"`), or drop the exact-string assertion.

### Minor excess / gaps

**5. `test_notifier.py:17` — `assert Path("notifier.py").exists()` is pure excess.** The `from notifier import …` at line 4 already fails if the module file is absent. AGENTS.md: don't duplicate existence checks with a test. Delete.

**6. `test_notifier.py:18` — `assert get_type_hints(retryable_status)["status"] is int` duplicates the type annotation / static type checking.** It protects no behavior; the `status: int` annotation is the source of truth and the type checker's job. Delete.

**7. `test_notifier.py:19` — `assert "def retry_message" in Path("notifier.py").read_text()` is a source-text/structure assertion.** The import already proves `retry_message` exists; this protects nothing observable and breaks on a benign rename/decorator. Delete.

**8. `test_notifier.py:13-14` — `retry_delay` anchors skip the middle contract value.** The contract lists three values: 10, 20, 40 for attempts 1, 2, 3. Tests anchor attempt 1 → 10 and attempt 3 → 40 (good — they catch common exponent errors) but not attempt 2 → 20. A mutation corrupting only attempt 2 would slip. Add `assert retry_delay(2) == 20` for the complete contract.

**9. `test_rejections.sh:4` — the rewrite added obscurity without adding protection.** `! python3 -c '…; raise SystemExit(0 if retryable_status(400) else 1)'` correctly protects "400 is not retried" (it does fail if 400 becomes retryable), but the original `python3 -c '…; assert not retryable_status(400)'` said the same thing more plainly. Prefer the simpler form.

### Good

- `test_notifier.py:12` — `assert retryable_status(503)` is independent and contract-derived; protects the 503 positive case.
- `test_notifier.py:13-14` — `retry_delay` expectations (10, 40) come from the contract, not from recomputing the function, and catch exponent mutations.
- `test_rejections.sh` — it is the sole protector of the negative case ("do not retry other statuses") and is not duplicated by `test_notifier.py`; it fails under the 400-becomes-retryable mutation.

### Net

The diff introduces a real behavior change (429) and several new functions, but the new/changed test evidence is dominated by false protection (circular expectations at lines 15 and 16, an invented contract-contradicting fixture at 7-9, an over-specified string at 20) and pure excess (lines 17-19). The one genuinely new promise — 429 is retryable — has **no** test. Address the four must-fix items before committing.
