# Review

Use this playbook when you launch or brief reviewers and when you handle their findings. Reviewers inspect and report; you, the orchestrator, judge what to act on, and the plan's author defends the plan by default. Reviewers follow `.pandino/playbooks/reviewing.md`.

Treat the steps as a checklist. When you skip a step, say why in one line of your reply.

## Steps

1. **Choose the reviewers.** For substantial changes, run the relevant reviewers once near the end of a logical slice:
   - `taste-reviewer` and `spec-reviewer` when implementation or scope benefits from independent review;
   - `test-reviewer` when substantial behavior, tests, test infrastructure, or a shipping-code bug fix warrants evidence review;
   - `docs-reviewer` when substantial documented behavior or authority changes;
   - `final-reviewer` when the change as a whole (a branch against its base, or a range of commits on `main`) could fail end to end or change the decision to keep it.

   Run docs before final when both apply, and keep each reviewer to its role.
2. **Brief each reviewer** with the template below. The reviewer chooses its checks and judges independently.
3. **Set the budget**: 20 turns for ordinary reviews, 40 for final review, 8 for a correction check. Lower budgets freely. For an increase, ask the user with a decision-changing question and the extra turns requested.
4. **Decide each finding.** Fix valid, in-scope, proportionate findings yourself or through the `implementer`. Reject a finding that is wrong, duplicated, out of scope, or disproportionate with a reason someone else can check against the code, the contract, or the evidence (for example "rejected: needs input above 65,535, which `parse.py:40` rejects"). Ask the user only for a remaining product, scope, or risk choice. Give every must-fix an explicit outcome, and get the user's acceptance before keeping the change with a valid must-fix unresolved. Keep report-only audits report-only until the user asks for changes.
5. **Check corrections locally.** After fixing findings, identify what changed and which findings or evidence it affects, and send only that delta to the reviewer it concerns, with the 8-turn budget. Reopen settled or rejected findings only with new evidence. Run one full final review; repeat it only after a substantive change that invalidates it.
6. **Record the cost.** Append each review's `Turns` line, its wall-clock minutes, and any timed-out commands to the task notes. These numbers let the user decide whether budgets or reviewers need to change; Pandino sets no baseline.

## Brief template

```
Revision: <branch against its merge base, commit range on main, or working diff>
Scope for this role: <what to judge; what belongs to other reviewers>
Task and specification: <IDs and paths>
Existing evidence: <checks already run and their results>
Settled findings: <findings already decided, with their outcome>
Open questions: <what you want answered>
Budget: <turns>
```

## When a reviewer cannot run

Use `fallback-runner` only when a reviewer cannot launch or complete because its provider, quota, session, or pinned model is unavailable. Give it an explicit alternate model (omitting one silently inherits yours), the failed reviewer's agent definition verbatim, this repository's `.pandino/playbooks/reviewing.md`, and the brief. Choose a model different from the writer's, and report every substitution to the user.

## Limits

Turn budgets and the timeouts in `reviewing.md` are experimental. A turn limit stops a reviewer that keeps taking turns; it leaves a long single command or an unproductive line of inquiry unbounded. How each editor enforces the limit is described in the specialist routing and bounded review specifications.
