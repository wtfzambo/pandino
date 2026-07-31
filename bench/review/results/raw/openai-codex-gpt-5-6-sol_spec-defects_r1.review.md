## Missing — must-fix

- `pricing.py:4` — Spec: “A negative subtotal must raise `ValueError`.” Negative values instead receive a 0% rate and complete normally, with no test covering the required error.

**Good:** No other required behavior is wholly absent.

## Unrequested — must-fix product decision

- `pricing.py:17` — Spec: “No other pricing behavior is in scope.” `apply_coupon` adds an unrequested `WELCOME` coupon feature and corresponding tests; remove it or explicitly approve and specify the added behavior.

**Good:** No unrelated configuration or tooling changes were added.

## Wrong — must-fix

- `pricing.py:7` — Spec: “100.00 or more get a 10% discount; the 100.00 boundary is included.” The strict `> 100.0` excludes exactly 100.00, while `test_pricing.py:4` avoids testing the required boundary.
- `pricing.py:14` — Spec: “The discount applies to the subtotal only, never to shipping.” The implementation discounts `(subtotal + shipping)`, and `test_pricing.py:8` codifies the incorrect result `189.0` instead of `190.0`.

**Good:** The 500.00 boundary correctly selects 20% and is tested. The current test script passes, but against the divergences above.
