Diff read and probed. Tests pass, but one promise in the new code doesn't hold off the happy path.

## must-fix

**`slug.py:6` / `slug.py:17` — the length cap applies to the pre-suffix stem, so the final slug can exceed `MAX_SLUG_LENGTH`.**
*Demonstrated defect.* `MAX_SLUG_LENGTH` is documented as keeping slugs short, and `test_slug.py:11` asserts a slug is `<= 60`, but the cap is applied before the `-2`/`-3` suffix is appended:

```
no-collision len 59
collision   len 61   ("...-word-2")
12 collisions len 62  ("...-word-12")
```

The comment and constant name describe a property of the returned slug; the code enforces it only for the stem, and the test only exercises the no-collision path, so it never detects the gap. Fix: pick one semantics and make name, comment, and test agree — either reserve room for the suffix (`slugify(title)[:MAX_SLUG_LENGTH - len(f"-{n}")]`, re-`rstrip("-")`) or rename to `MAX_SLUG_STEM_LENGTH` and say the suffix is added on top. Which semantics is wanted is a product choice; the current mixed message is not.

## minor

**`slug.py:17` — an empty stem yields `""`, and with `""` taken it yields a leading-hyphen slug `-2`.**
*Demonstrated defect (partly pre-existing).* `slugify` already returns `""` for punctuation-only titles (pre-existing, asserted at `test_slug.py:5`), but the new function turns that into `"-2"`, a shape the "words joined by single hyphens" contract never produces. Fix: add `if not base: return base` before suffixing, or decide an explicit fallback label if empty slugs are unacceptable.

**`test_slug.py:10-11` — the length assertion is vacuous for the case that matters.**
*Incomplete coverage.* `unique_slug(long_title, set())` can never collide, so it tests only truncation; the suffix interaction is exactly where the cap breaks. Fold into the must-fix: assert length on a colliding call too.

## good

`taken`/`n` naming is plain, the collision scan is the boring loop rather than anything clever, the function is pure (no mutation of `taken`, matching the functional-core preference), and placement follows the file's order — constant first, caller `slugify` before callee `unique_slug`. No contrastive-negation noise, nesting stays at one level, and no speculative machinery beyond the named threshold that AGENTS.md explicitly endorses.

No formatter, linter, or type-checker config exists in this repo, so no tooling was run beyond `python3 test_slug.py`.
