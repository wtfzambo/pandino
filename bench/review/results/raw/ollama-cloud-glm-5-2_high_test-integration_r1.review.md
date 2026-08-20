## Test review: `checkout.py` / `test_checkout.py` / spec

### What changed
- `checkout.py`: new `place_order(customer, subtotal, shipping, orders, mailer)` — returns `subtotal + shipping`, calls `orders.save(customer, total)` then `mailer.send_receipt(customer, total)`.
- Spec: adds "returns the computed total" to the contract.
- `test_checkout.py`: replaces the no-op `print("...PASS")` stub with a real test using coarse recording fakes.

### Analysis
The new test is proportionate and well-targeted. It exercises all four documented promises at the natural cut point (the `orders`/`mailer` boundaries), and every expectation derives from an independent source of truth (the spec + hand-derived `20.0 + 7.5 = 27.5`), not from re-running the implementation:

| Promise (spec) | Evidence | Mutation that fails |
|---|---|---|
| returns the computed total | `assert total == 27.5` | `return subtotal` → 20.0 ✗ |
| total = subtotal + shipping | `27.5` literal | `total = subtotal - shipping` → 12.5 ✗ |
| stores customer and total | `("save", "Ada", 27.5)` in events | drop `orders.save(...)` → missing event ✗ |
| sends that total in a receipt | `("receipt", "Ada", 27.5)` in events | drop `mailer.send_receipt(...)` → missing event ✗ |
| "stores … **then** sends" (sequence) | ordered `events == [save, receipt]` | swap the two calls → order mismatch ✗ |

The fakes are coarse boundary recorders, not fine-grained mocks that only confirm "method was called"; they capture the *values* that flow out, which is exactly the observable promise. The fake interfaces (`save(customer, total)`, `send_receipt(customer, total)`) match the real signatures the implementation depends on — no invented provider shape. No type/lint guarantees are being duplicated by assertions.

### Findings

**No must-fix.** The stub it replaced asserted nothing; the replacement protects every observable promise in the updated spec and fails under concrete plausible mutations. The sequence assertion is legitimate, not excess — the spec documents ordering with "then," so a swap is a real bug worth catching.

**Minor (not actionable):** `events` is typed `list[tuple[str, str, float]]` where the first `str` is really a label union (`"save" | "receipt"`). Tightening it would be cosmetic only; it does not weaken the test.

### Good
- Coarse fakes at the real boundary, values asserted rather than call-counts.
- Independent expected values (literal `27.5`), no implementation recompute.
- Single focused test covering return value, both side effects, *and* their documented order — proportionate to a ~5-line function, no generated boilerplate.
- Runs green: `python3 test_checkout.py` → `test_checkout: PASS`.

Clean diff from a test-evidence standpoint; nothing to add or trim.
