## Review

No findings. The diff satisfies all requirements in `docs/discount-spec.md`:

- Inclusive 10% and 20% thresholds.
- Discount applies only to subtotal.
- Negative subtotals raise `ValueError`.
- No unrelated pricing behavior added.

`python test_pricing.py` passes.
