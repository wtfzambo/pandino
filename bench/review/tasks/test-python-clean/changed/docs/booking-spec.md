# Booking contract

- One seat costs exactly 2500 cents.
- Members booking at least 4 seats receive a flat 1000-cent discount.
- Omitting `member` means a regular non-member booking.
- Seat count must be a positive whole number. Invalid values raise `ValueError`; the exact exception wording is not part of this contract.
- `confirm_booking(customer, seats, member, repository, mailer)` computes the total, calls `repository.save(customer, total)` first and receives its booking ID, then calls `mailer.send_confirmation(customer, total)`, and returns a dictionary containing that booking ID and total cents.
