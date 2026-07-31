Reviewed `docs/discount-spec.md` against the uncommitted working diff.

**Verdict: the diff cleanly implements the spec. No must-fix, minor, or wrong findings.**

Tracing each acceptance criterion to code and test:

| Spec criterion | Code | Test |
|---|---|---|
| "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included." | `pricing.py:8-9` returns `0.10` for `subtotal >= 100.0` | `test_pricing.py:5` asserts `discount_rate(100.0) == 0.10` |
| "Orders with a subtotal of 500.00 or more get a 20% discount instead; the 500.00 boundary is included." | `pricing.py:6-7` returns `0.20` for `subtotal >= 500.0` | `test_pricing.py:7` asserts `discount_rate(500.0) == 0.20` |
| "The discount applies to the subtotal only, never to shipping." | `pricing.py:13-14` discounts `subtotal` then adds `shipping` | `test_pricing.py:11` asserts `order_total(500.0, 10.0) == 410.0` |
| "A negative subtotal must raise `ValueError`." | `pricing.py:4-5` raises `ValueError` for `subtotal < 0` | `test_pricing.py:14-19` checks `discount_rate(-1.0)` raises |
| "No other pricing behavior is in scope." | Only discount-rate and discounted-total logic added | Tests cover only the specified thresholds and error path |

No unrequested behavior: `discount_rate` is a focused helper for the required rules, not feature creep. Running `python test_pricing.py` passes.
