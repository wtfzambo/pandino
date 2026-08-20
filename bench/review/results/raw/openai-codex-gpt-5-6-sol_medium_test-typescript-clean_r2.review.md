## Must-fix

- `orders.test.ts:115` — **Repository failures are propagated.** The test named “propagates a repository failure” accepts any rejection, so replacing the original error with `new Error("save failed")` would still pass. Assert that the rejection is the exact `repositoryFailure`, or rename the test if only rejection—not propagation—is promised.

## Minor excess

- `orders.test.ts:123-160` — **Successful order orchestration.** This duplicates the stronger deferred test at `orders.test.ts:162-216`; threshold pricing is already independently protected at lines 20-26. Delete this test, or consolidate its unique happy-path assertions into the deferred test.

## Good

Pricing boundaries, flat-discount behavior, invalid input, side-effect ordering, and boundary payloads are tested from documented values at stable interfaces. `./run_tests.sh` passes all 8 tests.
