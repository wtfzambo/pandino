Reviewed against `docs/discount-spec.md`.

**Missing**
- Minor: `test_pricing.py:15-19` — The spec says “A negative subtotal must raise `ValueError`,” but the negative-subtotal test only calls the helper `discount_rate`; it does not exercise the public `order_total` API that a user would actually call.

**Unrequested**
- `pricing.py:3` / `test_pricing.py:3` — The diff adds a new public function `discount_rate` and tests it directly. The spec states “No other pricing behavior is in scope,” so this is extra public API surface even if it is a reasonable internal decomposition.

**Wrong**
- None. The thresholds (`>= 100.0` for 10%, `>= 500.0` for 20%), boundary inclusion, shipping exclusion, and `ValueError` for negative subtotals all match the spec.

**Good**
- `order_total` correctly applies the discount to `subtotal` only and adds `shipping` afterward.
- Boundary tests cover 99.99, 100.0, 499.99, and 500.0.
