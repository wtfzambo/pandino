## Missing

- **Minor — `test_pricing.py:12`** — “A negative subtotal must raise `ValueError`.” The test exercises only the new `discount_rate()` helper, not the existing user-facing `order_total()` behavior; add coverage for `order_total(-1.0, ...)`.
- **Good:** Both discount boundaries and exclusion of shipping from the discount are implemented and tested.

## Unrequested

- **Minor / product decision — `pricing.py:4`** — “No other pricing behavior is in scope.” The diff adds `discount_rate()` as a new public API and tests it directly; confirm this API expansion is intended, otherwise keep the helper private or test solely through `order_total()`.
- **Good:** No unrelated configuration or tooling changes.

## Wrong

- **Good:** The 10%/20% thresholds, inclusive boundaries, subtotal-only discount, and negative-subtotal error path match `docs/discount-spec.md`.

`python test_pricing.py` passes. `pytest` discovers no tests because the file uses module-level assertions.
