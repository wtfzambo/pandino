## Test Review

**Summary of changes:** The diff implements `place_order()` with documented behavior (returns total, stores order, sends receipt) and adds an integration test via fakes.

### ✅ Good

The test is **appropriate and well-designed**:

1. **Observable promise protection**: The test exercises the three documented contracts in `checkout-spec.md`:
   - Returns the computed total
   - Stores customer and total via `orders.save()`
   - Sends receipt via `mailer.send_receipt()`

2. **Coarse fakes at system boundaries**: `MemoryOrders` and `RecordingMailer` are simple, coarse fakes that capture side effects without inventing provider internals or mocking internal calls.

3. **Independent expectations**: The test computes `total = 20.0 + 7.5 = 27.5` by hand and verifies:
   - Return value matches: `assert total == 27.5`
   - Side effects occur in order with correct args: `assert events == [("save", "Ada", 27.5), ("receipt", "Ada", 27.5)]`

4. **Would fail under plausible defects**:
   - Omitting the `return total` statement → return value assertion fails ✓
   - Forgetting `orders.save()` call → events list missing first tuple ✓
   - Forgetting `mailer.send_receipt()` call → events list missing second tuple ✓
   - Using wrong math (e.g., `subtotal * shipping`) → return value and events would differ from 27.5 ✓
   - Swapping the order of calls → events list order check fails ✓

5. **Derivation from independent source**: Expected values (20.0 + 7.5 = 27.5) are hand-derived, not computed from implementation.

6. **Single representative case**: One well-chosen fixture is sufficient; the math is trivial and order of side effects is linear.

---

**No new tests warranted.** The existing test is both necessary (protects a real product promise) and proportionate (covers the full behavior of the stable public interface). Type hints and simple implementation make additional unit-level tests redundant.
