## Verdict
changes needed

## Findings

### must-fix

- `pricing.py:14` | demonstrated defect | the discount is applied to `subtotal + shipping`, so shipping is discounted too | spec: "The discount applies to the subtotal only, never to shipping." | Compute the discount on `subtotal` and add undiscounted `shipping`: `subtotal * (1 - rate) + shipping`. | spec `docs/discount-spec.md` — "The discount applies to the subtotal only, never to shipping."
- `pricing.py:7` | demonstrated defect | the 10% tier uses strict `> 100.0`, so a subtotal of exactly 100.00 gets no discount (`order_total(100.0, 10.0)` returns 110.0 instead of 100.0) | spec: "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included." | Use `>= 100.0`. | spec `docs/discount-spec.md` — "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."
- `pricing.py:4-14` | demonstrated defect | negative subtotals are silently accepted; `order_total(-1.0, 5.0)` returns 4.0 and `discount_rate(-1.0)` returns 0.0 | spec: "A negative subtotal must raise `ValueError`." | Add an explicit negative-subtotal guard that raises `ValueError` before pricing. | spec `docs/discount-spec.md` — "A negative subtotal must raise `ValueError`."
- `pricing.py:17-21` | demonstrated defect | `apply_coupon` adds a flat-5.00 WELCOME coupon, a pricing feature nobody requested, with tests and a docstring to match | spec: "No other pricing behavior is in scope." | Delete `apply_coupon` and its tests. | spec `docs/discount-spec.md` — "No other pricing behavior is in scope."

### minor

- none.

## Good
- The 20% tier correctly uses an inclusive `>= 500.0` boundary, and the discount-rate split into a named helper reads plainly.
- The pre-existing behavior for orders below the first tier (`order_total(50.0, 5.0) == 55.0`) is preserved.

## Coverage
- Checked: found no Backlog.md project (`backlog task list` reports "No Backlog.md project found"), so reviewed against the specification named in the module docstring, `docs/discount-spec.md`; read the full uncommitted diff and base revision; executed `test_pricing.py` (passes, but its `order_total(200.0, 10.0) == 189.0` assertion encodes the shipping-discount bug); probed `discount_rate`/`order_total` directly at 50, 100, 200, 500, and -1 subtotals. Removed the `__pycache__` my probe created; working tree is back to the two modified files.
- Unverified: no automated test exercises the 100.00 boundary, shipping preservation, or `ValueError`, so those acceptance criteria have no evidence in the change; test adequacy is the test reviewer's call.
- Turns: 5 of 20 (no explicit budget given; review complete); timed-out commands: none.
