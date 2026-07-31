## Spec review: ✓ Complete and correct

The implementation satisfies all requirements from `docs/discount-spec.md`:

**Missing:** None. All acceptance criteria are met:
- ✓ 10% discount for subtotal ≥ $100.00 (line boundary included: `discount_rate(100.0) == 0.10`)
- ✓ 20% discount for subtotal ≥ $500.00 (boundary included: `discount_rate(500.0) == 0.20`)
- ✓ Discount applies to subtotal only, not shipping (line 14: `discounted + shipping`)
- ✓ Negative subtotal raises `ValueError` (`test_pricing.py:12–16`)

**Unrequested:** None. No scope creep—the diff implements exactly what was asked.

**Wrong:** None. Behavior traces correctly:
- Discount rate precedence is correct ($500 threshold checked before $100 due to order of conditions)
- Boundary conditions match spec exactly (≥ not >)
- Shipping is properly separated from discount application
- Tests validate all thresholds and error case

The implementation is straightforward, the tests are representative (covering boundaries and the error path), and all passing.
