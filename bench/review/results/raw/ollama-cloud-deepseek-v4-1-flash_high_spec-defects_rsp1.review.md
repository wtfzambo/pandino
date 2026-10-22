## Verdict
changes needed

## Findings

### must-fix

- `pricing.py:14` | incomplete coverage | the discount is applied to `(subtotal + shipping)`, so shipping is discounted too; spec line "The discount applies to the subtotal only, never to shipping." Evidence: `order_total(200.0, 10.0)` returns `189.0`, spec requires `200.0*0.9 + 10.0 = 190.0`; `order_total(500.0, 5.0)` would return `404.0`, spec requires `405.0` | compute `subtotal * (1 - rate) + shipping` | "The discount applies to the subtotal only, never to shipping." (`docs/discount-spec.md:5`)
- `pricing.py:7` | incomplete coverage | the 10% tier uses `subtotal > 100.0`, excluding the boundary; spec line "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included." Evidence: `discount_rate(100.0)` returns `0.0` and `order_total(100.0, 0.0)` returns `100.0`, spec requires `90.0` | change the comparison to `subtotal >= 100.0` | "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included." (`docs/discount-spec.md:3`)
- `pricing.py:4-14` | incomplete coverage | no guard rejects a negative subtotal; spec line "A negative subtotal must raise `ValueError`." Evidence: `order_total(-10.0, 0.0)` returns `-10.0` instead of raising, and `discount_rate(-10.0)` returns `0.0` | raise `ValueError` for a negative subtotal on the pricing path before any rate or total is computed | "A negative subtotal must raise `ValueError`." (`docs/discount-spec.md:6`)

### minor

- `pricing.py:17-21` | plausible risk (unrequested) | `apply_coupon` with the `WELCOME` code adds a whole pricing rule nobody asked for, contradicting spec line "No other pricing behavior is in scope."; it is a new public function with its own semantics (`max(total - 5.0, 0.0)`) and will need audit and maintenance | delete `apply_coupon` and its imports/assertions (`test_pricing.py:1,10-11`) unless the user approves the coupon feature as a spec change | "No other pricing behavior is in scope." (`docs/discount-spec.md:7`)

## Good
- The 20% tier is implemented with an early return, so `>= 500.0` correctly wins over the 10% tier, matching "get a 20% discount instead" with the 500.00 boundary included.
- The base case is preserved: `order_total(50.0, 5.0)` still returns `55.0`, and the added tests run green (`test_pricing: PASS`).

## Coverage
- Checked: read `AGENTS.md`, `.pandino/playbooks/reviewing.md`, `docs/discount-spec.md`, `pricing.py`, `test_pricing.py`; inspected the uncommitted diff and commit list (`git status`, `git diff`, `git log` — single `base` commit, no branch/task brief, so the spec is `docs/discount-spec.md` as named by the module docstring); ran `python3 test_pricing.py` (passes); probed actual values at 50/99.99/100/101/200/500 subtotals and a negative subtotal against spec-derived expectations. No Backlog task exists in this repository (`git ls-files` shows no task files), so acceptance criteria come from the spec lines only.
- Unverified: no explicit statement on float-vs-decimal rounding policy, so exact-equality behavior for values like `0.1` fractions was not judged; test quality, independence, and whether tests should be restructured are left to `test-reviewer`; code-level taste in `discount_rate`'s shape is left to `taste-reviewer`.
- Turns: 6 used; no turn budget was stated in the brief; timed-out commands: none.
