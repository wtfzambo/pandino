## Spec review: pricing diff

Spec: `docs/discount-spec.md`. No Backlog task present (branch is `main`, single commit `base`), so I reviewed the diff against the spec it points to.

The spec has five requirements. I find **three must-fix divergences** and **one scope-creep**.

### Wrong (must-fix)

1. **100.00 boundary is excluded, not included** — `pricing.py:7`
   - Spec: *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*
   - Code: `if subtotal > 100.0: return 0.10` uses strict `>`, so `discount_rate(100.0)` returns `0.0` instead of `0.10`. The test suite never exercises the boundary (`101.0` and `500.0` only), so it passes while the spec is violated.

2. **Discount is applied to shipping, not subtotal only** — `pricing.py:13`
   - Spec: *"The discount applies to the subtotal only, never to shipping."*
   - Code: `return (subtotal + shipping) * (1 - rate)` discounts the combined sum, so shipping is discounted too. Correct form is `subtotal * (1 - rate) + shipping`. `order_total(200.0, 10.0)` should be `190.0`; the code (and its test) assert `189.0`, i.e. the test recomputes the expectation the same buggy way and proves nothing.

### Missing (must-fix)

3. **Negative subtotal does not raise `ValueError`** — `pricing.py` (no location)
   - Spec: *"A negative subtotal must raise `ValueError`."*
   - Neither `discount_rate` nor `order_total` validates the subtotal. `order_total(-50.0, 5.0)` returns `-45.0` and `discount_rate(-50.0)` returns `0.0`. No test covers this either.

### Unrequested (product decision for the operator)

4. **`apply_coupon` / WELCOME coupon added** — `pricing.py:16-20`
   - Spec: *"No other pricing behavior is in scope."*
   - The diff introduces a coupon feature with a `WELCOME` code (flat 5.00 off, clamped at zero) that the spec explicitly excludes. Well-built but out of scope; either remove it or get the spec amended.

### Good

- The 20% tier and its `>= 500.0` boundary are correct (`pricing.py:5`), and `discount_rate(500.0) == 0.20` is tested against the spec's stated boundary.
- The tiering order (check 500 first, then 100) correctly implements "20% instead of 10%".
