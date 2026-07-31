## Missing
- None. Every rule in `docs/discount-spec.md:3-6` is implemented and covered by tests.

## Unrequested
- **Minor / operator decision** — `pricing.py:4`: “No other pricing behavior is in scope.” The change exposes and tests `discount_rate` as a new public API, although the existing public behavior could have remained limited to `order_total`.

## Wrong
- None. Thresholds, included boundaries, discount rates, shipping treatment, and negative-subtotal handling match the spec.

**Good:** `python test_pricing.py` passes, and `git diff --check` reports no errors.
