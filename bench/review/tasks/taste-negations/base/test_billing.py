from billing import invoice_total, parse_amount

assert parse_amount("12.34") == 1234
assert invoice_total([]) == 0
assert invoice_total(["12.34", "0.66", "5.00"]) == 1800

print("test_billing: PASS")
