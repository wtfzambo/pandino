## Must-fix

None. The documented behavior has proportionate automated evidence.

## Minor

- `orders.test.ts:85` — The test title claims repository failures are “propagated,” but `assert.rejects(...)` at line 115 accepts any rejection. Wrapping the repository error in an unrelated error would still pass. Since exact error identity is not documented, rename this to “rejects when the repository fails”; otherwise document propagation and assert identity.

## Good

- Pricing tests independently cover unit price, threshold boundaries, and flat-versus-repeated discount behavior.
- `placeOrder` tests use coarse boundary fakes and protect validation-before-effects, charge-before-save ordering, payloads, returned receipt, and asynchronous completion.
- `./run_tests.sh` passes all 8 tests.
- No additional test is warranted.
