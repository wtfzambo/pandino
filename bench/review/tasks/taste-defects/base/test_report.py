from report import sum_by_category

assert sum_by_category([]) == {}
assert sum_by_category([("food", 2.0), ("rent", 8.0), ("food", 1.0)]) == {
    "food": 3.0,
    "rent": 8.0,
}
print("test_report: PASS")
