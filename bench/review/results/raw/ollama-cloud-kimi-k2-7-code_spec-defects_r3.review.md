Review of the working diff against `docs/discount-spec.md`.

## Missing

- **Must-fix** `pricing.py`: no validation for negative subtotal. The spec states, "A negative subtotal must raise `ValueError`," but `discount_rate` accepts any negative number and returns `0.0`.  
- **Minor** `test_pricing.py`: no assertion for the `100.00` boundary, so the off-by-one bug below is not caught.

## Wrong

- **Must-fix** `pricing.py:7` — boundary excluded. `if subtotal > 100.0` excludes the exact `100.00` threshold; the spec says, "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included." `discount_rate(100.0)` currently returns `0.0`, should be `0.10`.  
- **Must-fix** `pricing.py:12` — discount applied to shipping. `order_total` computes `(subtotal + shipping) * (1 - rate)`, but the spec says, "The discount applies to the subtotal only, never to shipping." For `order_total(200.0, 10.0)` the correct result is `200.0 * 0.9 + 10.0 = 190.0`; the diff and its test expect `189.0`.

## Unrequested

- **Scope creep** `pricing.py:15`, `test_pricing.py`: `apply_coupon` and its tests are added when the spec explicitly says, "No other pricing behavior is in scope." It is a product decision whether to keep, remove, or split this into a separate task; it is not a defect in the discount logic itself.

## Good

- The `500.00` boundary is inclusive (`>= 500.0`) and tested correctly.
- The module docstring still points to the spec.
- The test script runs and exits cleanly.

**Overall verdict:** the discount logic does not yet satisfy the spec. The two wrong behaviors (excluded `100.00` boundary, discount on shipping) and the missing negative-subtotal validation must be fixed; the coupon code should be removed or treated as out-of-scope.
