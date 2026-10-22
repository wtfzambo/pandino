**Must-fix — demonstrated defect in test evidence.** `orders.test.ts:80,115`: the failure tests accept *any* rejection. A mutation that catches the payment or repository error and throws an unrelated error without preserving its cause would still pass after the recorded calls, despite losing the original failure. Assert that each rejection is the injected error, or retains it as its cause if translation is intended.

**Minor excess — demonstrated duplication.** `orders.test.ts:123–160`: the immediate-success test repeats the charge, save, and receipt checks in the deferred test at `orders.test.ts:162–216`. Run the deferred test at quantity 10 with an expected total of 11000, then remove the immediate-success test; the calculation test already covers quantity 11.

**Good.** The amounts come from the documented contract, and the tests cover the discount boundary, invalid quantities, saved payload, and payment-before-save ordering. `./run_tests.sh` passed all 8 tests.
