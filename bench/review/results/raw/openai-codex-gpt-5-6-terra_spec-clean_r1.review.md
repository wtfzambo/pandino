## Missing

### Minor
- `test_pricing.py:12` — “A negative subtotal must raise `ValueError`.” — The test invokes the new helper rather than `order_total`, so the specified order-pricing entry point’s error behavior is not directly covered.

## Unrequested

### Minor
- `pricing.py:4` — “No other pricing behavior is in scope.” — Adding public `discount_rate()` creates an unrequested pricing API surface; retain it only if this is an intentional product decision, otherwise make it implementation-private.

## Wrong

No divergence found: thresholds include both boundaries, the 20% rate supersedes 10%, shipping is excluded from discounting, and negative subtotals raise `ValueError`.

## Good

`python test_pricing.py` passes.
