from stats import mean, median

assert mean([2.0, 4.0]) == 3.0

assert median([3.0]) == 3.0
assert median([5.0, 1.0, 3.0]) == 3.0
assert median([4.0, 1.0]) == 2.5
assert median([7.0, 1.0, 5.0, 3.0]) == 4.0
assert median([-2.0, -8.0, -4.0]) == -4.0

try:
    median([])
except ValueError:
    pass
else:
    raise AssertionError("median([]) must raise ValueError")

print("test_stats: PASS")
