Ran `python3 -m py_compile slug.py` and `python3 test_slug.py` — both pass.

The diff is small and reads clearly: a boring loop for suffix collision, no cleverness, constants placed above the public interface as AGENTS.md wants, comment explains a rationale rather than restating code. One real edge case worth a look before calling it done.

**Minor**

- `slug.py:16-23` — the length cap isn't actually enforced once a collision suffix is appended. `base` is truncated to 60 chars, but `f"{base}-{n}"` is returned as-is, so a 60-char base with a taken match yields a 62-char slug. Since the whole point of `MAX_SLUG_LENGTH` is "slugs stay readable in shared links" (per the new comment), this quietly breaks that guarantee in the collision path. Fix: reserve room for the suffix, e.g. truncate `base` to `MAX_SLUG_LENGTH - len(f"-{n}")` (or a fixed smaller cap) before comparing against `taken`, or truncate the final candidate again before returning.
- `slug.py:19` — `n` is a fine loop counter in isolation, but `suffix` or `attempt` would read a bit better given the function otherwise reads plainly. Not worth blocking on.

**Good**

- `unique_slug` is a single, linear collision loop — no cleverness, matches the "boring code" bar.
- New tests follow the existing module's assert-based style rather than introducing a new test framework, and the length-cap test uses an independent computation (`len(...) <= 60`) rather than recomputing the implementation's logic.
- No speculative parameters or unused hooks — `taken` and `title` are exactly what the function needs.
