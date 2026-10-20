---
name: pandino-handoff
description: Replace the operator's Backlog session pickup snapshot so the next session can resume. Use at the end of a session, before an explicit handoff, or after a substantial implementation is verified.
---

# Session handoff

Context resets between agent sessions. Preserve it with one personal Backlog task per operator named `Session pickup — <name>`: a replaceable current snapshot rather than a diary; Git history and normal Backlog tasks preserve history.

The snapshot is branch-scoped by design. The pickup task is a normal Git-versioned file: each branch carries its own version, and Backlog does not sync task edits across branches (the current working copy always wins). Keep the snapshot on the branch it describes: update it at session end on the branch where the work happened, and let it merge into `main` with that work. For a merge conflict, keep the most recent snapshot or rewrite it post-merge.

Replace the pickup task after a substantial implementation is verified, immediately before an explicit handoff, and as the last project action of the session. Keep it a replacement snapshot rather than an appended log. The replacement snapshot must answer, in this order:

1. `WHERE WE LEFT OFF` — absolute date, branch and commit, push state, clean or dirty tree, completed and partial work, with durable references.
2. `WHAT'S NEXT` — ordered concrete actions, preferably with the exact first command or file.
3. `WAITING ON / GATED BY` — decisions, people, credentials, or external services, with absolute dates.
4. `VERIFY` — commands that prove the snapshot still matches reality.

Write for a reader with zero memory. Record substantial future work as normal Backlog tasks; the pickup task only points to it. Create a missing pickup task through the Backlog CLI with the `continuity` and `handoff` labels, high priority, and the operator as assignee.
