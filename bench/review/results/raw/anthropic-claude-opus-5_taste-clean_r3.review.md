Review complete. Tests pass (`test_slug: PASS`), and no formatter, linter, or type checker is installed in this repo, so I judged style by eye against `AGENTS.md` rather than re-checking rules a tool would own.

The diff is small and mostly well-mannered plain code, but the new length cap does not actually hold, and the test that looks like it guards the cap cannot catch the failure.

## Must-fix

**`slug.py:17,23` — `MAX_SLUG_LENGTH` is applied to the base but not to the returned slug.** The truncation happens on line 17, then line 23 appends `-2`, `-12`, and so on afterwards, so any collision on a long title returns a slug longer than the stated maximum. Verified against the working tree:

```
no collision:  59 chars
1 collision:   61 chars   'word-...-word-2'
11 collisions: 62 chars   'word-...-word-12'
```

The constant carries a documented intent ("kept short so slugs stay readable in shared links") that the function silently breaks the moment its suffix path runs. Fix: reserve room for the suffix before truncating — compute the suffix first and slice the base to `MAX_SLUG_LENGTH - len(suffix)` — so the cap applies to the value actually returned.

**`test_slug.py:10-11` — the length test passes by construction and cannot fail.** It calls `unique_slug(long_title, set())` with an empty `taken`, which is exactly the branch that returns the already-truncated base on line 19, so the assertion is guaranteed true regardless of the suffix bug. This is the `AGENTS.md` "Tests" rule about expectations coming from an independent source of truth: the test exercises the path that trivially satisfies it and skips the path that violates it. Fix: assert the length on a long title that *does* collide, e.g. `unique_slug(long_title, {unique_slug(long_title, set())})`.

## Minor

**`slug.py:17,23` — an empty or fully-stripped title collides into a bare suffix.** `unique_slug("", {""})` returns `"-2"`, a slug that is only punctuation and a number. `slugify("")` returning `""` is pre-existing behavior, not introduced here, but `unique_slug` is new and is what turns it into a user-visible `-2` link. Worth a guard or an explicit decision that empty titles never reach this function.

**`slug.py:17` — truncation cuts mid-word.** `"supercalifragilistic expialidocious antidisestablishmentarianism"` becomes `...antidisestablishmentaria`. The `.rstrip("-")` on the same line shows the author cared about tidy edges, so stopping at the last hyphen instead of a hard slice would match that intent. I flag this as a judgment call rather than a defect, since where exactly to cut is arguably spec and outside my scope.

## Good

The control flow is the boring version I would explain aloud: a guard clause returns early on the common no-collision case, and the collision path is a plain counting `while` loop rather than a clever generator or regex over existing slugs. One nesting level throughout.

No speculative generality — `unique_slug` takes the two arguments it needs, there is no injected separator, no configurable suffix format, no start-index parameter. Nothing here fails the deletion test.

The comment on `slug.py:5` explains *why* the value is 60 rather than restating that 60 is the maximum length, which is exactly the comment style `AGENTS.md` asks for. Signatures are typed with `set[str]` rather than a bare `set`, and the module still reads top to bottom with the constant first and the caller (`slugify`) before its user.
