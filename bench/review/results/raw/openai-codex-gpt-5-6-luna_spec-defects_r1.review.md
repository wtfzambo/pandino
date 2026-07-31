## Missing

- **Must-fix — `pricing.py:4-9`** — The spec says negative subtotals “must raise `ValueError`” (docs/discount-spec.md:6), but negative values are accepted.
- **Minor — `test_pricing.py:3-8`** — Tests do not cover the required `100.00` boundary or negative-subtotal error path.

## Unrequested

- **Minor — `pricing.py:17-21`** — The `apply_coupon` behavior is outside the stated scope: “No other pricing behavior is in scope” (docs/discount-spec.md:8).

## Wrong

- **Must-fix — `pricing.py:7`** — The spec includes the `100.00` boundary for the 10% discount (docs/discount-spec.md:3), but the implementation uses `subtotal > 100.0`.
- **Must-fix — `pricing.py:14`** — The discount is applied to shipping too, violating “the discount applies to the subtotal only, never to shipping” (docs/discount-spec.md:5). The test’s `189.0` expectation at `test_pricing.py:8` encodes the same incorrect behavior.

The current test script passes, but it does not validate the required boundaries and contains an expectation contrary to the spec.
