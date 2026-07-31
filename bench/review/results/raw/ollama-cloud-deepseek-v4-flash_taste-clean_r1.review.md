Tests pass, syntax is clean. Here is my review.

---

## Review of `slug.py` + `test_slug.py`

### Must-fix

None.

---

### Minor

**`slug.py:17` — suffix can exceed `MAX_SLUG_LENGTH`**  
The constant is named `MAX_SLUG_LENGTH` and the comment says slugs should stay "readable", but the suffix is appended *after* truncation. If a 60-char base is taken, the result is `{base}-2` (62 chars). Either rename the constant to something like `SLUG_TRUNCATE_LENGTH` to clarify it is not a hard cap, or truncate the final result too. This is a naming/contract issue, not introduced by the diff — the constant is new in this diff, so it is a finding on the new code.

**`slug.py:17` — infinite loop on empty base taken**  
If `slugify(title)` returns `""` (e.g. title is `""` or `"@!#"`) and `""` is in `taken`, the loop checks `"-2"`, `"-3"`, etc. It will terminate (since `"-N"` is unlikely to be in `taken`), but the returned slug `"-2"` is misleading. A guard like `if not base: return base` before the taken check would make the behavior explicit. Not introduced by the diff in the sense that the edge case existed before, but the new function introduces the possibility.

---

### Good

- **Linear, boring control flow.** Guard clause for the untaken case, then a simple while loop. No cleverness.
- **Named constant with intent comment.** `MAX_SLUG_LENGTH` is a domain threshold, placed close to the code that uses it, with a comment explaining *why* (readability in shared links).
- **Type annotation on `taken`.** `set[str]` communicates the expected collection and signals O(1) lookup intent.
- **Tests are minimal and readable.** They cover the three core cases (untaken, first conflict, second conflict) plus the truncation boundary. No mockery, no recomputed expectations.
- **No speculative machinery.** No configurable suffix start, no pluggable separator, no abstract `SlugGenerator` class. Just the function the problem needs.

The diff is clean. Ship it after deciding on the `MAX_SLUG_LENGTH` naming question.
