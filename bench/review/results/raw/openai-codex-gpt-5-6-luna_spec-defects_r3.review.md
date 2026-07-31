Reviewed against `docs/discount-spec.md`.

### Wrong

- **`pricing.py:7`** — Spec: “subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.” Uses `>` instead of `>=`, so exactly `100.00` receives no discount.
- **`pricing.py:14`** — Spec: “The discount applies to the subtotal only, never to shipping.” Discounts `(subtotal + shipping)`, incorrectly discounting shipping; the test at `test_pricing.py:8` encodes this wrong result.

### Missing

- **`pricing.py:4-9`** — Spec: “A negative subtotal must raise `ValueError`.” Negative subtotals are accepted without error.
- **`test_pricing.py:3-11`** — Boundary, shipping-preservation, and negative-subtotal requirements lack regression tests.

### Unrequested

- **`pricing.py:17-21`** and **`test_pricing.py:10-11`** — Spec: “No other pricing behavior is in scope.” Adds a `WELCOME` coupon feature not requested by the specification.

### Good

- The `500.00` threshold and 20% rate are implemented correctly and covered by a test.
