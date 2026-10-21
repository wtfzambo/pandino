## Verdict

Small, readable diff; the tests pass (`python3 test_slug.py` → PASS). Two real issues: one behavior hole on empty input, one duplicated length rule. No linter/type-checker/ruff config exists in this repo, so style is judged by eye only.

### Must-fix

1. **`slug.py:17-22`** — when `slugify` yields nothing, the suffix is appended to an empty base, producing a slug that starts with a hyphen: `unique_slug("", {""})` → `"-2"`, `unique_slug("!!!", {"", "-2"})` → `"-3"`. That violates the module's own contract in `slugify`'s docstring ("alphanumeric words joined by single hyphens") and `slugify("") == ""` is an accepted input, so this path is reachable. *Demonstrated defect.* Fix: decide the empty-title case explicitly (return `""` unchanged, or a fixed fallback word) before the suffix loop, instead of suffixing an empty base — flag it as a product choice if the answer isn't obvious.

### Minor

2. **`slug.py:17` and `slug.py:21`** — the truncation rule is written twice with two different bounds (`base[:MAX_SLUG_LENGTH]` and `base[: MAX_SLUG_LENGTH - len(suffix)]`), so a reader must diff two expressions to confirm the length limit holds. *Plausible risk of divergence.* Fix: fold the first candidate into the loop so one expression owns the rule:
   ```python
   attempt = 1
   while True:
       suffix = "" if attempt == 1 else f"-{attempt}"
       candidate = base[: MAX_SLUG_LENGTH - len(suffix)].rstrip("-") + suffix
       if candidate not in taken:
           return candidate
       attempt += 1
   ```

3. **`test_slug.py:32-33`** — the long-title assertions check only `len(...) <= MAX_SLUG_LENGTH`, never the value, so a defect that drops the suffix (returning `long_slug` again, colliding in `taken`) passes. *Incomplete coverage.* Fix: assert the exact expected string, e.g. `assert unique_slug(long_title, {long_slug}) == long_slug[:-2] + "-2"`. Also give the second result a name instead of nesting the call inside `len(...)` at line 33.

4. **`slug.py:17`** — `rstrip("-")` shows intent to avoid a broken edge, but truncation still cuts mid-word in the suffixed case (`"word " * 30` → `…-wor-2`). *Plausible risk / product question, not a defect:* either accept mid-word cuts and drop the implication, or truncate at the last hyphen.

### Good

- `MAX_SLUG_LENGTH` is a named constant sitting next to the behavior it governs, and the public function reads top-down with the happy path visible.
- `taken: set[str]` is typed at the boundary; no defensive layers around impossible states.
- Tests reuse the existing flat bare-assert style and reuse `slugify` indirectly, so they don't re-implement the slug rule.
