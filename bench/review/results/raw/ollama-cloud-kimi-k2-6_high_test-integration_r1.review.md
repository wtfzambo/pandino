### Review summary

The diff adds a `place_order` function and replaces a dummy test with real automated evidence. The test is proportionate, independent, and effective.

**No findings.** The diff is clean.

**Why this is good**

- `test_checkout.py:14-20` exercises every observable promise from `docs/checkout-spec.md` at a stable boundary: it calls `place_order` and asserts on the return value *and* the visible side effects, in order.  
- The expected total `27.5` is derived independently (simple arithmetic on the inputs), not recomputed from the implementation.  
- The coarse fakes (`MemoryOrders`, `RecordingMailer`) record real boundary calls; they do not merely assert that internal methods were invoked.  
- The test would fail under concrete, plausible mutations: omitting `orders.save`, omitting `mailer.send_receipt`, swapping their order, returning the wrong value, or passing an incorrect total to either dependency.  
- One focused test is proportionate for a four-line happy-path function; the spec documents no error-handling or edge-case contracts that would require additional coverage.
