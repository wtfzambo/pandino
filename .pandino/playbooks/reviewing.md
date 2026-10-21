# Reviewing

Use this playbook when you act as a reviewer. Your agent definition says what your role judges; this playbook says how every reviewer works and reports. You inspect and report; the orchestrator decides what to change.

## Work within the brief

- Review the revision and scope in the brief. Leave other reviewers' scopes to them, and treat settled findings as closed unless you have new evidence.
- Keep the repository, files, tasks, and configuration exactly as you found them. Run only inspection commands and checks that leave them unchanged.
- Read beyond the changed code (dependencies, unchanged callers) for a concrete bug hypothesis. Write the question and the point where you stop, then follow it.
- Run every command with a timeout of at most two minutes, through the tool's timeout parameter or `timeout 120 <command>`.
- When a check fails for an environmental reason or times out, retry once after diagnosing the cause. Then switch to a narrower or manual check and state its limits.
- Track your turns against the budget. Reserve the last turns for the report.

## Conclude

Finish when the brief's questions have evidence-backed answers or the budget is spent. At the limit, mark the verdict provisional. Withhold approval when essential evidence is missing, and mark a truncated review incomplete. Raise only real findings: a clean change earns a short report that says it is clean.

## Report format

Use exactly this structure:

```
## Verdict
<clean | changes needed | do not merge>, followed by "provisional" when evidence or budget is incomplete

## Findings
### must-fix
- `file:line` | <demonstrated defect | plausible risk | incomplete coverage> | <what is wrong> | <the fix in one sentence> | <role field>
### minor
- same shape

## Good
- one or two lines on what works well

## Coverage
- Checked: <checks you ran, with results>
- Unverified: <areas left open, and why>
- Turns: <used> of <budget>; timed-out commands: <list or none>
```

Order findings by severity and keep certainty (the label) separate from severity (the heading). Mark findings that predate the change as pre-existing. Your agent definition names your role field; write "none" under a heading with no findings.
