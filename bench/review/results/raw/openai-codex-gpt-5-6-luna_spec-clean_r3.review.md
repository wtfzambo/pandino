## Review

No missing, unrequested, or incorrect behavior found.

The diff satisfies every requirement in `docs/discount-spec.md`:

- Inclusive 10% and 20% thresholds
- Discount applied only to subtotal
- Negative subtotals raise `ValueError`
- Existing pricing behavior remains intact

`python test_pricing.py` passes.
