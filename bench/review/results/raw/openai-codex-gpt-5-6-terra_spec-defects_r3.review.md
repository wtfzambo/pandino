No Backlog task exists; reviewed against `docs/discount-spec.md`.

## Wrong — must-fix

- `pricing.py:7` — “subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included”: `>` excludes exactly `100.00`.
- `pricing.py:14` — “discount applies to the subtotal only, never to shipping”: the discount is applied to `subtotal + shipping` (e.g. 200 + 10 yields 189, not 190).

## Missing — must-fix

- `pricing.py:5` — “A negative subtotal must raise `ValueError`”: no validation exists; negative subtotals return a total instead.

## Unrequested — product decision

- `pricing.py:17` — “No other pricing behavior is in scope”: adds `WELCOME` coupon behavior, plus related tests, which the spec does not request.

## Good

- The 500.00 inclusive 20% tier is implemented and tested.
- The test suite passes, but its 10% shipping expectation currently codifies the spec divergence.
