Reviewed working diff against `docs/discount-spec.md` (no Backlog task reference found).

## Wrong — must-fix

- `pricing.py:7` — “**100.00 boundary is included**”: `subtotal > 100.0` excludes exactly `100.00`; no test covers that boundary.
- `pricing.py:14` — “**discount applies to the subtotal only, never to shipping**”: the rate is applied to `subtotal + shipping`, discounting shipping too; `test_pricing.py:8` incorrectly codifies `189.0` rather than the required `190.0`.
- `pricing.py:13` — “**A negative subtotal must raise `ValueError`**”: no validation exists, so negative subtotals produce a total instead; no regression test covers this requirement.

## Unrequested — product decision

- `pricing.py:17` — “**No other pricing behavior is in scope**”: adds a `WELCOME` coupon feature not requested by the spec.

## Good

- `pricing.py:5` correctly applies the 20% rate at the inclusive `500.00` boundary, with a corresponding test.
- `python test_pricing.py` passes, but it does not validate the required 100.00, shipping, or negative-subtotal behavior.
