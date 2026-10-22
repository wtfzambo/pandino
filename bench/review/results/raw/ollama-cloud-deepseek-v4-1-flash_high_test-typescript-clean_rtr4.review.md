## Verdict
changes needed

## Findings

### must-fix
- `orders.test.ts:162` | demonstrated defect in the evidence itself | the deferred test's unbounded `await chargeStarted.promise` / `await saveStarted.promise` leaves the suite hung, not failed, when `placeOrder` saves before charging (mutant: `await repository.save({..., transactionId: "pending"})` then `await payment.charge(...)`); the run stalls after 7 of 8 tests and `run_tests.sh` sets no timeout, so the only verification command never reports | bound the test — `test("placeOrder awaits payment and saving quantity 11", { timeout: 2000 }, ...)` — or delete it per the excess finding below | the "charge then save" ordering promise; with `{ timeout: 2000 }` the same mutant yields `✖ ... (2001ms)` and `fail 3` instead of a hang

### minor
- `orders.test.ts:80`, `orders.test.ts:115` | plausible risk | both failure tests use `assert.rejects(...)` with no matcher, so they pass on any rejection; mutants that replace the provider error (`throw new Error("charge failed")`, `throw new Error("save failed")`) pass all 8 tests, i.e. the tests named "rejects a payment failure" and "propagates a repository failure" agree with cause-dropping, which `AGENTS.md` forbids | assert the fake's error (`assert.rejects(placeOrder(...), paymentFailure)` / `repositoryFailure`) so error-mangling fails | the observable promise that the provider's failure reaches the caller intact
- `orders.test.ts:162` | incomplete coverage of its own claim | the test adds no protection over the `quantity 10` and failure tests for the defects it targets (missing awaits, double charge, wrong amount, save-before-charge all fail 1–3 other tests; with save-first plus a plausible-looking id `"tx-7"`, three other tests fail while this one only hangs) at the cost of ~55 lines, the `deferred` helper, and a fourth `OrderEvent` copy | delete it, or keep it only with the timeout from the must-fix | no new promise is protected; deletion removes the excess and the hang
- `orders.test.ts:61`, `orders.test.ts:86`, `orders.test.ts:124`, `orders.test.ts:163` | maintenance risk in the evidence | the 13-line `OrderEvent` union and the event-recording fakes are copied per test, so any change to the `save` payload requires four identical edits and invites one copy drifting out of sync with the others | hoist one module-scope event type (and optionally a recorder) and reuse it | test infrastructure cost only; assertions stay the same

## Good
- The total fixtures are independent of the implementation and land on the real boundary: 9 → 10800, 10 → 11000, 11 → 12200, 20 → 23000, which fails per-unit discount and `>`-instead-of-`>=` mutants. The non-finite test earns its place: a `Math.floor(q) !== q` guard is rejected only by it.
- The success test asserts the exact `save` payload and the exact `charge` amount with strict deep-equality, and the "no side effects" test is paired with cases where those events do appear.

## Coverage
- Checked: read `AGENTS.md`, `.pandino/playbooks/reviewing.md`, `.pandino/playbooks/testing.md`, `orders.ts`, `orders.test.ts`, `docs/order-spec.md`, `run_tests.sh`; full suite passes 8/8 in a scratch copy; 20 mutants applied in `/tmp/orderreview` (per-unit discount, strict `>`, dropped positive check, wrong unit price, double subtraction, `TypeError`, save-before-charge ×2, unawaited charge/save/both, wrong saved quantity, swallowed payment failure, double charge, wrong charge amount, pre-discount return, validation skipped, `Math.floor` integer guard); repo left unchanged (`git status` still the three modified files, no scratch writes inside it).
- Unverified: there is no tsconfig, package.json, or lint script, so type-level and static guarantees were not exercised (notably `deferred`'s `resolve` is assigned inside the executor and would not typecheck under `strict`); the `PaymentGateway`/`OrderRepository` fakes cannot be checked against a real adapter because none exists.
- Turns: 9 of 20 (budget not supplied); timed-out commands: one mutation script hit the 120s tool limit because the save-before-charge mutant hangs the suite — re-run with per-mutant timeouts.
