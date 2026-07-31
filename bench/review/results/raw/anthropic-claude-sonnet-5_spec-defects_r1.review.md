## Spec

Found at `docs/discount-spec.md`, referenced directly in `pricing.py`'s docstring. Rules:

1. Subtotal ≥ 100.00 → 10% discount.
2. Subtotal ≥ 500.00 → 20% discount instead.
3. Discount applies to subtotal only, never to shipping.
4. Negative subtotal → raise `ValueError`.
5. "No other pricing behavior is in scope."

## Findings

**Must-fix — discount applied to shipping, contradicting spec rule 3.** `pricing.py:15` computes `(subtotal + shipping) * (1 - rate)`, which discounts the shipping amount too. Spec: "The discount applies to the subtotal only, never to shipping." Correct formula would be `subtotal * (1 - rate) + shipping`. The diff's own test (`test_pricing.py:8`, `order_total(200.0, 10.0) == 189.0`) was computed with the same wrong formula — the correct value per spec is `200*0.9 + 10 = 190.0`, not `189.0`. This is a case of the test agreeing with the code rather than an independent source of truth, so it hides the bug instead of catching it.

**Must-fix — 100.00 boundary excluded, contradicting rule 1.** `pricing.py:6` uses `subtotal > 100.0`, but the spec states "the 100.00 boundary is included." At exactly `subtotal = 100.0`, this falls through to `0.0` instead of `0.10`. The diff's test suite never exercises `discount_rate(100.0)` (only `101.0`), so this off-by-one boundary bug isn't caught. Note the 500.00 boundary is done correctly (`>=`) and is tested (`discount_rate(500.0) == 0.20`), which makes the 100.00 asymmetry look like an oversight rather than intent.

**Must-fix — negative subtotal validation is entirely missing.** Spec rule 4: "A negative subtotal must raise `ValueError`." Neither `discount_rate` nor `order_total` in `pricing.py` performs any such check, and there's no test for it. This acceptance criterion is untraced to any code or test.

**Unrequested — `apply_coupon` function (`pricing.py:18-21`).** The spec explicitly closes scope: "No other pricing behavior is in scope." A flat `WELCOME` coupon discount is a new pricing behavior added to `order_total`'s sibling API, plus corresponding tests, none of which trace back to any requirement. This is scope creep — flag as a product decision for the operator, not sneak it in as part of the discount-rate task.

## Summary

Three of the four spec-mandated behaviors are either wrong or missing (shipping incorrectly discounted, 100.00 boundary excluded, negative-subtotal validation absent), and the diff adds a coupon feature nobody asked for while the spec says nothing else is in scope. The test suite passes, but only because two of its assertions were derived from the same flawed logic as the implementation rather than the spec's independent numbers — it doesn't prove correctness here.
