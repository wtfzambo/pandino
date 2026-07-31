Reviewed against `docs/discount-spec.md`.

### Missing

- **Must-fix — `pricing.py:4-9`** — Spec: “A negative subtotal must raise `ValueError`.” Negative subtotals are accepted, and no regression test covers this requirement.

### Unrequested

- **Minor — `pricing.py:17-21`, `test_pricing.py:10-11`** — Spec: “No other pricing behavior is in scope.” The new `apply_coupon` feature adds coupon behavior outside the requested discount rules; this is a product decision for the operator.

### Wrong

- **Must-fix — `pricing.py:7`** — Spec: “subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.” `subtotal == 100.0` receives no discount because the comparison is `> 100.0`.

- **Must-fix — `pricing.py:14`** — Spec: “The discount applies to the subtotal only, never to shipping.” The implementation discounts `(subtotal + shipping)`, so shipping is discounted too; the test’s expected `189.0` for `200.0 + 10.0` should be `190.0`.

The existing test script passes, but it does not catch these specification violations.
