## Taste review

Clean diff. Plain code, named constant for the domain threshold, public functions ordered caller-before-callee, tests assert on visible behavior with an independent bound. No cleverness to rewrite.

### Minor

- `slug.py:18` — `unique_slug` enforces `MAX_SLUG_LENGTH` only on the base. On a collision the returned slug is `f"{base}-{n}"`, which when `base` is already 60 chars (e.g. a long title whose slug is taken) exceeds 60, contradicting the "kept short so slugs stay readable" intent of the constant. The test only checks the no-collision case so it doesn't catch this. Either state explicitly that the limit is advisory for the base only (and drop/loosen the comment), or truncate `base` to leave room for the suffix. Simplest honest fix: cap the base, e.g. `base = slugify(title)[:MAX_SLUG_LENGTH].rstrip("-")` and accept that suffixed slugs may run a few chars over — then make the comment say "base is capped" rather than "slugs stay short".

### Good

- `unique_slug` is a boring loop with a guard clause and a clear happy path — exactly the plain version.
- `MAX_SLUG_LENGTH` is named and lives next to the behavior it governs; the structural `rstrip("-")` and `2` start need no constants.
- Test fixtures are representative and independent (`"word " * 30` to probe length, hand-picked `taken` sets for collisions), no mocks.
