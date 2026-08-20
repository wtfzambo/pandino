# Ground truth

## Must-fix

1. **The bulk-discount boundary is missing.** The tests cover the minimum valid
   quantity 1 plus quantities 9, 11, and 20, but not 10. Mutating
   `quantity >= BULK_DISCOUNT_QUANTITY` to
   `quantity > BULK_DISCOUNT_QUANTITY` leaves the suite green.
2. **Every valid total and event expectation follows the production price
   constant.** They import `UNIT_PRICE_CENTS` instead of using the contract's
   1200-cent literal (while the 1000-cent discount remains literal), including
   the minimum valid quantity. Mutating `UNIT_PRICE_CENTS = 1200` to
   `UNIT_PRICE_CENTS = 1500` leaves every such expectation green.
3. **The non-positive-quantity checks do not reliably require `RangeError`.**
   The direct `calculateTotal(-1)` assertion accepts any thrown error. The
   `placeOrder(0, ...)` assertion awaits the full
   `assert.rejects(..., RangeError).catch(() => undefined)` chain, but its
   catch swallows a failed assertion. Its shared fake event list then proves
   that an invalid order has no charge or save side effects, including delayed
   side effects, but mutating only the non-positive production branch from
   `RangeError` to `TypeError` still leaves both checks green with no events.
   The direct `-1` check does still make a `quantity <= 0` to
   `quantity === 0` mutation fail. The separate fractional assertion exercises
   the non-integer branch instead.
4. **The persistence event omits the transaction ID.** The immediate
   quantity-11, deferred quantity-20, and repository-rejection paths each
   require charge-before-save ordering and record the charge, quantity, and
   total, but none records `transactionId` in its save event. The configured
   transaction IDs remain intentionally unobserved, so hardcoding the
   persisted transaction ID to a missing value survives.
5. **The receipt test does not require the repository order ID.** Both happy
   paths use only `assert.ok(receipt.orderId)`, so hardcoding the returned order
   ID to `"pending"` survives. Their totals are also derived from the production
   constant rather than independent contract literals.

## Minor excess

1. **The source-file existence and source-text checks are low-value
   implementation checks.** Importing and exercising `placeOrder` already
   proves the module is available and its behavior; requiring the literal
   `export async function placeOrder` pins source form rather than the
   contract.
2. **The fractional-quantity test pins non-contractual error wording.** It
   correctly requires `RangeError`, but requiring the exact current message
   `"quantity must be a whole number"` is not promised by the order contract.

The two happy paths serve separate timing evidence: the immediate quantity-11
case observes the completed charge-to-save flow, while the deferred quantity-20
case proves saving does not start before delayed payment resolves and supports
delayed normal completion. It awaits a `chargeStarted` signal resolved
synchronously by the payment fake before observing the charge event and that
saving has not started while payment remains pending. After payment resolves,
it awaits a `saveStarted` signal resolved synchronously by the repository fake
before observing the save event. Both boundary-start observations use explicit
signals, so harmless awaits before `payment.charge` or `repository.save` do
not break the evidence. The defect fixture remains blind to the persisted
transaction ID and, under planted item 5, the exact returned order ID; its
truthy order-ID assertion does not independently protect awaiting the
repository result. No redundant event-count assertion remains; exact event
arrays prove the observed sequence and payload.

Scoring is exact-match: each numbered must-fix item and minor group must match
this ground truth. Item 3 and item 4 are compound groups and require every
named component. Genuine unlisted issues are valid findings; do not award false
positives for concerns already covered by the listed groups.

Non-planted protections: the quantity-20 expectation uses the production price
with a literal 1000-cent discount, so it requires one flat discount without
repairing the planted price or threshold gaps. The minimum-valid-quantity
expectation also uses the production price and therefore preserves the planted
price gap while protecting that boundary. The zero-order fake events require no
invalid side effects without repairing the planted error-type gap. A focused
non-finite-number test requires `RangeError` for `Number.NaN` and
`Number.POSITIVE_INFINITY` without asserting exception wording. The fractional
wording assertion remains the separate minor excess. The payment-rejection case
requires no save after a payment failure, and the repository-rejection case
requires the rejection to propagate after charge and save. Both use expected
amounts derived from `UNIT_PRICE_CENTS`, preserving the planted price gap.
