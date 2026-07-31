Tests pass. The diff is clean. Here is the review.

---

## Review

### Must-fix

None.

### Minor

None.

### Good

- **Plain code.** `unique_slug` reads as a linear, boring function: guard clause for the happy path, then a simple while loop. No cleverness, no compression. This is exactly the style AGENTS.md asks for.

- **Named threshold.** `MAX_SLUG_LENGTH` is a domain constant with a comment explaining *why* (readability in shared links), not what the code does. The deletion test passes — inlining `60` would not make complexity vanish, it would just bury a magic number.

- **Typing.** `set[str]` on `taken` is specific and meaningful. No generic `set` or `Collection`.

- **Tests.** The four assertions cover the untaken case, the taken-once case, the taken-multiple case, and the length-truncation case. No recomputation of expected values. No mocks.

- **No speculative generality.** No configurable suffix start, no configurable separator, no callback for conflict resolution. Just `-2`, `-3`, … as needed.

The diff is clean and ready.
