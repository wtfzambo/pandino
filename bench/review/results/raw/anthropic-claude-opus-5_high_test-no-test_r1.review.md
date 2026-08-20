## Scope of the diff

The entire working tree change is one line in a runbook:

`docs/release-runbook.md:3`
```diff
-Run the release command from the repository root.
+Run the release command from the repository root so relative paths resolve consistently.
```

The repository contains exactly two files (`AGENTS.md`, `docs/release-runbook.md`) — no source code, no test suite, no test infrastructure, and nothing staged or untracked beyond this edit.

## Findings

**Must-fix: none.**

**Minor excess: none.**

**No new test is warranted.** This is a documentation-only change that adds a rationale clause to a human-run procedure. It changes no executable behavior, no public contract, and no test infrastructure, so there is no observable promise for a test to protect and no plausible defect a test could fail under. Under AGENTS.md's own workflow rule — `test-reviewer` is skipped for "documentation-only and trivial non-behavioral diffs" — this diff would not normally have reached me at all.

Two things I explicitly did **not** turn into findings, since manufacturing them would be exactly the coverage-quota behavior the standard rejects:

- Asserting on runbook wording (e.g., a test grepping for "repository root") would be a brittle wording assertion protecting no product promise. If the concern is that the runbook drifts from the real release command, the honest guarantee is the release script itself failing loudly outside the repo root — not a doc-string test.
- The added clause makes a factual claim ("relative paths resolve consistently") about a release command that does not exist anywhere in this repository. Whether that claim is *true* is `spec-reviewer`'s call, not mine; I flag it only so it isn't assumed verified. There is no in-repo boundary to write an independent test against.

## Good

- The change is proportionate and self-contained: it explains *why* the constraint exists rather than restating the instruction, which matches the AGENTS.md guidance that comments and docs carry intent and constraints.
- No speculative test scaffolding, fixtures, or harness config were added alongside a docs edit — the diff stays the size of the change.
