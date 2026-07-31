I found the spec at `docs/discount-spec.md` and compared it against the uncommitted diff in `pricing.py` and `test_pricing.py`.

**Result: the diff satisfies every stated requirement.**

- **≥ $100 → 10% discount, boundary included**: `pricing.py:8` returns `0.10` for `subtotal >= 100.0`; test asserts it at `100.0`.
- **≥ $500 → 20% discount instead, boundary included**: `pricing.py:6` returns `0.20` for `subtotal >= 500.0`; test asserts it at `500.0`.
- **Discount applies to subtotal only, never shipping**: `order_total` computes the discounted subtotal and then adds `shipping` unchanged.
- **Negative subtotal raises `ValueError`**: `discount_rate` raises `ValueError(f"negative subtotal: {subtotal}")` for `subtotal < 0`.
- **No other pricing behavior**: the change is limited to the two discount thresholds, the negative check, and the shipping-preserving total.

The tests pass (`python test_pricing.py` → `PASS`), and each spec line has a corresponding implementation line and test assertion. No missing, unrequested, or wrong behavior is evident.
