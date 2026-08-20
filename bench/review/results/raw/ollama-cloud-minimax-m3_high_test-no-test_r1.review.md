## No new test warranted

The working diff contains a single change in `docs/release-runbook.md`:

```diff
-Run the release command from the repository root.
+Run the release command from the repository root so relative paths resolve consistently.
```

This is a documentation-only clarification — no executable behavior, no public contract, no test infrastructure, no bug fix. Per the review scope ("skip it for documentation-only and trivial non-behavioral diffs"), no automated evidence is warranted here.

- A test asserting "the release command works when run from the repo root" would either duplicate an existing release script's own integration coverage or test trivial shell context that is not the documented promise.
- The added clause ("so relative paths resolve consistently") explains a *why*, not a contract the user can observe independently of running the command — and the underlying guarantee, if real, would be protected at the release-script boundary, not by a runbook test.

Good: this is exactly the kind of small prose tweak that should not drag in test scaffolding.
