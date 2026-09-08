## Session continuity

Context resets between agent sessions. Preserve it with one personal Backlog task per operator named `Session pickup — <name>`: a replaceable current snapshot rather than a diary; Git history and normal Backlog tasks preserve history.

The snapshot is branch-scoped by design. The pickup task is a normal Git-versioned file: each branch carries its own version, and Backlog does not sync task edits across branches (the current working copy always wins). Keep the snapshot on the branch it describes: update it at session end on the branch where the work happened, and let it merge into `main` with that work. For a merge conflict, keep the most recent snapshot or rewrite it post-merge. To read another branch's snapshot without switching, use `git show <branch>:"backlog/tasks/task-1 - Session-pickup-—-<name>.md"`; Backlog's browser resolves same-ID variants to one task and cannot select another branch's version while a working-copy version exists.

At the start or resumption of project work:

1. Run `backlog instructions overview`.
2. Find the operator's task with `backlog search "Session pickup" --plain` and read it with `backlog task view <ID> --plain`.
3. Follow the durable file and task references in the snapshot rather than duplicated context.
4. Verify reality with `git status -sb`, `git log --oneline -5`, the referenced Backlog tasks, and any checks named in the snapshot. When reality differs, trust the repository and tools.
5. Continue from the first actionable item under `WHAT'S NEXT`.

Replace the pickup task exactly once as the last project action of the session or immediately before an explicit handoff. Keep it a replacement snapshot rather than an appended log. The replacement snapshot must answer, in this order:

1. `WHERE WE LEFT OFF` — absolute date, branch and commit, push state, clean or dirty tree, completed and partial work, with durable references.
2. `WHAT'S NEXT` — ordered concrete actions, preferably with the exact first command or file.
3. `WAITING ON / GATED BY` — decisions, people, credentials, or external services, with absolute dates.
4. `VERIFY` — commands that prove the snapshot still matches reality.

Write for a reader with zero memory. Record substantial future work as normal Backlog tasks; the pickup task only points to it. Create a missing pickup task through the Backlog CLI with the `continuity` and `handoff` labels, high priority, and the operator as assignee.
