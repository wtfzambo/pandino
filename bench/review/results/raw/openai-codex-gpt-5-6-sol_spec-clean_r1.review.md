Spec source: `docs/discount-spec.md`; no Backlog task exists.

### Missing
No findings. Every discount rule is implemented and covered by a test.

### Unrequested
- **Minor / product decision — `pricing.py:4`:** “No other pricing behavior is in scope.” The change exposes `discount_rate()` as a new public API, although only `order_total()` behavior was required.

### Wrong
No findings. Thresholds, inclusive boundaries, subtotal-only discounts, shipping treatment, and negative-subtotal errors match the spec.

`python test_pricing.py` passes.
