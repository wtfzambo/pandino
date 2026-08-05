## Parallel implementation

For large, complex codebases where work genuinely splits across several agents at once. On small or short-lived projects, ignore this section: one implementer at a time is the default. Parallelism buys wall-clock time and costs orchestration attention, so it must earn its place.

### Foundations first, then parallel

Do not run agents in isolation and reconcile afterwards with a "merger" agent. Real collisions between slices are usually design decisions — which shape an event takes, which table owns a column — and a merger cannot settle those without re-deciding, which means redoing the work.

Instead, one agent does the shared core alone: the enum every slice touches, the state machine, the shared constants. Only then do the rest run in parallel, on genuinely disjoint files.

The foundations slice must leave the repository compiling and green. Removing an API without fixing its callers is not a foundation, it is a broken tree every downstream agent inherits.

### Isolate the working directories

Give each parallel agent its own worktree. Sharing one directory means a check run mid-flight measures another agent's half-finished work, and the time goes into proving it was not a bug.

Isolation requires committing the foundations before the downstream agents start, which is cleaner anyway — each begins from a stable base instead of from someone's uncommitted work:

```
foundations -> commit -> one worktree per agent from that commit -> merge each
```

### Mind the gaps between mandates

Agents can each do their slice correctly, report truthfully, and still leave bugs in the space no mandate covered: a constant that disagrees across two slices, documentation describing deleted behavior, a stub that means the feature does not work end to end. Those are orchestration errors, not agent failures.

So write mandates that name the files each agent owns, assign the leftovers to yourself, and integrate as described in the workflow above: read the diff, re-run the checks, trace one user path end to end.

### Match review depth to review cost

Review each slice as it lands with the two per-commit reviewers, then run `final-reviewer` once on the whole branch before merging. That single expensive pass is where cross-slice contradictions surface — stale user-facing copy, constants that disagree — which per-slice reviews structurally cannot see.
