---
id: TASK-35
title: Make review-lens steps readable on their own and add file search
status: Done
assignee:
  - '@zambo'
created_date: '2026-11-24 14:32'
updated_date: '2026-11-25 13:38'
labels: []
dependencies: []
priority: medium
ordinal: 42000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Feedback from the PR 366 walkthrough (LumaMDX), step 2: the step relied on context the reader had not seen, hid the difference between an unconfirmed and a failed signature, and translated canonical terms such as Held amendment so their definition was unreachable. Also add a VS Code-like file search and show only new terms on the overview.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 SKILL.md: paragraph 1 states the starting point without relying on earlier steps
- [ ] #2 SKILL.md: rule for states that look alike (what happens, what the user sees)
- [ ] #3 SKILL.md: prose uses canonical glossary names in code; definitions may be translated
- [ ] #4 SKILL.md: file notes follow the same self-contained and term rules
- [ ] #5 SKILL.md: links Pandino writing playbook, local or online
- [ ] #6 render.py warns when a glossary term appears as plain text and never in code
- [ ] #7 template.html: Cmd/Ctrl+E file search with button, fuzzy on path, opens the file page
- [ ] #8 Overview shows only new glossary terms
- [ ] #9 PR 366 guide rerendered with rewritten step 2 and its notes
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Verified on /tmp/review-366.tm549z: unittest passes; Cmd+E search checked in Chrome (nsrs -> NoteSignatureReviewService.cs, Enter opens step 2); step 2 glossary codes hover. Puppeteer not installed, so ViewerTest skips; search has no automated test.

Also: writing.md reordered so sentence rules and the final check apply to every text, with the AGENTS.md trigger and README row widened to match; exported AI-question prompt links writing.md; review-lens README with dark-mode screenshots from a made-up PR in imgs/review-lens/ (loaded by raw GitHub URL, so they appear after push). Validation: python3 -B -m unittest tests.test_review_lens OK (browser test skipped, no puppeteer); bash tests/test_install.sh PASS.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
review-lens steps and file notes now start from a self-contained point, explain look-alike states, and write canonical glossary names in code; render.py warns on glossary terms left as plain text; the viewer gains Cmd/Ctrl+E file search and shows only new terms on the overview. writing.md now applies to any text. Verified with unit tests, the installer test, and a manual Chrome check on the rerendered PR 366 guide.
<!-- SECTION:FINAL_SUMMARY:END -->
