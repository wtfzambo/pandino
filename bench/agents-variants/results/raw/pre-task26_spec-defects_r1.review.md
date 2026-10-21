## Spec source

No Backlog task, branch name, or commit message to trace (single commit `base`, branch `main`). `AGENTS.md` routes product truth to `backlog/docs/specs/`, which does not exist; the only authoritative document is `docs/discount-spec.md`, named by the module's own docstring (`pricing.py:1`) — I reviewed against it.

**Verdict: not ready. Three must-fix divergences, one of them a behavior the spec explicitly forbids, plus one forbidden scope addition.**

---

### Missing

**MUST-FIX — Negative subtotal validation absent** — `pricing.py:4-14` (demonstrated defect)
Spec: *"A negative subtotal must raise `ValueError`."*
Neither `discount_rate` nor `order_total` validates; probed `order_total(-5.0, 10.0)` returns `5.0` silently. No acceptance criterion for this exists anywhere in the diff.

**MINOR — No coverage at either stated boundary** — `test_pricing.py:3-8` (incomplete coverage)
Spec: *"the 100.00 boundary is included"* / *"the 500.00 boundary is included"*. Tests use `101.0` and `500.0`; the inclusive `100.00` case — the one that is broken — is never asserted. (Test depth/appropriateness is `test-reviewer`'s call; I flag only that the spec's boundary words have no traceable check.)

---

### Unrequested

**MUST-FIX — `apply_coupon` is outside scope** — `pricing.py:17-21`, `test_pricing.py:1,10-11`
Spec: *"No other pricing behavior is in scope."*
Coupon support appears nowhere in the spec, adds public API surface, and drags two tests with it. Useful, but unrequested; orchestrator adjudicates.

---

### Wrong

**MUST-FIX — 10% boundary is exclusive, spec says inclusive** — `pricing.py:7` (demonstrated defect)
Spec: *"Orders with a subtotal of 100.00 or more get a 10% discount; the 100.00 boundary is included."*
`if subtotal > 100.0` yields `discount_rate(100.0) == 0.0`; probe: `order_total(100.0, 10.0)` returns `110.0`, spec answer `100.0`. `>=` is required.

**MUST-FIX — Discount applied to shipping** — `pricing.py:13-14` (demonstrated defect)
Spec: *"The discount applies to the subtotal only, never to shipping."*
`(subtotal + shipping) * (1 - rate)` discounts both. `subtotal + shipping * ...` is wrong too; correct is `subtotal * (1 - rate) + shipping`. Probes: `order_total(200.0, 10.0)` → `189.0` vs spec `190.0`; `order_total(500.0, 10.0)` → `408.0` vs spec `410.0`.

**MUST-FIX — Test asserts the spec-violating value** — `test_pricing.py:8` (demonstrated defect)
`assert order_total(200.0, 10.0) == 189.0` locks in the shipping-discount bug as expected behavior. Spec: 10% off subtotal only, `190.0`. The suite agreeing with the code proves consistency, not correctness — the expected value is not derived independently from the spec.

---

### Good

The 20% rule traces cleanly both ways: `pricing.py:5` uses `>= 500.0` and 20% correctly takes precedence over the 10% tier, matching *"500.00 or more get a 20% discount instead"*; `discount_rate(500.0) == 0.20` holds. The pre-existing no-discount path is preserved (`order_total(50.0, 5.0) == 55.0`).
