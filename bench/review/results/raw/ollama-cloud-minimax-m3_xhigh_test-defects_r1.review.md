The spec is clear: the provider exposes retry delay through the `Retry-After` HTTP **header**, not the JSON body. The implementation `provider_retry_delay` reads `response["body"]["retry_after_seconds"]` — a JSON body field. That's a spec-vs-implementation conflict (owned by `spec-reviewer`), but it also affects test evidence: the test fabricates a `FakeMailProvider` that returns the wrong shape (`{"body": {"retry_after_seconds": 20}}`) and the implementation agrees with it by construction. This is a false-protection finding: the test cannot detect the contract violation because both sides agree on a fictional shape.

Now let me write up findings.

---

# Test review: must-fix

**test_notifier.py — `provider_retry_delay` test is false protection against a spec violation**

`docs/notification-spec.md` line 5 says: *"The mail provider exposes its retry delay through the `Retry-After` response header; its JSON response body is not part of our contract."*

The implementation reads `response["body"]["retry_after_seconds"]` (JSON body), and the test fixture `FakeMailProvider.post` returns exactly `{"body": {"retry_after_seconds": 20}}`. Both sides agree on a shape the spec explicitly excludes from the contract. A correct implementation that reads `response["headers"]["Retry-After"]` would fail this test, and an implementation that quietly keeps reading a JSON body would pass — the test pins the wrong shape, not the contract.

Concrete mutation that would expose the gap: change `provider_retry_delay` to read `response["headers"]["Retry-After"]` and the test still asserts success only because the fake was reshaped to match the bug. The current evidence proves the implementation matches the fake; it does not prove the implementation matches the contract.

Recommendation: either the test must derive the expected shape from the spec (e.g. assert `FakeMailProvider` returns a header-style payload and the implementation reads from it), or — if the spec reviewer concludes the JSON body reading is intentional — update `docs/notification-spec.md` to reflect the chosen shape and re-anchor the test against that updated contract. As-is, the test is invented-fixture false protection.

# Minor excess

**test_notifier.py — `Path("notifier.py").exists()` is a duplicate of filesystem state**

`Path("notifier.py").exists()` is exercised by every other line of the test (the import would have already failed). This is the existence-check pattern AGENTS.md calls out explicitly as a "cheaper guarantee" — duplication of an already-failed precondition.

**test_notifier.py — `get_type_hints(retryable_status)["status"] is int` is type-checker work**

Runtime introspection of `__annotations__` to confirm `int` is exactly the same guarantee the type checker (or import-time static analysis) already provides. If the signature regressed, the implementation could not return the `bool` values asserted elsewhere without an annotation mismatch first — and `retryable_status` accepts and returns values compatible with multiple numeric types anyway, so the test pins the annotation rather than behavior. Drop it.

**test_notifier.py — `"def retry_message" in Path("notifier.py").read_text()` is a textual grep**

Asserting on the source text proves a string is present in a file, not that `retry_message` is callable with the documented behavior. The very next assertion (`retry_message(20) == "Retry scheduled in 20 seconds"`) already covers the callable contract. The grep is redundant.

**test_rejections.sh — style-only rewrite**

The `! python3 -c '... raise SystemExit(...)'` form is equivalent to the original `assert` under `set -euo pipefail` (both exit-0-on-failure and exit-1-on-failure paths are caught by `!` plus `errexit`). No new evidence; no loss of evidence. Harmless but unnecessary churn. Either revert to the prior form or, if the goal was to drop the `assert` dependence, leave a one-line note.

# Good

- `test_notifier.py` covers all four new functions with at least one independent expected value each.
- `retry_delay(1) == 10` and `retry_delay(3) == 40` use hand-derived values (10·2^0, 10·2^2), not a recomputation of the implementation — independent source of truth.
- `schedule_retry` is tested against both a retryable status and indirectly via `retry_delay`, exercising composition rather than recomputation.
- The 429 addition is covered by `test_rejections.sh` continuing to assert that 400 is not retryable, and the import of `retryable_status` would fail loudly if 503 regressed — the existing negative test plus the positive `retryable_status(503)` assertion together bracket the membership set, though a small positive `retryable_status(429)` assertion would make the new behavior explicit.
- `set -euo pipefail` is preserved in the shell test; no swallowed errors.

# Summary

One must-fix: `provider_retry_delay` test pins a fabricated JSON-body shape that contradicts the spec's header-based contract. Three minor excesses (existence check, annotation introspection, source-text grep). Otherwise the diff's evidence is proportionate and independent for the new retry helpers.
