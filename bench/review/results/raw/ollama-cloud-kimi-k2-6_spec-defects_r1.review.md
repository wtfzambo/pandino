The diff modifies `pricing.py` and `test_pricing.py`. The spec is in `docs/discount-spec.md`.

### Missing

- **`pricing.py:9`** — *"A negative subtotal must raise `ValueError`"* (spec line 4). There is no validation for negative inputs in `discount_rate` or `order_total`, and no test for it.

- **`test_pricing.py`** — *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included"* (spec line 1). No test covers the exact `100.0` boundary.

### Unrequested

- **`pricing.py:17-21`** — *"No other pricing behavior is in scope"* (spec line 5). The `apply_coupon` function and its flat-$5 `WELCOME` code are extra pricing behavior not in the spec.

- **`test_pricing.py:11-12`** — Tests for the unrequested `apply_coupon` function.

### Wrong

- **`pricing.py:9`** — *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included"* (spec line 1). The code uses `subtotal > 100.0` (strict), so a subtotal of exactly `100.0` incorrectly returns `0.0`.

- **`pricing.py:14`** — *"The discount applies to the subtotal only, never to shipping"* (spec line 3). `order_total` computes `(subtotal + shipping) * (1 - rate)`, applying the discount to shipping as well. It should be `subtotal * (1 - rate) + shipping`.

- **`test_pricing.py:9`** — Test asserts `order_total(200.0, 10.0) == 189.0`, which matches the buggy shipping-inclusive discount. Per spec, the expected total should be `190.0` (`200 * 0.9 + 10`).
