## Missing

### Minor
- `test_pricing.py:13` — “A negative subtotal must raise `ValueError`.” — The test covers `discount_rate(-1)` rather than the order-facing `order_total(-1, shipping)` path, so the specified order behavior lacks direct regression coverage.

## Unrequested

### Minor
- `pricing.py:4` — “No other pricing behavior is in scope.” — `discount_rate` is introduced as a new public callable (and imported by tests), adding API surface beyond applying discounts to orders; this is a product decision for the operator.

## Wrong

None.

## Good

The implementation correctly applies 10% at `100.00` inclusive, replaces it with 20% at `500.00` inclusive, discounts only the subtotal, and raises `ValueError` for negative subtotals. `python3 test_pricing.py` passes.
