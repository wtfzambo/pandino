# Order contract

- One unit costs exactly 1200 cents.
- Quantities of 10 or more receive one flat 1000-cent discount.
- A quantity must be a positive whole number. Invalid quantities raise `RangeError`; exception wording is not part of this contract.
- `placeOrder(quantity, payment, repository)` calculates the total, charges it to receive a transaction ID, then saves the quantity, total, and transaction ID to receive an order ID. It returns that order ID and the total cents.
