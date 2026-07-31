The spec is `docs/discount-spec.md`. The diff is two files: `pricing.py` and `test_pricing.py`.

**Missing** — none. All acceptance criteria are implemented and tested.

**Unrequested** — none. No scope creep, no extra configuration, no tooling changes.

**Wrong** — none. Tracing the values:
- 100.00 boundary included: `discount_rate(100.0) == 0.10` ✓
- 500.00 boundary included: `discount_rate(500.0) == 0.20` ✓
- Discount applies to subtotal only, shipping excluded: `order_total(500.0, 10.0) == 410.0` (500×0.8 + 10) ✓
- Negative subtotal raises `ValueError`: `discount_rate(-1.0)` raises ✓
- "No other pricing behavior is in scope": diff is minimal, focused.

**Good:** The implementation correctly orders the tier checks (`>= 500` before `>= 100`), the tests compute expected values independently (no re-implementation of the logic), and the error path is covered.

Everything traces cleanly both ways.
