Reviewed against `docs/discount-spec.md`; no Backlog task or descriptive commit exists.

## Missing

- **Must-fix — `pricing.py:4-9`** — Spec: “A negative subtotal must raise `ValueError`”; negative subtotals currently return a zero discount and no test covers the required exception.
- **Good — `pricing.py:5-6`, `test_pricing.py:5`** — The included 500.00 boundary correctly receives and tests the 20% rate.

## Unrequested

- **Must-fix / product decision — `pricing.py:17-21`, `test_pricing.py:10-11`** — Spec: “No other pricing behavior is in scope”; the `WELCOME` coupon introduces an unrequested public pricing feature and should be removed unless explicitly approved.
- **Good** — No unrelated configuration or tooling changes were added.

## Wrong

- **Must-fix — `pricing.py:7`** — Spec: “100.00 or more get a 10% discount; the 100.00 boundary is included”; using `> 100.0` excludes exactly 100.00.
- **Must-fix — `pricing.py:14`, `test_pricing.py:8`** — Spec: “The discount applies to the subtotal only, never to shipping”; the implementation discounts `(subtotal + shipping)`, and the test codifies the incorrect `189.0` instead of `190.0`.

Verification: `python test_pricing.py` passes, but `pytest` exits with code 5 because it collects no tests.
