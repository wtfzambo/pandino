The diff is small and clean. Findings below.

## Review

**Diff inventory.** `checkout.py` gains `place_order` (compute total, store order, send receipt, return total); `docs/checkout-spec.md` adds "returns the computed total" to the contract; `test_checkout.py` replaces a `print("PASS")` stub with a real test using two coarse boundary fakes.

**Observable promises at stake** (all from the spec, no hidden ones):
1. Returns subtotal + shipping.
2. Stores customer and total.
3. Sends that total in a receipt.
4. Store happens before receipt ("stores … then sends").

**Evidence assessment.** The test is necessary — this is new executable behavior with zero prior coverage. It is effective and independent: `27.5` is hand-derived arithmetic, not recomputed from the implementation; `MemoryOrders`/`RecordingMailer` are exactly the coarse boundary fakes AGENTS.md endorses, and the `events` assertion checks observable stored/sent values, not internal calls. Mutations it would catch: formula change (`total == 27.5` and events both fail); dropped or reordered `save`/`send_receipt` (events list fails); passing `subtotal` instead of `total` to either boundary (events fail); missing `return` or returning a value different from the stored one (the `total == 27.5` assertion independently protects the new "returns the computed total" promise — not redundant with the events check). Ordering protection matches the spec's "then". The `__main__` block and PASS print are required by the repo's runner (`run_tests.sh` does plain `python3 test_checkout.py`, with `set -euo pipefail`, so a failing assertion exits non-zero — verified green, exit 0).

**Minor excess.** None worth flagging. One representative happy-path fixture is proportionate for a two-promise spec with no stated edge cases; no boilerplate, no duplicate of type/static guarantees (there is no type checker configured in this repo).

**Good.** Coarse fakes at the system boundary, independent expected value, single focused test that protects all four documented promises, and the runner wiring (`__main__` + `set -e`) makes the test actually fail loudly rather than pass vacuously.

No must-fix findings; no test changes warranted.
