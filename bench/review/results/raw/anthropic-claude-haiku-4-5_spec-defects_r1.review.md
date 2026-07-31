## Review findings

**Missing: Critical error handling**

The spec requires: "A negative subtotal must raise `ValueError`." The implementation does not check for negative subtotals anywhere. `discount_rate()` accepts any float without validation, and `order_total()` does not guard against negative input. The test suite does not verify this behavior either.

**Unrequested: Coupon feature (scope creep)**

The diff adds `apply_coupon()` with "WELCOME" code logic for a flat $5.00 discount. This feature is not mentioned in `docs/discount-spec.md` and is outside the stated scope: "No other pricing behavior is in scope." This is a product decision to flag — the function is well-built and tested, but it was not asked for.

**Wrong: Discount applied to shipping**

The spec states: "The discount applies to the subtotal only, never to shipping." The implementation at `pricing.py:13` calculates:

```python
return (subtotal + shipping) * (1 - rate)
```

This multiplies both subtotal and shipping by `(1 - rate)`, applying the discount to both. The spec requires the discount to apply only to the subtotal. The correct formula should be:

```python
return subtotal * (1 - rate) + shipping
```

This is verified by the test at `test_pricing.py:9`: `assert order_total(200.0, 10.0) == 189.0`. With a $200 subtotal and $10 shipping, the 10% discount gives `200 * 0.9 + 10 = 180 + 10 = 190.0`, not `189.0`. The test's expected value of `189.0` confirms the current (wrong) behavior: `(200 + 10) * 0.9 = 189.0`.

**Boundary condition check: included boundaries**

The spec requires: "the 100.00 boundary is included" and "the 500.00 boundary is included." The implementation at `pricing.py:4-5` correctly uses `>=` for both thresholds, capturing the boundary values. The test at `test_pricing.py:4` confirms `discount_rate(500.0) == 0.20`, which is correct.

**Missing test: negative subtotal**

No test verifies that negative subtotals raise `ValueError` as required.
