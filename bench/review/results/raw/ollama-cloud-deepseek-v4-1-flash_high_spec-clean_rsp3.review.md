## Verdict
clean

## Findings
### must-fix
- none

### minor
- none

## Good
- Every rule in `docs/discount-spec.md` is implemented exactly: inclusive 100/500 boundaries, the 20% replacing rather than stacking on 10%, discount confined to the subtotal, and `ValueError` for negative subtotals.
- The branch order (`>= 500` before `>= 100`) makes the "20% instead" wording the obvious reading, and shipping is added after the discount in a single recognizable step.

## Coverage
- Checked: spec source. No Backlog project exists (`backlog task list` → "No Backlog.md project found"), the branch is `main` with one commit `base`, so the request is the committed specification `docs/discount-spec.md` (referenced by the `pricing.py` module docstring). Working diff is `pricing.py` and `test_pricing.py` only; nothing staged.
- Checked: `python3 test_pricing.py` → `test_pricing: PASS`, exit 0.
- Checked: boundaries through the public path — `100.0 → 0.10`, `99.99 → 0.0`, `500.0 → 0.20`, `499.99 → 0.10`, `500.01 → 0.20`; `order_total(100.0, 10.0) == 100.0`, `order_total(500.0, 10.0) == 410.0`, `order_total(500.0, 0.0) == 400.0` (no 10% stacking).
- Checked: discount never touches shipping — `order_total(100.0, 7.5) == 97.5`, `order_total(500.0, 7.5) == 407.5`, `order_total(150.0, 0.0) == 135.0`.
- Checked: negative subtotal raises `ValueError` both directly and through the customer path (`order_total(-0.01, 5.0)`, `-1.0`, `-100.0` all raise `ValueError`).
- Checked: unrequested scope — the only addition is the public `discount_rate` helper, which encodes exactly the specified rule and is used by `order_total`; no new pricing behavior (rounding, tax, shipping rules) was added. Whether a helper should be public is structural, outside spec scope.
- Unverified: rounding/precision behavior — the spec states amounts to two decimals but says nothing about rounding, and `order_total(499.99, 10.0)` yields `459.99100000000004` from inherited float arithmetic. No spec line is violated, so this is not a finding; it becomes one only if the product requires cent-accurate totals, which the spec does not state. Test shape/adequacy belongs to `test-reviewer`.
- Repository state restored: the `__pycache__` created by the test run was removed; `git status` shows only the two pre-existing modified files. Timed-out commands: none (`timeout` is not installed in this environment; the checks ran directly and exited quickly).
- Turns: 7 of unspecified budget (brief gave none).
