## Verdict
clean

## Findings
### must-fix
- none
### minor
- `test_checkout.py:20-27` | plausible risk | the single fixture (`20.0`, `7.5`) cannot distinguish the contract from constants that happen to produce 27.5; I confirmed that replacing `total = subtotal + shipping` with `total = subtotal + 7.5` still exits 0 under `run_tests.sh`, and the same blindness applies to a hardcoded `orders.save(customer, 27.5)` | add a second case with different values (e.g. `place_order("Bo", 10.0, 2.5, …)` asserting `12.5` and matching events) so each effect is pinned to the inputs | protects "total is subtotal plus shipping" and "stores/receipts that total" against inlined constants

## Good
- Expected values come from the contract and hand arithmetic, not from the code under test, and every effect is observed at a real boundary (`orders`, `mailer`) through coarse fakes shaped by their documented methods.
- The assertion sequence protects the spec's documented ordering ("stores … then sends") rather than internal call details; I verified the suite still exits 0 after restructuring `place_order` into helpers with identical observable behavior, so it survives the "change the internals" edit.

## Coverage
- Checked: read the full diff, `checkout.py`, `test_checkout.py`, `run_tests.sh`, `docs/checkout-spec.md`, `AGENTS.md`, and the reviewing/testing playbooks. Ran the suite as-shipped (`exit=0`, `test_checkout: PASS`) with `PYTHONDONTWRITEBYTECODE=1` so no `__pycache__` was left behind; `git status --porcelain -uall` afterwards shows only the three supplied modifications. Mutation probes executed in throwaway copies of the files under a temp dir, never in the repo: `return subtotal`, dropped `send_receipt`, dropped `save`, swapped effect order, doubled `save`, `save(customer, subtotal)`, `send_receipt(customer, subtotal)`, `total = subtotal` all failed (`exit=1`); a behavior-preserving internal restructure passed (`exit=0`). Also confirmed the harness is not neutralized by shell handling: `run_tests.sh` uses `set -euo pipefail` and a bare `python3 test_checkout.py`, so a failing assert yields a non-zero exit, and `pytest` is not installed, so the `__main__` block is the only runner rather than duplicated coverage.
- Unverified: none material. The one surviving mutation class (hardcoded constants) is reported as minor because closing it is cheap rather than because it blocks the change; whether `orders: object` / `mailer: object` should be typed is outside my scope.
- Turns: 8 of 20; timed-out commands: none
