## Review: Uncommitted diff test evidence

**Summary:** The diff changes only documentation—a one-line clarification to `docs/release-runbook.md` explaining why the release command should run from the repository root.

**Finding:** No new automated test is needed.

**Rationale:**

Per AGENTS.md § Tests and § Agent workflow, automated test evidence is required for "executable-behavior changes, test or test-infrastructure changes, and bug fixes; skip it for documentation-only and trivial non-behavioral diffs."

This change is **documentation-only**:
- The file is a procedural guide in `docs/`, not executable code
- The change adds explanatory context ("so relative paths resolve consistently") to an existing instruction
- No product behavior, interface, or contract changes
- No test code or infrastructure changes
- No software defect fix

The added rationale is helpful for human operators running the release procedure, but it does not introduce a new observable promise, and the underlying release procedure has not changed. Cheaper tooling (manual adherence to the runbook) already provides the necessary guarantee.

**Good:** ✓ No test bloat, no time spent on non-qualifying evidence.
