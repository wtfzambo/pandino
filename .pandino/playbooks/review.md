# Review

Use this playbook when you launch, brief, or act as a reviewer, and when you handle review findings. Reviewers give independent evidence; the orchestrator keeps the judgment of what was discussed and rejected, and the plan's author defends it by default.

Treat the steps as a checklist. When you skip a step, say why in one line of your reply.

## Steps

1. **Choose the reviewers.** For substantial changes, run the relevant reviewers once near the end of a logical slice:
   - `taste-reviewer` and `spec-reviewer` when implementation or scope benefits from independent review;
   - `test-reviewer` when substantial behavior, tests, test infrastructure, or a shipping-code bug fix warrants evidence review;
   - `docs-reviewer` when substantial documented behavior or authority changes;
   - `final-reviewer` when branch composition or end-to-end risk could change the merge decision.

   Run docs before final when both apply, and preserve each reviewer's separate role.
2. **Brief the reviewer** with the template below. The reviewer chooses its checks and judges independently.
3. **Set the budget.** Allow 20 turns for ordinary reviews, 40 for final review, and 8 for corrections. Apply limits to reviewers; preserve project-wide defaults and implementer settings. Lower budgets freely. For an increase, ask the user with a decision-changing question and the extra turns requested.
4. **Adjudicate the findings.** Treat findings as evidence and keep research, deliverables, and maintenance artifacts within the agreed scope. Fix valid, in-scope, proportionate findings. Give incorrect, duplicate, out-of-scope, or disproportionate findings a checkable reason tied to shipped behavior, contracts, repository risk, or proportionate evidence. Ask the user only for a remaining product, scope, or risk choice. Give every must-fix an explicit disposition, and obtain user acceptance before merging with a valid unresolved must-fix. Keep report-only audits report-only until the user requests implementation.
5. **Review corrections locally.** Identify what changed, which findings or evidence it affects, and which reviewer is needed. Check the fix and its consequences. Reopen settled or rejected findings only with new evidence or invalidated earlier evidence. Run one full final review; justify a repeat by a substantive change that invalidates it, within the approved budget.

## Brief template

```
Revision: <commit range, branch against its merge base, or working diff>
Scope for this role: <what to judge and what belongs to other reviewers>
Task and specification: <IDs and paths>
Existing evidence: <checks already run and their results>
Settled findings: <findings already adjudicated, with their disposition>
Open questions: <what the orchestrator wants answered>
Budget: <turns>
```

## While reviewing

- **Keep investigation focused.** Explore beyond changed interactions, including dependencies and unchanged code, only for a concrete bug hypothesis. State the question and stopping point. Report unexpected defects. The orchestrator skips redundant launches and redirects or stops redundant work.
- **Switch blocked checks.** After an environmental failure, allow one retry backed by a diagnosis. Then use a narrower or manual check, explain its limits, and preserve required regression coverage.
- **Conclude.** Finish when the review questions have evidence-backed answers or the budget is spent. Reserve time to report. State the verdict, evidence, proven defects, plausible risks, and unverified areas; distinguish certainty from severity. At the limit, mark the verdict provisional and get approval before continuing. Mark truncated reviews incomplete. Withhold approval when essential evidence is missing.

## Fallback runner

`fallback-runner` is an inspection-only escape hatch for a reviewer that cannot launch or complete because its provider, quota, session, or pinned model is unavailable. Use it only for those availability failures; findings you disagree with or a disappointing result are outside its purpose. Invocation requires an explicit alternate model (omitting one silently inherits the parent), the failed reviewer's canonical instructions verbatim, its playbooks, and the concrete task context. Preserve the review role and tool boundaries. For review work, choose a model different from the writer, and visibly report every substitution.

## Pi enforcement

The runner counts completed turns, warns at the limit, and aborts after its grace allowance (five turns by default). Workflows inherit reviewer frontmatter limits. Use direct `Agent(max_turns: 8, ...)` calls for corrections and explicit role-specific limits for fallback reviewers. Elapsed time, tool calls, tokens, and cost remain unbounded by this setting. Budget-increase approval depends on the orchestrator following these instructions. Other harnesses receive the budget as an instruction.
