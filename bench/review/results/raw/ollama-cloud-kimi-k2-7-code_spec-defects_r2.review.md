Reviewed the working diff against `docs/discount-spec.md`.

## Missing

- `pricing.py:4` — `discount_rate` never raises `ValueError` for a negative subtotal. Spec: *“A negative subtotal must raise `ValueError`.”*
- `test_pricing.py` — no test for the negative-subtotal error path.

## Wrong

- `pricing.py:8` — `if subtotal > 100.0` excludes exactly `100.00`. Spec: *“Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.”* Should be `>= 100.0`.
- `pricing.py:14` — `return (subtotal + shipping) * (1 - rate)` applies the discount to shipping as well. Spec: *“The discount applies to the subtotal only, never to shipping.”*
- `test_pricing.py:10` — `order_total(200.0, 10.0) == 189.0` matches the buggy combined discount, not the spec. Per spec it should be `190.0` (`200 * 0.90 + 10`).

## Unrequested

- `pricing.py:17` — `apply_coupon` and the WELCOME flat-discount behavior are not in scope. Spec: *“No other pricing behavior is in scope.”*
- `test_pricing.py:12-13` — coupon tests for unrequested behavior.

## Good

- `pricing.py:1` docstring correctly points to `docs/discount-spec.md`.
- The `500.00` boundary uses `>=`, matching the spec.
- Existing happy-path discount-rate assertions cover the 0%, 10%, and 20% tiers (though not the exact boundaries).

Overall the diff does **not** cleanly satisfy the spec: two core rules are implemented incorrectly, a required error path is absent, and extra out-of-scope behavior was added.
