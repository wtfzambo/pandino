## Verdict

The diff adds one observable behavior (`place_order`) plus the matching test and spec line. The test itself is well-formed evidence — it survives every mutation I threw at it. There is **one must-fix**, and it is in the test *infrastructure*, not the test.

I verified all claims below by running probes; the repo tree is untouched (`git status -sb` unchanged, mutations applied in-memory or in a scratch copy under `/tmp` that I deleted).

---

## Must-fix

**`test_checkout.py:30-32` (with `run_tests.sh:4`) — the hand-maintained `__main__` dispatch silently skips unregistered tests, and the runner still reports PASS.**

- **Observable promise affected:** all of them, transitively. The runner's exit code is the signal that says "the checkout contract holds."
- **Why the evidence fails:** the new `if __name__ == "__main__":` block is a manual test registry. A test function that exists in the file but is not listed there never executes, and `print("test_checkout: PASS")` fires unconditionally afterward. The `set -euo pipefail` in `run_tests.sh` is *not* the problem — I confirmed it propagates a Python `AssertionError` as exit 1 correctly. The problem is that no assertion runs at all, so there is nothing to propagate. This is false protection with a green light on top: the literal string `PASS` is printed regardless.
- **Concrete mutation that exposes it:** in a scratch copy I appended a second, deliberately failing test:

  ```python
  def test_shipping_free_over_threshold() -> None:
      assert False, "unregistered test"
  ```

  `./run_tests.sh` → `test_checkout: PASS`, `runner exit=0`. The same file under `python3 -m pytest -q` → `1 failed, 1 passed`. pytest 7.4.4 is already installed in this environment, and the existing test passes under it unmodified (`1 passed`).
- **Cheapest fix:** have `run_tests.sh` invoke `python3 -m pytest -q` and drop the `__main__` block entirely. That deletes hand-maintained dispatch code rather than adding any — the discovery guarantee comes from the tool instead of from a list a future author must remember to update. If pytest must stay out of the dependency set, then the `PASS` print has to be gated on actual execution rather than mere arrival at the end of the file, but collection remains manual and the trap stays armed.

---

## Minor excess

None. I looked specifically for the usual candidates and each one earns its place:

- `test_checkout.py:26` (`assert total == 27.5`) is **not** redundant with the events assertion on line 27. The spec line changed in this very diff to add "returns the computed total," so the return value is a distinct promise; mutant M3 (return `None`, still save and send correctly) is killed only by line 26.
- `test_checkout.py:27` asserting a single ordered `events` list is **not** a brittle internal-structure assertion. `docs/checkout-spec.md:3` says "stores the customer and total, **then** sends that total in a receipt" — ordering is a documented contract, so killing the save/send swap is protecting a real promise, not a coincidence of implementation.
- The fakes are coarse boundary recorders, not mocks asserting call counts or internal wiring. A behavior-preserving refactor of `place_order` would not break this test.

---

## Good

- **Expectations are independently derived.** `27.5` is hand-computed from `docs/checkout-spec.md:4` ("subtotal plus shipping"), not read back out of the implementation. `20.0 + 7.5 == 27.5` is exact in binary floating point, so the assertion is not accidentally fragile — though note that the test does not, and need not, promise anything about inputs where it wouldn't be.
- **The spec was updated alongside the behavior.** The new return-value promise landed in `docs/checkout-spec.md` in the same diff that added it and that asserted it, so the test's source of truth is genuine rather than circular.
- **Mutation coverage is real.** All six plausible defects I ran are killed by assertion: `subtotal - shipping`; receipt sent the subtotal instead of the total; return `None`; receipt before save; save skipped entirely; save records the subtotal.
- **Proportionate.** One test for one function, no generated boilerplate, no speculative cases for behavior nothing promises (persistence failure, mailer errors). I am not asking for more.
- Worth noting in support: because `orders` and `mailer` are annotated `object`, static analysis offers no guarantee here at all — this test is the *only* evidence that `save`/`send_receipt` are called with the right values. That reinforces that it earns its place. (Whether `object` is the right annotation is `taste-reviewer`'s call, not mine.)
