## Test review: checkout `place_order`

**Diff summary.** One behavior change (`checkout.py` adds `place_order`), one documentation change (`docs/checkout-spec.md`), and one test change (`test_checkout.py` replaces the `print("PASS")` placeholder with a real test). The docs change is documentation-only and needs no evidence; the behavior change is covered by the new test.

### Must-fix
None.

### Minor excess
None.

### Good

- **`test_checkout.py:20-27`** — The single test exercises the full documented contract at a stable cut point: it asserts the returned total (`27.5`), and that the collaborators received the customer and the *same* total in the documented order (`save` then `receipt`). The expectation is independently derived — `27.5` is hand-computed from `20.0 + 7.5`, and the event contents/order come straight from the spec's "stores the customer and total, then sends that total in a receipt" — not from the implementation.
- **`test_checkout.py:4-16`** — `MemoryOrders` and `RecordingMailer` are coarse boundary fakes that record observable effects, not fine-grained mocks confirming internal calls. They make the "stores" and "sends" promises observable without inventing an external provider's shape.
- **Proportionate.** One representative fixture covers the whole contract; there is no boilerplate, no duplicate check of something the type checker already guarantees, and no assertion on internal structure. The test would fail under each plausible defect (wrong total, missing save, missing receipt, wrong value passed to a collaborator, wrong ordering).

The evidence is necessary, effective, independent, and proportionate. No changes requested.
