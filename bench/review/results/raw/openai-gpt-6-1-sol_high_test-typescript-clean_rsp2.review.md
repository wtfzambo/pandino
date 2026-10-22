## Verdict
changes needed

## Findings
### must-fix
- `orders.test.ts:80,115` | incomplete coverage | Both failure tests accept any rejection, so they do not verify preservation of the payment or repository failure. Replacing either error with an unrelated `Error` would still pass, despite the repository’s requirement to preserve original failures. | Add rejection predicates that verify the original error identity, or its preserved cause if translation is intended. | Promise: callers retain the underlying failure for diagnosis; mutation: catch a boundary failure and throw `new Error("order failed")` without a cause.

### minor
- `orders.test.ts:123` | plausible risk | The quantity-10 success test largely duplicates the stronger deferred success test; the exact discount threshold is already covered by `calculateTotal(10)`. This adds another full fixture to maintain without a distinct workflow promise. | Keep one deferred success test covering charge/save payloads and the receipt, and retain threshold cases in the focused total-calculation test. | Remove the immediately resolved success test, or merge its necessary assertions into the deferred test.

## Good
- Pricing expectations are literal, independently derived values covering both sides of the threshold and a repeated-discount defect.
- Coarse boundary fakes verify observable payment/storage effects, including sequencing and absence of effects after invalid input or payment failure.

## Coverage
- Checked: complete working diff, documented order contract, implementation, test runner, and all tests. `bash run_tests.sh`: **8 passed**. `git diff --check`: passed.
- Unverified: mutation resistance was assessed by inspection; no mutations were executed. No configured type-check or lint commands were present. Repository files were left unchanged.
- Turns: 5 of 12 (self-imposed budget); timed-out commands: none.
