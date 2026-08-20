## Must-fix

- `orders.test.ts:80,115` — Boundary failures should be propagated. Both assertions accept any rejection, so replacing the original payment/repository error with `new Error("order failed")` would still pass. Assert sentinel identity with a predicate such as `error => error === repositoryFailure` (and likewise for payment), or explicitly narrow the claimed contract/test names if error identity is not promised.

## Minor excess

- `orders.test.ts:123-160` — This happy-path test duplicates the stronger deferred test at `orders.test.ts:162-216`; threshold calculations are already independently covered at lines 20–26. Deleting this test loses no distinct observable protection.

## Good

Pricing boundaries, flat-discount behavior, invalid inputs, side-effect ordering, failure paths, persisted payloads, and returned receipt are otherwise well protected at stable public boundaries. `./run_tests.sh` passes all 8 tests.
