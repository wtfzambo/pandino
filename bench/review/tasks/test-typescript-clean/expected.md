# Ground truth

## Must-fix

None.

## Minor excess

None.

The suite independently protects the 1200-cent unit price and flat 1000-cent
discount with the contract literals 1200, 10800, 11000, 12200, and 23000 at
quantities 1, 9, 10, 11, and 20. Those quantities protect the minimum-valid,
below-threshold, at-threshold, above-threshold, and one-flat-discount
semantics. It requires `RangeError`, but not wording, for zero, negative, and
fractional quantities; focused invalid-number coverage also requires
`RangeError` for `Number.NaN` and `Number.POSITIVE_INFINITY` without asserting
a message. The zero-order `placeOrder` rejection is awaited and typed fakes
record that it has no charge or save side effects. The payment-rejection case
requires no save after a recorded 1200-cent charge, and the repository-
rejection case requires that charge before the recorded save while the call
still rejects. These failure cases are non-planted protections and neither
pins error wording or identity.

The immediate quantity-10 happy path observes complete data propagation for
total 11000, `tx-7`, and `order-9`. The deferred quantity-11 happy path
proves saving does not start before delayed payment resolves and supports
delayed normal completion. It awaits a `chargeStarted` signal resolved
synchronously by the payment fake before confirming the charge event and that
saving has not started while payment is pending. After payment resolves, it
awaits a `saveStarted` signal resolved synchronously by the repository fake
before observing the save event. Both boundary-start observations use explicit
signals, so harmless awaits before `payment.charge` or `repository.save` do
not break the evidence. The exact final repository IDs and total payload
assertions protect result propagation while allowing extra return keys. No
redundant event-count assertion remains; exact event arrays prove the required
sequence and payload.

Scoring: `found` and `total` are both zero. Any must-fix or minor finding is a
false positive.
