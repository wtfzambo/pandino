Tests pass. The diff is small and clean — one new public function `unique_slug` plus a length constant, with tests.

**minor**

- `slug.py:18` — The length cap only applies to `base`; the `-N` suffix can push the returned slug past `MAX_SLUG_LENGTH` (e.g. a 60-char base collides → `…-2` = 62 chars). The comment says slugs are kept short "so [they] stay readable in shared links," so the intent covers the whole slug, not just the prefix. If the cap is meant to bound total length, reserve room for the suffix (e.g. truncate `base` to `MAX_SLUG_LENGTH - len("-NN")`-ish, or truncate the final result). If 60 is only a soft target for the base, say so in the comment. Low severity — the current test (`len(...) <= 60` on the no-collision case) doesn't exercise this.

**good**

- Plain, linear control flow: guard-clause early return, then a boring counting loop. No cleverness, no bit tricks — exactly the "scrivi codice come mangi" version. A `itertools.count` rewrite would be worse, not better.
- Module ordering is right: constant → `slugify` → `unique_slug` (caller before callee).
- The comment explains *why* 60 exists (intent/constraint), not what the code does.
- Tests assert behavior from an independent expectation (literal `"hello-3"`), and the length test uses a separate fixture rather than recomputing the bound.
- No speculative generality: `taken` is a plain `set[str]`, no registry class, no pluggable separator. The deletion test passes — nothing here is a pass-through.

No must-fix findings.
