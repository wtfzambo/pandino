**Verdict: test evidence needs fixes before this shipping change is ready.** `./run_tests.sh` passes all 10 tests, but several documented promises can still break without failing them.

### Must-fix

- **Incomplete coverage — `orders.test.ts:23–28`.** The 1200-cent unit price and discount starting at quantity **10** are documented promises. Expectations use the implementation’s `UNIT_PRICE_CENTS`, and the cases skip 10. Changing the price to 1300 or the threshold to 11 would leave these tests green. Assert hand-derived totals, including quantity 10.
- **Incomplete coverage — `orders.test.ts:151–158, 200–209`.** `placeOrder` promises to save the transaction ID received from payment and return the order ID received from saving. Neither ID is compared with its source. Saving a hard-coded transaction ID or returning a different nonempty order ID would pass. Assert the saved `transactionId` and exact returned `orderId`.
- **Demonstrated defect in evidence — `orders.test.ts:49`.** The `.catch(() => undefined)` swallows a failed `assert.rejects`. Replacing zero-quantity validation with a different error before either boundary call would pass, despite the promised `RangeError`. Remove the catch.
- **Incomplete coverage — `orders.test.ts:30–32`.** The negative-quantity test accepts any error. Replacing `RangeError` with `Error` would pass; assert the documented error class.

### Minor excess

- **Demonstrated disproportionate test — `orders.test.ts:54–60`.** Exact exception wording is expressly outside the contract. Delete the message assertion while retaining the fractional-input `RangeError` check.
- **Demonstrated disproportionate test — `orders.test.ts:212–217`.** The source-text regex protects syntax, not an observable ordering result, and would fail on a behavior-preserving export refactor. The imported function is already exercised; delete this test and its file-reading imports.

**Good:** The tests exercise charge-before-save and delayed boundary responses through `placeOrder`, a useful stable cut point.
