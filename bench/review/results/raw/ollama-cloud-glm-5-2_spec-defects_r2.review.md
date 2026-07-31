## Spec review

Spec: `docs/discount-spec.md`. The relevant lines:

> - Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.
> - Orders with a subtotal of 500.00 or more get a 20% discount instead; the 500.00 boundary is included.
> - The discount applies to the subtotal only, never to shipping.
> - A negative subtotal must raise `ValueError`.
> - No other pricing behavior is in scope.

### Wrong

**Must-fix — `pricing.py:8` — "100.00 or more... the 100.00 boundary is included"**
`discount_rate` uses `subtotal > 100.0` for the 10% tier, so a subtotal of exactly `100.0` returns `0.0` instead of `0.10`. The spec says the boundary is included; the operator should be `>=`. No test covers the `100.0` boundary, so the suite does not catch it.

**Must-fix — `pricing.py:17` — "The discount applies to the subtotal only, never to shipping"**
`order_total` computes `(subtotal + shipping) * (1 - rate)`, discounting shipping along with the subtotal. Per spec it must be `subtotal * (1 - rate) + shipping`. The test `order_total(200.0, 10.0) == 189.0` recomputes the expectation the same way the code does (`210 * 0.9`); the spec-correct value is `200 * 0.9 + 10 == 190.0`. The test passing proves consistency with the code, not correctness against the spec.

### Missing

**Must-fix — `pricing.py` (whole file) — "A negative subtotal must raise `ValueError`"**
Neither `discount_rate` nor `order_total` validates the subtotal, so `order_total(-50.0, 5.0)` returns a number instead of raising. There is no test for the negative case. This requirement is entirely undelivered.

### Unrequested

**Minor — `pricing.py:20` (`apply_coupon`) — "No other pricing behavior is in scope"**
A coupon feature (`WELCOME` → flat 5.00 off, floored at 0.0) is added with no spec backing. It is a clean, self-contained addition, but it is scope creep; flag as a product decision for the operator, not a defect in execution.

### Good

- The 500.00 tier (`>= 500.0`, `0.20`) matches the spec including the boundary, and `discount_rate(500.0) == 0.20` is tested.
- Splitting the rate decision out of `order_total` is reasonable and testable.

Summary: two must-fix correctness gaps (shipping incorrectly discounted; 100.00 boundary excluded), one must-fix missing requirement (no `ValueError` on negative subtotal), and one unrequested coupon feature. The test suite agrees with the implementation rather than with the spec, so green tests are not evidence of conformance.
