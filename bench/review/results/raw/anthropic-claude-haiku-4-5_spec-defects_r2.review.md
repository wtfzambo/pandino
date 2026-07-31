## Review Findings

**Missing requirements:**

1. **Boundary condition error — `pricing.py:3-8`, spec requires "the 100.00 boundary is included"**
   - The `discount_rate()` function returns 0.0 at 100.0 but the spec requires a 10% discount at exactly 100.00. The condition should be `subtotal >= 100.0`, not `subtotal > 100.0`.

2. **Negative subtotal validation — spec requires "A negative subtotal must raise `ValueError`"**
   - Neither `discount_rate()` nor `order_total()` validates that `subtotal >= 0`. A call to `order_total(-10.0, 5.0)` returns a result instead of raising `ValueError`.

3. **Out-of-scope feature — `pricing.py:16-19`**
   - The `apply_coupon()` function implements coupon logic. The spec explicitly states "No other pricing behavior is in scope"; this is scope creep.

**Good:**

- The discount tiers (10% at 500+, 20% earlier bracket) are correctly structured.
- Discount applies to subtotal only, not shipping: `(subtotal + shipping) * (1 - rate)` is mathematically correct.
- Test coverage for the implemented functions.
