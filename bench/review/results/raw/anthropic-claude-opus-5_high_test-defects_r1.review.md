Verified against `docs/notification-spec.md` (the independent source of truth) with executed mutations in scratch copies. The working tree was not modified.

## Must-fix

**1. `test_rejections.sh:4` — the only negative-status test was inverted and now asserts nothing**

Promise: "Do not retry other statuses."

The rewrite negates the wrong thing. The inner Python exits `0` when `retryable_status(400)` is **true**, and the leading `!` flips that — so the script passes exactly when 400 *is* retryable, and also passes when it is not (exit 1 → negated → success). Both outcomes are green. Proven:

```
Defect injected: status in (400, 429, 503)
  OLD (HEAD) test_rejections.sh rc=1 -> catches bug
  NEW (diff)  test_rejections.sh rc=0 -> MISSES bug
```

This is a strict regression against the committed version, which caught it. Mutation that exposes it: `status in (400, 429, 503)`. The committed `assert not retryable_status(400)` was already correct and needed no change.

**2. `test_notifier.py:12` — 429 is never exercised, though the diff's whole point is adding it**

Promise: "Retry delivery after HTTP 429 or 503." The behavior change is `status == 503` → `status in (429, 503)`, and no assertion covers 429. Mutation `status in (429, 503)` → `status == 503` reverts the feature entirely and the full suite still prints PASS. A bug fix / behavior change with zero protecting evidence. Needs `assert retryable_status(429)`.

**3. `test_notifier.py:15` — `schedule_retry` expectation is recomputed from the implementation**

The expected delay is written as `retry_delay(2)` — the same function under test. It passes by construction and cannot fail on any delay defect. Proven: with `retry_delay` stubbed to `return 7777` for every attempt, this assertion alone still passes. Expectation should be the hand-derived literal from the spec: `{"retry": True, "delay": 20}`.

**4. `test_notifier.py:16` + `notifier.py:16-18` — the fake invents a provider shape the spec explicitly disclaims**

The spec says: "The mail provider exposes its retry delay through the `Retry-After` response header; **its JSON response body is not part of our contract**." `FakeMailProvider.post` returns `{"body": {"retry_after_seconds": 20}}` and `provider_retry_delay` reads that path. The fixture was derived from the implementation, not from the real boundary, so the test confirms a reading of a field the contract says is not there — it agrees with the defect it appears to prevent. Against the real provider this parse fails while the test stays green. Either the implementation should read the `Retry-After` header (with the fake shaped accordingly), or `spec-reviewer` should rule on whether this function belongs at all. No mutation of the header-parsing path can be caught by the current fixture.

**5. `test_notifier.py:13-14` — attempt 2 (20 seconds) is a documented value with no assertion**

The spec names three delays: 10, 20, 40. Attempts 1 and 3 are asserted with independent literals (good); attempt 2 is only touched through the self-referential line 15, which proves nothing. Mutation `return {1: 10, 2: 999, 3: 40}[attempt]` passes the entire suite. Cheap fix: `assert retry_delay(2) == 20`, which also makes finding 3's literal available.

## Minor excess — delete

- **`test_notifier.py:17`** — `assert Path("notifier.py").exists()`. The `from notifier import ...` on line 4 already fails louder and earlier if the module is missing. Duplicate of a cheaper guarantee.
- **`test_notifier.py:18`** — `assert get_type_hints(retryable_status)["status"] is int`. Asserts the annotation, not behavior; a type checker proves this more cheaply, and a refactor to a domain type breaks the test without breaking a promise.
- **`test_notifier.py:19`** — `assert "def retry_message" in Path("notifier.py").read_text()`. Grepping your own source for a `def` is an internal-structure assertion; line 20 already imports and calls the function, which subsumes it. Renaming the function while updating callers would fail this for no product reason.
- **`test_notifier.py:20`** — `assert retry_message(20) == "Retry scheduled in 20 seconds"`. The spec states outright that "the exact wording is not part of the product contract." This pins wording a reworded message would break, with no bug behind the failure. If anything is worth protecting it is that the delay value appears — but given the spec disclaimer, dropping the assertion is the proportionate call.

Net: of the 9 assertions added, 4 are excess, 2 are false protection, and the two real gaps (429, attempt-2) are untested.

## Good

- `test_notifier.py:13-14` derive 10 and 40 as hand-written literals straight from the spec table rather than from the formula — exactly the independent-expectation standard, and they do catch delay defects (confirmed: the `7777` stub fails line 13).
- `FakeMailProvider` is a coarse boundary fake rather than a call-verifying mock; the structure is right even though its payload shape is wrong.

The clean fix is small: repair `test_rejections.sh` back toward the committed assertion, add `retryable_status(429)` and `retry_delay(2) == 20`, replace `retry_delay(2)` with the literal `20` on line 15, delete lines 17-20, and resolve the provider-body-vs-header contradiction with `spec-reviewer`.
