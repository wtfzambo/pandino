# Testing

Use this playbook to write, change, or review tests, and to choose how to verify a change.

## Choose the evidence by purpose

Choose verification depth by the decision the artifact must support, as the Definition of done in `AGENTS.md` states. Shipping code gets meaningful tests, applicable lint and type checks, and regression-first bug fixes. Explorations are done when they answer their question. Behavior under exploration gets the narrowest test or probe that answers it, and delivery standards apply once the artifact is promoted into shipping code.

For shipping code, tests are maintained evidence for observable product promises. Prefer integration tests at stable boundaries, keep end-to-end coverage to critical user paths, and unit-test pure logic, tricky edge cases, and decisions hard to reach through a boundary.

## Start from the invariants

For substantial shipping work, the planner turns the requirement into "when X, then Y" invariants and writes each as a test against the sketched interface, before the implementation exists. Run them and check they fail for the missing behavior, rather than an import error or a typo. The implementer makes them pass and adds tests for promises the implementation reveals.

## Judge each test with two imagined edits

1. **Break the behavior**: the code returns a wrong value, skips an effect, or performs it twice. A test that still passes proves nothing. Usual causes are an assertion looser than the contract, an expected value computed by the code under test, an assertion on data the test built itself, and a failure swallowed by the shell or test framework.
2. **Change the internals**: every observable result stays the same and the code underneath is restructured. A test that now fails is pinned to the implementation. Usual causes are assertions on internal calls or their order, on private state, and on wording no caller reads.

Keep a test that fails under the first edit and survives the second. Rewrite or delete the rest.

## Write tests that pass both edits

- Drive the code through the interface its users call, with concrete input.
- Take expected values from an independent source: the contract, a fixture, or a result derived by hand.
- Assert what the contract promises, no less and no more. An effect on an external system is behavior; a call to an internal helper is implementation. The error type callers branch on is the contract; its message usually is not.
- Pair a "this never happens" test with a case where it happens, so the test shows it can see the effect.
- Use coarse fakes at real boundaries (network, storage, clock, providers) shaped by the provider's documented contract, and real code inside them.
- Add a test only when it protects a promise whose breakage is a bug, beyond what types, static analysis, compilation, linting, existence checks, or a stronger test already guarantee. Use a few representative fixtures.
