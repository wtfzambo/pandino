## Verdict
changes needed

## Findings

### must-fix
**Missing**
- `pricing.py:12-14` | demonstrated defect | A negative subtotal returns a price instead of raising; spec says "A negative subtotal must raise `ValueError`." Probed: `order_total(-1.0, 5.0)` returns `4.0`. | Reject `subtotal < 0` with `ValueError` before pricing (guard in `discount_rate` covers both entry points). | "A negative subtotal must raise `ValueError`." (docs/discount-spec.md)

**Unrequested**
- `pricing.py:17-21` (and `test_pricing.py:1,10-11`) | demonstrated defect | Adds a `WELCOME` coupon feature nobody asked for and the spec excludes: "No other pricing behavior is in scope." The diff also expands the test module to cover it. | Delete `apply_coupon` and its assertions. | "No other pricing behavior is in scope." (docs/discount-spec.md)

**Wrong**
- `pricing.py:7` | demonstrated defect | The 10% tier uses `subtotal > 100.0`, so an order of exactly 100.00 gets no discount; spec includes that boundary. Probed: `discount_rate(100.0)` returns `0.0` and `order_total(100.0, 10.0)` returns `110.0`, where the spec yields `100.0`. | Change the comparison to `subtotal >= 100.0`. | "Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."
- `pricing.py:14` | demonstrated defect | The discount is computed on `(subtotal + shipping)`, so shipping is discounted; spec says it never is. Probed: `order_total(500.0, 10.0)` returns `408.0` instead of `500*0.8 + 10 = 410.0`, and `order_total(200.0, 10.0)` returns `189.0` instead of `190.0`. The 200/10 value is also baked into `test_pricing.py:8`, so the suite agrees with the bug. | Compute `subtotal * (1 - rate) + shipping`. | "The discount applies to the subtotal only, never to shipping."

### minor
none

## Good
- The 20% tier uses an inclusive `>= 500.0`, matching the spec, and tier ordering (20% before 10%) is correct.
- Extracting `discount_rate` gives one readable place for the thresholds, and the no-discount path for small orders is preserved.

## Coverage
- Checked: `git diff` and `git status` (only `pricing.py` and `test_pricing.py` modified, no branch or commit list beyond base commit "base"); spec at `docs/discount-spec.md`, which `pricing.py:1` names as the source of the rules; ran `python3 test_pricing.py` (passes — consistency only, it encodes the shipping bug); probed boundaries and error path directly: `discount_rate(50/100/101/500)`, `order_total(100,10)`, `order_total(200,10)`, `order_total(500,10)`, `order_total(-1,5)`.
- Unverified: no Backlog task exists (`backlog task list` reports "No Backlog.md project found"), so the only authoritative intent is `docs/discount-spec.md` plus the base commit "base", which carries no rationale. Test quality and whether boundary/negative assertions are adequate belong to `test-reviewer`; `test_pricing.py:4` tests 101.00 and `test_pricing.py:8` asserts the buggy 189.00, so the suite currently masks two of the violations above. No formatter, linter, or type checker is configured in the repository to run.
- Turns: 5 of 10 self-imposed (brief set no budget); timed-out commands: none. Repository left as found (`__pycache__` created by probing was removed).
