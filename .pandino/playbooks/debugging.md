# Debugging

Use this playbook when you fix a bug, or a failure whose cause is unknown.

1. **Reproduce it.** Find the smallest observable reproduction on the surface where the bug was reported: a command, a request, a test, or a UI step. Record the expected and the actual behavior.
2. **Write the regression test first.** For a reproducible bug in shipping code, turn the reproduction into a focused test at the closest stable boundary and run it. It must fail for the reported reason; if it passes or fails for another reason, fix the test before touching the code. When the only test path is expensive, use the closest repeatable check (a script, a probe, a logged assertion) and say why. Follow `.pandino/playbooks/testing.md`.
3. **Trace to the cause.** Follow the wrong value back to the first place the system went wrong. Read the real code path and the relevant external API; label every step you infer instead of observe.
4. **Fix the cause.** Make the smallest change that corrects the first wrong step. A guard, retry, default, or special case is a fix only when the state it handles is legitimate; a guard that hides an illegitimate state moves the bug elsewhere. When the real cause is outside the current work, report it to the user.
5. **Test the premise after two failed fixes.** When two fixes based on the same assumption have failed the same check, stop fixing. Write the assumption down and test it directly before the next attempt.
6. **Confirm.** Rerun the regression test and the original reproduction. Both must now pass, and the surrounding checks must stay green.
