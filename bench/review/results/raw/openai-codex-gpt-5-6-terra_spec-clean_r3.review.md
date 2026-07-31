No Backlog task was identifiable; reviewed against `docs/discount-spec.md`.

### Missing
None.

### Wrong
None.

### Unrequested
- **Minor — `pricing.py:4`**: “No other pricing behavior is in scope.” — `discount_rate` is introduced and tested as a public API, which is an extra product-facing behavior; confirm this API surface is intended.

### Good
- `pricing.py:5-16` implements both inclusive thresholds, discounts subtotal only, and raises `ValueError` for negative subtotals.
- `test_pricing.py:3-17` covers both boundaries, shipping exclusion, and negative input.
- `python test_pricing.py` passes.
