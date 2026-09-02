Confirmed: the test passes, but the `taken` path overflows the length bound using the test's own fixture (base 59 chars → `base-2` is 61).

## Must-fix

**`slug.py:14`** — The `-N` suffix is appended after truncation, so a taken base that fills `MAX_SLUG_LENGTH` (or 59 after `rstrip("-")`, as with the test's own `long_title`) yields a slug of 61+ chars. That contradicts what `MAX_SLUG_LENGTH` is for, what its comment promises, and what the new test asserts (`len(...) <= 60` — which only covers the untaken path, so the defect ships green). Fix by reserving room for the suffix when truncating the base (e.g. truncate to `MAX_SLUG_LENGTH - len(f"-{n}")` inside the loop, or reserve a fixed suffix budget), and add a test for `unique_slug(long_title, {base})` — the exact path that overflows today.

## Minor

- **`test_slug.py:16`** — the missing test case above is the only gap; otherwise the new assertions are independent, hand-derived values and match the file's existing bare-`assert` style. Nothing else worth changing here.

## Good

- `unique_slug` is the boring, named version of the idea: separate `slugify` base step, early return for the happy path, a plain `n` loop. No cleverness.
- The `rstrip("-")` correctly handles truncation cutting at a hyphen boundary (true for `"word " * 30`), and needs no comment — it's structural.
- The `MAX_SLUG_LENGTH` comment states intent (shared-link readability), not mechanics.
- Module layout follows AGENTS.md: constant, then public functions in workflow order, caller before callee.

Cleanup of the one overflow makes this diff done.
