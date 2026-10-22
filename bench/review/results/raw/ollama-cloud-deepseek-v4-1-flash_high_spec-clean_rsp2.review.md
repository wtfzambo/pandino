## Verdict
clean

## Findings
### must-fix
- none
### minor
- none

## Good
- `pricing.py` implements every rule in `docs/discount-spec.md` at the exact stated boundaries, discounts the subtotal only, and raises `ValueError` for negative subtotals from the single rate-owner function so `order_total` inherits the rule.
- The change is minimal: two files, no new configuration or unrelated behavior, and the existing `order_total` contract is preserved.

## Coverage
- Spec located: no Backlog.md project (`backlog task list` → "No Backlog.md project found"), no named task or branch commit history beyond `base`; the authoritative specification is `docs/discount-spec.md`, already referenced by the module docstring. No other spec/decision docs exist (`find docs .pandino -type f` → only `docs/discount-spec.md` and playbooks).
- Spec → diff, criterion by criterion:
  - "subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included" → `subtotal >= 100.0 → 0.10`; probed `99.99999999999999` (0.0) and `100.0` (`order_total` = 90.0). Traced.
  - "500.00 or more get a 20% discount instead; the 500.00 boundary is included" → `subtotal >= 500.0 → 0.20` takes precedence over the 10% branch; probed `500.0` (`order_total` = 400.0). Traced.
  - "discount applies to the subtotal only, never to shipping" → `subtotal * (1 - rate) + shipping`; probed `order_total(500.0, 10.0)` = 410.0. Traced.
  - "A negative subtotal must raise `ValueError`" → explicit guard before all branches; probed `order_total(-1.0, 5.0)` and `order_total(-0.01, 0.0)` both raise `ValueError`. Traced.
  - "No other pricing behavior is in scope" → diff adds nothing beyond the rule set; no rounding, currency, or configuration introduced.
- Diff → spec: the only added surface is the `discount_rate` helper, which names the spec's own discount table rather than introducing behavior; nothing in the diff lacks a spec line.
- Ran `PYTHONDONTWRITEBYTECODE=1 python3 test_pricing.py` → `test_pricing: PASS` (exit 0), and probed boundary/negative/shipping/float values directly against the module rather than relying on the suite. `git status --short` unchanged (only the pre-existing ` M pricing.py`, ` M test_pricing.py`).
- Unverified: `NaN`/infinite subtotals return a 0.0 rate and `nan` total instead of raising — the spec's only error rule covers negative subtotals, so this sits outside the promise and I am not reporting it as a divergence. Money-scale rounding is likewise unspecified. Test-suite design and independence are `test-reviewer` territory.
- Turns: 8 of budget; timed-out commands: none.
