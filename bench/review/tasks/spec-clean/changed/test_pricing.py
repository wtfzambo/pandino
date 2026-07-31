from pricing import discount_rate, order_total

assert discount_rate(99.99) == 0.0
assert discount_rate(100.0) == 0.10
assert discount_rate(499.99) == 0.10
assert discount_rate(500.0) == 0.20

assert order_total(50.0, 5.0) == 55.0
assert order_total(200.0, 10.0) == 190.0
assert order_total(500.0, 10.0) == 410.0

try:
    discount_rate(-1.0)
except ValueError:
    pass
else:
    raise AssertionError("negative subtotal must raise")
print("test_pricing: PASS")
