## Verdict
changes needed. There are no must-fix findings. The suite is sound, but two tests need changes: one weakens a promise it names, and one duplicates another test.

## Findings
### must-fix
- none

### minor
- `orders.test.ts:80` and `orders.test.ts:115` | demonstrated gap (weak assertion, certain) | Both failure tests call `assert.rejects(...)` with no validator, and the `paymentFailure` (line 64) and `repositoryFailure` (line 88) errors are created and thrown but never compared. The repository test is named "propagates a repository failure", yet a `placeOrder` that replaces the failure with `new Error("order not saved")` still passes both tests. This is a plausible defect: it drops the original cause, which `AGENTS.md` says to preserve when translating errors. Fix: pass the original error as a validator, for example `assert.rejects(placeOrder(1, payment, repository), (error) => error === repositoryFailure)`, and do the same for the payment test. | Observable promise: the caller receives the original payment or repository failure. Mutation: wrap or replace the thrown error in `placeOrder`.

- `orders.test.ts:162-216` (plus the `deferred` helper at lines 11-18) | excess (certain) | The "quantity 11" test duplicates protection the other tests already give. Its quantity-11 total is already checked at `orders.test.ts:26` (`calculateTotal(11)` → 12200). Its ordering check is already covered by the quantity-10 test at lines 123-160. That test uses immediately resolving fakes, so a non-awaiting `placeOrder` would pass a Promise object as `transactionId`, and the `deepEqual` at about line 157 would fail. The deferred scaffolding adds no mutation that this test misses. Delete lines 162-216 and the `deferred` helper, since nothing else uses it. | Test deletion: lines 11-18 and 162-216. Protection is unchanged.

## Good
- The boundary tests at 9 and 10 (`orders.test.ts:20-26`) catch a wrong threshold, a missing discount, and a wrong unit price, with hand-derived expected values.
- The zero-quantity test (`orders.test.ts:40-58`) pins "no charge and no save on invalid input", and the quantity-10 test checks the full charge → save order, including the transaction ID and the returned receipt.
- Error checks use the type only (`RangeError`), which matches the spec's "exception wording is not part of this contract".
- `run_tests.sh` uses `set -euo pipefail`, and the exit code is 0 with 8/8 passing, so no failure is hidden by the shell.

## Coverage
- Checked: read the diff, `orders.ts`, `docs/order-spec.md`, and the playbooks. Ran `./run_tests.sh`: 8 pass, 0 fail, exit 0 (Node v24.21.0, native TypeScript stripping).
- Checked by reasoning only (not executed, since this review is read-only): the mutations for swapped charge/save order, a missing discount, a `> 10` threshold, a skipped save, a double charge, a non-awaited charge, a returned transaction ID in place of the order ID, and bypassed validation in `placeOrder`. Each is caught by at least one test.
- Unverified: no type check was run. There is no `package.json` or `tsconfig.json`, so `tsc` wasn't available. The `let resolve` in `deferred` may trip strict TypeScript's use-before-assignment check, but I did not confirm that. The spec-side change is documentation and needs no test.
- Turns: budget not stated in the brief. Timed-out commands: none. The `timeout` binary is missing on this Mac, so I ran the suite without it.
