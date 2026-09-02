# Taste review — billing helpers

Small, clear diff; tests pass. The logic is boring and correct, the boundary tests are well chosen, and the two constant comments are textbook examples of a motivated negation. The problem is that the diff also imported the *unmotivated* kind of negation everywhere else, which AGENTS.md explicitly forbids.

## Must-fix

**Unmotivated contrastive negations (AGENTS.md: "add a negation only when it rules out a stated plausible misreading")** — three spots where a negated clause is bolted onto something no reader could plausibly have misread:

- `billing.py:17` — the `parse_amount` docstring gained ", not a pre-parsed integer cent value". No one reading `amount_text: str` with `amount_text.split(".")` assumes the input is pre-parsed cents; the original docstring ("Convert a dollar amount with two decimal places into cents.") was correct. Revert to the original.
- `billing.py:26` — `# Return not a status message, but the total in cents.` No plausible reader assumes `invoice_total` returns a status message. Delete the comment; the function names itself.
- `billing.py:31` — parameter `age_days_not_status_text`. No one reading an `int` age-in-days parameter assumes it is a status text; the negation just makes the name worse. Rename to `age_days`.

The two constant comments ("counts calendar days, not business days", "count total calls, not retries") are the *good* kind — each rules out a genuine plausible misreading and explains why the magic number is what it is. Keep those; drop the other three.

## Minor

None — the `Literal` return alias earns its keep as a named domain type for a three-state public contract, the constants sit near the behavior they govern, and the test matrix (30/0, 30/3, 31/3, 31/2) pins both the boundary and the due-window-precedence ordering with hand-derived expectations.

## Good

- `collection_action` is a linear, three-guard function with the happy path visible — exactly the "boring control flow" the standard asks for.
- The check order is encoded in the tests (`30, 3 → wait` proves the due window precedes the attempt limit), so the precedence claim is evidenced, not just commented.
- Tests are integration-style at the module boundary, consistent with the existing file's style.

Net: rename the parameter, delete the two stale negations, revert the docstring — then this is clean.
