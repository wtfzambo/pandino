Spec reviewed: `docs/discount-spec.md` (no Backlog task found).

## Missing — must-fix
- `pricing.py:4` — “A negative subtotal must raise `ValueError`.” — Negative subtotals return a zero discount and `order_total(-1, 0)` returns `-1`; no regression test covers the required exception.

## Wrong — must-fix
- `pricing.py:7` — “Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included.” — `subtotal > 100.0` excludes exactly `100.00`, and no test covers that boundary.
- `pricing.py:14` — “The discount applies to the subtotal only, never to shipping.” — The calculation discounts `(subtotal + shipping)`; `order_total(200, 10)` returns `189` rather than the required `190` (and `test_pricing.py:8` codifies the incorrect result).

## Unrequested — product decision
- `pricing.py:17` — “No other pricing behavior is in scope.” — Adds a `WELCOME` coupon feature and associated tests, which are outside the requested discount behavior.

## Good
- `pricing.py:5` correctly implements and `test_pricing.py:5` covers the inclusive `500.00` / 20% threshold.
- `python3 test_pricing.py` passes, but its shipping test confirms the implementation rather than the specification.
