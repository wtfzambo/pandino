## Review: `slug.py`, `test_slug.py`

The diff is small and mostly reads well — plain control flow, a guard clause, no speculative machinery. The one real problem is in the test, not the implementation.

### Must-fix

**`test_slug.py:11` — the length assertion passes by construction and hides a broken invariant.**
`assert len(unique_slug(long_title, set())) <= 60` only exercises the no-collision path, where truncation trivially guarantees the bound. On the collision path the suffix is appended *after* truncation, so the cap is exceeded:

```
no collision:    59 chars  'word-word-...-word'
one collision:   61 chars  'word-word-...-word-2'
99 collisions:   63 chars  'word-word-...-word-100'
```

AGENTS.md asks that expected values come from an independent source of truth rather than re-deriving the code's own path. Fix: add a case that asserts the bound with the base slug already taken, e.g. `assert len(unique_slug(long_title, {unique_slug(long_title, set())})) <= MAX_SLUG_LENGTH`.

That test will then fail, which is the point — it exposes `slug.py:17`, where `base` is truncated to the full `MAX_SLUG_LENGTH` with no room reserved for the `-N` suffix. Whether the cap is a hard guarantee or a soft target is a spec call, so I'm flagging the behavior and leaving the semantics to the spec reviewer; the test gap itself is squarely a quality issue.

### Minor

**`test_slug.py:11` — hardcoded `60` duplicates `MAX_SLUG_LENGTH`.** The constant is already exported and the test file already imports from `slug`; import and use it so the threshold lives in one place.

**`slug.py:17` — an empty or punctuation-only title that is already taken yields `-2`, a leading-hyphen slug.** Present in the diff, and arguably a spec question rather than a style one, but `unique_slug("", {""}) == "-2"` is an odd URL to hand out; worth a deliberate decision rather than falling out of the code.

### Good

- `MAX_SLUG_LENGTH` is a named domain threshold sitting next to the behavior it governs, and its comment explains *why* 60 rather than restating the value — exactly the comment style AGENTS.md asks for.
- `unique_slug` is the boring version: guard clause for the common case, then a plain incrementing loop. No cleverness to unwind, and it reads aloud the way it's written.
- `slugify(title)[:MAX_SLUG_LENGTH].rstrip("-")` chains three obvious operations; I considered flagging it as dense but it narrates cleanly as "slugify, truncate, drop a trailing hyphen."
- No speculative parameters or extension points; nothing here fails the deletion test.
- The bare-assert script style matches the pre-existing `test_slug.py` rather than introducing a second convention, which is the right call under the consistency principle even though `pytest` is installed.

I ran `python3 test_slug.py` (passes) and checked for a formatter, linter, and type checker — the repo configures none, so there were no tool rules to defer to.
