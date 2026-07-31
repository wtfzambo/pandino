from pricing import apply_coupon, discount_rate, order_total

assert discount_rate(50.0) == 0.0
assert discount_rate(101.0) == 0.10
assert discount_rate(500.0) == 0.20

assert order_total(50.0, 5.0) == 55.0
assert order_total(200.0, 10.0) == 189.0

assert apply_coupon(100.0, "WELCOME") == 95.0
assert apply_coupon(100.0, "OTHER") == 100.0
print("test_pricing: PASS")
