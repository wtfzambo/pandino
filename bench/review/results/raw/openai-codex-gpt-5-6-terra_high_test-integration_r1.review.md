## Must-fix

None.

## Minor excess

None.

## Good

- `test_checkout.py:20` independently verifies the documented total (`20.0 + 7.5 = 27.5`), return value, both visible boundary effects, and their required order. It would fail for plausible mutations such as omitting either effect, sending/storing the wrong total or customer, swapping effects, or returning the wrong value.
- The coarse recording fakes are proportionate and avoid coupling to internal implementation details.
- Ran `./run_tests.sh`: passes.
