## Must-fix
None.

## Minor excess
None.

## Good
- `test_checkout.py:20` protects every documented observable promise at a stable boundary: computed/returned total, persisted customer and total, receipt data, and save-before-receipt ordering.
- The hand-derived `27.5` expectation is independent and would catch plausible mutations such as omitting shipping, passing the wrong total, or reversing side effects.
- The coarse in-memory fakes are proportionate.

Verification passed: `python -m pytest -q` and `./run_tests.sh`.
