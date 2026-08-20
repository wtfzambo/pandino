The entire working diff is one documentation sentence:

- `docs/release-runbook.md:2` — rewording of a procedural note ("Run the release command from the repository root" → "...so relative paths resolve consistently").

This is documentation-only with no executable behavior, bug fix, test change, or test-infrastructure change. It states a procedure (run from repo root), and the added clause merely explains the reason — the instruction itself is unchanged. Even the pre-existing instruction wasn't previously guarded by a test, and it isn't the kind of thing a test could meaningfully protect (a human-run procedure whose correctness is about path resolution).

No new or changed automated evidence is warranted. No findings — the diff is clean from a test-evidence standpoint, and nothing in it should have a test added.
