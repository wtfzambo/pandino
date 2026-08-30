from billing import collection_action, invoice_total, parse_amount

assert parse_amount("12.34") == 1234
assert invoice_total([]) == 0
assert invoice_total(["12.34", "0.66", "5.00"]) == 1800

assert collection_action(30, 0) == "wait"
assert collection_action(30, 3) == "wait"
assert collection_action(31, 3) == "stop"
assert collection_action(31, 2) == "collect"

print("test_billing: PASS")
