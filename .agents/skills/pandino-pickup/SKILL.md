---
name: pandino-pickup
description: Resume project work from the operator's Backlog session pickup snapshot. Use at the start or resumption of work in a Pandino repository, or when the user asks where things stand.
---

# Session pickup

Context resets between agent sessions. Preserve it with one personal Backlog task per operator named `Session pickup — <name>`: a replaceable current snapshot rather than a diary; Git history and normal Backlog tasks preserve history.

At the start or resumption of project work:

1. Run `backlog instructions overview`.
2. Find the operator's task with `backlog search "Session pickup" --plain` and read it with `backlog task view <ID> --plain`.
3. Follow the durable file and task references in the snapshot rather than duplicated context.
4. Verify reality with `git status -sb`, `git log --oneline -5`, the referenced Backlog tasks, and any checks named in the snapshot. When reality differs, trust the repository and tools.
5. Continue from the first actionable item under `WHAT'S NEXT`.

To read another branch's snapshot without switching, use `git show <branch>:"backlog/tasks/task-1 - Session-pickup-—-<name>.md"`; Backlog's browser resolves same-ID variants to one task and cannot select another branch's version while a working-copy version exists.

When the session ends or work is handed over, replace the snapshot with the skill `pandino-handoff`.
