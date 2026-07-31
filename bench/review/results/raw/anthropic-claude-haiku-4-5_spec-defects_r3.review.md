Now I'll review the diff against the spec.

## Findings

**Missing**: The spec requires "A negative subtotal must raise `ValueError`" — the diff does not implement this. `discount_rate(subtotal: float)` and the modified `order_total()` do not validate input; they will silently accept negative values. Line `pricing.py:3-9` and `pricing.py:12-13` do not check for `subtotal < 0`.

**Unrequested**: The diff adds an `apply_coupon(total: float, code: str) -> float` function with a flat $5.00 discount for the "WELCOME" code. The spec states "No other pricing behavior is in scope." This coupon feature was not asked for and violates the scope boundary.

**Wrong**: `order_total()` (line `pricing.py:12-13`) applies the discount to the **total** (subtotal + shipping), not to the subtotal only. The spec says "The discount applies to the subtotal only, never to shipping." The implementation `return (subtotal + shipping) * (1 - rate)` multiplies both by the discount rate. For example, with subtotal=200 and shipping=10: correct result is (200 * 0.9) + 10 = 190; the diff produces (200 + 10) * 0.9 = 189.

**Wrong**: Boundary condition at 100.00. The spec says "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included," but line `pricing.py:5` uses `> 100.0`, which excludes 100.00 exactly. Test coverage masks this: the test at `test_pricing.py:4` checks 101.0, not 100.0.

The test at `test_pricing.py:8` (`assert order_total(200.0, 10.0) == 189.0`) passes with the wrong calculation, proving the test validates the implementation's own logic rather than the spec's numbers.
