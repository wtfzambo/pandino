## Test Review

**Diff scope:** `checkout.py` gains `place_order()` (its first real behavior); `test_checkout.py` replaces a no-op print with an actual test; spec doc updated to match.

### Must-fix
None.

### Minor excess
None. One test, one function, proportionate.

### Verification performed
- `pytest test_checkout.py -q` → 1 passed.
- `python3 test_checkout.py` (the `run_tests.sh` path) → prints `PASS`, exit 0.
- Confirmed no other module implements an `orders`/`mailer`-like class the fakes could deviate from — `MemoryOrders`/`RecordingMailer` are minimal structural fakes covering exactly the two methods `place_order` calls, not invented shapes of a real external provider.

### Analysis
- **Promise covered:** `place_order` returns `subtotal + shipping`, calls `orders.save(customer, total)` then `mailer.send_receipt(customer, total)`, in that order — matches `docs/checkout-spec.md:3-4` exactly.
- **Independent expectation:** `20.0 + 7.5 == 27.5` is hand-derived arithmetic, not a recomputation of the implementation.
- **Order enforced correctly:** asserting on the single shared `events` list (`[("save", ...), ("receipt", ...)]`) checks call order, which the spec's "then" requires — not just that both calls happened.
- **Kills plausible mutations:** swap the two calls, drop either call, use `subtotal - shipping`/`subtotal` alone, return `None`, or pass the wrong customer/total to either fake — each breaks the single assertion. This is real regression protection, not tautological.
- **Proportionate:** one representative fixture for a pure two-line arithmetic function; no reason for additional cases (e.g., negative shipping) absent a documented edge-case contract.

**Good.** No test changes needed.
