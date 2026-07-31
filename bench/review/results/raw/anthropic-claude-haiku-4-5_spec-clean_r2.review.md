**Spec compliance: all requirements met.** 

The implementation delivers everything in the discount-spec.md correctly:

✓ **10% discount at $100.00 and above**: `discount_rate(100.0)` returns 0.10, boundary included  
✓ **20% discount at $500.00 and above**: `discount_rate(500.0)` returns 0.20, boundary included  
✓ **Discount applies to subtotal only**: `order_total()` applies the discount only to the subtotal before adding shipping (test confirms: `order_total(500.0, 10.0) == 410.0`)  
✓ **Negative subtotal raises ValueError**: Exception handling and test included  
✓ **No other pricing behavior**: The change is scope-contained  

**Missing**: nothing — all acceptance criteria trace directly to tested code.

**Unrequested**: nothing — the change adds only what the spec asks for.

**Wrong**: nothing — actual values (boundaries at 100.0 and 500.0, discount rates of 0.10 and 0.20, application to subtotal only) match the spec word-for-word.

The code is clean, reads linearly, and the test suite passes.
