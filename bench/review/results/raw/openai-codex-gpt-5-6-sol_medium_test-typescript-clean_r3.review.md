## Must-fix

None.

## Minor excess

- `orders.test.ts:11,162-216` — The deferred orchestration test duplicates the observable `placeOrder` contract already protected at `orders.test.ts:123-160`. That test verifies the calculated charge, transaction ID passed to save, operation order, repository order ID, and returned total. The extra test mostly proves JavaScript `await` mechanics and adds substantial bespoke synchronization. Delete `deferred()` and the `"placeOrder awaits payment..."` test.

## Good

The pricing boundary cases, flat discount, invalid quantities, side-effect prevention, failure paths, persistence payload, and receipt are independently derived from `docs/order-spec.md` and exercised at stable public boundaries. `node --test orders.test.ts` passes all 8 tests.
