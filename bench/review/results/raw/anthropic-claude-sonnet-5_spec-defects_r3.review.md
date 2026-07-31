I found the spec (`docs/discount-spec.md`, referenced directly in `pricing.py`'s docstring) and checked the diff against each requirement, including running the arithmetic independently rather than trusting the tests.

## Must-fix

**`pricing.py:14`** — Discount is applied to `(subtotal + shipping)` combined, not to subtotal alone: `return (subtotal + shipping) * (1 - rate)`. Spec: *"The discount applies to the subtotal only, never to shipping."* Verify against the diff's own test: for `order_total(200.0, 10.0)` the correct result is `200*0.9 + 10 = 190.0`, but the code (and the test asserting it) produces `189.0` — shipping is being discounted too. The test doesn't catch this because it was written to match the implementation, not the spec (a textbook case of the test recomputing the expectation the code's way).

**`pricing.py:5`** — Boundary bug: `if subtotal > 100.0: return 0.10` excludes exactly `100.0`. Spec: *"a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."* At `subtotal == 100.0` this returns `0.0` instead of `0.10`. No test exercises `discount_rate(100.0)` or `order_total` at that exact boundary, so the bug is silent — only `101.0` and `500.0` are tested, sidestepping the one value the spec calls out explicitly.

**Missing entirely** — *"A negative subtotal must raise `ValueError`."* There is no validation in `discount_rate` or `order_total`, and no test for it. This acceptance criterion has zero code and zero test coverage.

## Unrequested (scope creep)

**`pricing.py:18-21`** — `apply_coupon` (flat $5 off for a `"WELCOME"` code) is new public API nobody asked for, and the spec closes with *"No other pricing behavior is in scope."* This isn't a gray-area addition; the diff adds exactly the kind of behavior the spec explicitly forbids. Flag for the operator as a product decision, but it should not have shipped alongside this task.

## Summary

The 500.00 boundary (`>=`) is correct, and the basic no-discount case (`order_total(50, 5) == 55.0`) still holds. But two of five spec lines are implemented wrong (discount touches shipping; 100.00 boundary excluded), one is missing outright (negative-subtotal validation), and one unrelated feature (`apply_coupon`) was added despite the spec explicitly ruling out anything beyond the stated discount rules. The tests pass only because they were written to match the buggy implementation rather than independently derived from the spec's numbers.
