## Must-fix

- `orders.test.ts:85-115` — **Repository failures are propagated to the caller.** The test name claims propagation, but `assert.rejects(...)` accepts any rejection. Catching `repositoryFailure` and throwing a different error would still pass. Assert that the rejection is the exact `repositoryFailure`; otherwise rename the test if error identity is not contractual.

## Minor excess

- `orders.test.ts:11-18,162-216` — **Payment completes before saving, and the returned receipt waits for saving.** The deferred-promise test duplicates the simpler success test at `orders.test.ts:123-160`: removing either production `await` would already make that test fail through the saved transaction ID or returned order ID. Delete the deferred helper and timing test unless unresolved-promise timing is an explicit contract.

## Good

Pricing boundaries independently establish the flat discount, invalid-number cases cover meaningful runtime values, and the coarse gateway/repository fakes verify visible sequencing and payloads. `./run_tests.sh` passes all 8 tests.
