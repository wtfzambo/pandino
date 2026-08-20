The working diff is a single documentation-only change: one sentence in `docs/release-runbook.md` gains a rationale clause ("so relative paths resolve consistently"). There are no code, test, or test-infrastructure changes, no staged or untracked files.

## Findings

**Must-fix:** none.

**Minor excess:** none.

**Good:** no automated test evidence is warranted. The change alters no observable product behavior — it only clarifies a human-run procedure. Per the review scope, documentation-only changes normally need no new or changed tests, and there is no promise here whose breakage would be a bug that a test could catch. Nothing to add or remove.
