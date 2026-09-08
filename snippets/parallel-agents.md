## Parallel implementation

Use this section for large, complex codebases where work genuinely splits across several agents at once. Give small or short-lived projects one implementer at a time. Parallelism earns its orchestration cost by reducing meaningful wall-clock time.

### Foundations first, then parallel

Establish shared foundations before parallel slices: one agent owns the enum every slice touches, the state machine, and shared constants. Then assign the remaining agents genuinely disjoint files.

The foundations slice leaves the repository compiling and green. Keep callers working when changing an API so each downstream agent starts from a runnable tree.

### Isolate the working directories

Give each parallel agent its own worktree. This keeps a mid-flight check focused on that agent's work rather than another agent's half-finished changes.

Commit the foundations before downstream agents start so each begins from a stable base:

```
foundations -> commit -> one worktree per agent from that commit -> merge each
```

### Mind the gaps between mandates

Agents can each complete their slice and still leave bugs in work no mandate covered: a constant that disagrees across two slices, documentation describing deleted behavior, or a stub that prevents the feature from working end to end. The orchestrator owns these integration gaps.

Write mandates that name each agent's files, assign the leftovers to yourself, and integrate through the workflow above: read the diff, run checks matched to each artifact's purpose, and trace one user path end to end.

### Match review depth to review cost

For substantial slices, run the relevant reviewers when their independent evidence helps: taste and spec for implementation or scope, and test for relevant behavior or evidence changes. Run `final-reviewer` when whole-branch composition or end-to-end value could change the merge decision. That deep pass surfaces cross-slice contradictions such as stale user-facing copy or disagreeing constants that per-slice reviews cannot see.
