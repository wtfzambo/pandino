## Must-fix

None.

## Minor excess

- `orders.test.ts:162` — The deferred orchestration test duplicates protection already provided by the quantity-10 success test. Removing either `await` in `placeOrder` would already fail assertions at lines 154 or 158. Delete this test and the `deferred` helper at lines 11–18; calculation above the threshold remains covered separately.

## Good

- Pricing, flat-discount boundaries, invalid inputs, side-effect ordering, failure paths, and returned receipt data are tested at stable public boundaries using independently derived values.
- `bash run_tests.sh` passes all 8 tests.
