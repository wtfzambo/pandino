The working diff is documentation-only:

**`docs/release-runbook.md`** — single line changed, adding clarifying rationale ("so relative paths resolve consistently") to a runbook sentence. No executable behavior, no code, no contracts, no test or test-infrastructure change.

No automated test evidence is warranted for this diff. A runbook wording clarification protects no observable product promise that a test could assert, and there is nothing for a regression test to catch.

**Verdict:** clean — no test changes needed.
