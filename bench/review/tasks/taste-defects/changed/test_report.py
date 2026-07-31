from report import format_summary, sum_by_category, top_categories

assert sum_by_category([]) == {}
assert sum_by_category([("food", 2.0), ("rent", 8.0), ("food", 1.0)]) == {
    "food": 3.0,
    "rent": 8.0,
}

assert top_categories([]) == []
assert top_categories([("food", 2.0), ("rent", 8.0), ("food", 1.0)]) == ["rent", "food"]

assert format_summary([]) == ""
assert format_summary([("food", 2.0), ("rent", 8.0)]) == "rent: 8.00\nfood: 2.00"

print("test_report: PASS")
