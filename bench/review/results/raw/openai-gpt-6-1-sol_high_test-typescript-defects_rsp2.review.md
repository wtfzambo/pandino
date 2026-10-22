## Verdict
changes needed

## Findings
### must-fix
- `orders.test.ts:24` | incomplete coverage | All price expectations derive from the production `UNIT_PRICE_CENTS`, so the suite does not protect the documented 1200-cent price. | Use independently calculated expected totals, such as 1200, 10800, and 12200. | Promise: exact unit pricing; changing `UNIT_PRICE_CENTS` back to 1000 would leave all tests passing.

- `orders.test.ts:23` | incomplete coverage | Pricing cases cover quantities 9 and 11 but omit the inclusive discount boundary at 10. | Add an assertion that `calculateTotal(10)` equals 11000. | Promise: the discount starts at 10; changing `quantity >= BULK_DISCOUNT_QUANTITY` to `quantity > BULK_DISCOUNT_QUANTITY` would escape detection.

- `orders.test.ts:49` | demonstrated defect | The `.catch(() => undefined)` swallows failures from `assert.rejects`, so the test verifies only that no side effects occurred, not that zero rejects with `RangeError`. The negative-quantity test also accepts any exception type. | Remove the catch and require `RangeError` in the negative-quantity assertion. | Promise: invalid quantities raise `RangeError` without charging or saving; returning a successful receipt early for zero, or throwing `Error` instead of `RangeError` for nonpositive quantities, would currently pass.

- `orders.test.ts:127` | incomplete coverage | Neither success test records the saved `transactionId`, and both accept any truthy receipt `orderId`; the deferred test therefore also fails to prove that the repository’s resolved ID is returned. | Assert the complete saved payload and exact returned receipt using the fake payment and repository IDs. | Promise: persist the payment’s transaction ID and return the repository’s order ID; replacing either ID with a constant—or removing `await` from `repository.save`, leaving a truthy Promise as `orderId`—would pass the current suite.

### minor
- `orders.test.ts:54` | demonstrated defect | The fractional-quantity test pins exception wording that the contract explicitly excludes, unnecessarily blocking equivalent validation implementations. | Replace the message predicate with `assert.throws(() => calculateTotal(1.5), RangeError)`. | Test change: preserve error-type protection while allowing wording-only refactors.

- `orders.test.ts:212` | demonstrated defect | The source-text test duplicates import/execution coverage and requires a particular declaration syntax rather than observable behavior. | Delete this test and its filesystem/URL imports. | Test deletion: existing behavioral tests already require a usable export; an equivalent exported async arrow function would incorrectly fail the regex.

## Good
- Tests exercise the public interface with coarse payment and repository fakes; event assertions protect observable side effects and charge-before-save ordering.
- Above-threshold cases protect a flat discount rather than a per-unit discount, and failure cases check that errors do not become successful orders.

## Coverage
- Checked: shipping-code evidence against `docs/order-spec.md`; all changed code, tests, and the test runner. `bash run_tests.sh`: **10/10 passed**. `git diff --check`: passed. Concrete mutation scenarios assessed by inspection; no mutations executed.
- Unverified: regression-first development history cannot be established from the working diff. No separate lint/type-check configuration is present. Referenced pickup skill is absent.
- Turns: 6 of unspecified budget; timed-out commands: none.
