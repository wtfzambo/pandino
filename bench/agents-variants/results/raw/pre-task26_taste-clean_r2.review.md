## Review: uncommitted diff (`slug.py`, `test_slug.py`)

Scope: `git diff` of 2 files (21 insertions), read against `AGENTS.md`. Tests pass (`python3 test_slug.py` → PASS). No formatter/linter/type checker is installed in this repo (`ruff`, `mypy`, `pyright`, `black` all absent, no `pyproject.toml`/`setup.cfg`), so those checks were skipped rather than re-done by eye.

### must-fix

1. **`slug.py:17-24` — the length limit is bypassed on the collision path.** `base` is cut to `MAX_SLUG_LENGTH`, then `-2`/`-3` is appended *outside* the limit, so the "max length" constant is not a max. Demonstrated defect (reproduced): `unique_slug("word "*30, {base})` → 61 chars; `unique_slug("a"*70, {"a"*60})` → 62 chars. Fix: reserve room for the suffix, e.g. suffix the *already-truncated* base and re-truncate to `MAX_SLUG_LENGTH` before returning (`f"{base[:MAX_SLUG_LENGTH - len(suffix)]}-{n}".rstrip("-")`) — or simpler, keep `base` longer and trim to fit once the final string is known.

2. **`test_slug.py:11` — the length test only covers the branch that works.** Incomplete coverage: the only length assertion calls `unique_slug(long_title, set())`, i.e. the untaken path, which is why finding 1 passed. Fix: assert the length of `unique_slug(long_title, {unique_slug(long_title, set())})` — the suffixed result — is also `<= 60` (that assertion now fails, which is the point).

### minor

3. **`slug.py:17-24` — an empty base produces a malformed "unique" slug.** Plausible risk (demonstrated behavior, intent unverified): `unique_slug("", {""})` → `"-2"`, and `unique_slug("!!!", set())` → `""`, inherited from `slugify`. If callers can reach this, a leading-hyphen/blank slug is not usable. Fix: when `base` is empty, return a named fallback (e.g. `"untitled"`) before the collision loop, or state in the docstring that callers must reject empty titles.

4. **`slug.py:17` — truncation cuts mid-word.** Plausible risk, product judgment rather than a bug: `"word "*30` truncates to `...word-word` only by luck of the cut point; other titles end mid-token, which sits awkwardly with the comment's "readable in shared links". Fix if you care: after cutting to length, trim back to the last hyphen (`base.rsplit("-", 1)[0] or base`) before `rstrip`.

### good

- `unique_slug` is a pure function taking `taken` as input and leaving mutation to the caller — the functional-core shape `AGENTS.md` asks for, not a hidden global registry.
- Module ordering holds (docstring, constant, public functions; no helper soup), the constant is named and commented with its intent, the docstring states the `-2, -3` contract, and types are annotated on the public signature.
- The loop is the boring version and reads aloud cleanly; no clever bit-twiddling, no speculative generality (no `sep=`/`max_length=`/`suffix_start=` parameters), no dead code, no contrastive "X, not Y" phrasing in the new comments or identifiers.
- Test additions sit in the existing bare-assert style (pre-existing convention in this repo), and expected values are hand-derived rather than recomputed from the implementation.

**Verdict:** not clean — two must-fix items, both cheap: make `MAX_SLUG_LENGTH` an actual maximum on the suffix path, and extend the length test to the suffixed result.
