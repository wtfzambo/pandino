Planted defects the spec reviewer must find against docs/discount-spec.md (the test suite agrees with the code, so tests prove nothing):

1. **Wrong** — `discount_rate` uses `subtotal > 100.0`: the spec includes the 100.00 boundary (`>=`). The tests only check 101.0, hiding it.
2. **Wrong** — `order_total` applies the discount to `subtotal + shipping`: the spec says the discount applies to the subtotal only, never to shipping. `order_total(200.0, 10.0)` should be 190.0, not 189.0.
3. **Missing** — no `ValueError` on a negative subtotal anywhere.
4. **Unrequested** — `apply_coupon` and the WELCOME code: no spec line asks for coupons ("No other pricing behavior is in scope").

Scoring: found = the review names the defect and ties it to the spec. Also record false positives.
