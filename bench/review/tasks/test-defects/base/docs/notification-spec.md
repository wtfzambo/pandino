# Notification retry contract

- Retry delivery after HTTP 429 or 503. Do not retry other statuses.
- The retry delays for attempts one, two, and three are 10, 20, and 40 seconds.
- The mail provider exposes its retry delay through the `Retry-After` response header; its JSON response body is not part of our contract.
- Report that a retry was scheduled, but the exact wording is not part of the product contract.
