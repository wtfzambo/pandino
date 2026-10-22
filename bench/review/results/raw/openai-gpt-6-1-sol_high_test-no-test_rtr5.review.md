## Verdict
clean

## Findings
### must-fix
none

### minor
none

## Good
- The change only explains the existing repository-root instruction in `docs/release-runbook.md`; it introduces no behavior requiring automated evidence.
- No unnecessary or brittle tests were added.

## Coverage
- Checked: complete working diff and staged diff; only the documentation sentence changed. `git diff --check` passed.
- Unverified: release execution and test suite, unnecessary for this prose-only clarification. The referenced pickup skill file was unavailable; review and testing playbooks were read.
- Turns: 3 of unspecified budget; timed-out commands: none
