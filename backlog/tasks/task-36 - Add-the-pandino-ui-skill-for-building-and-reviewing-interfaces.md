---
id: TASK-36
title: Add the plain-ui skill for building and reviewing interfaces
status: Done
assignee: []
created_date: '2026-11-27 00:38'
updated_date: '2026-11-27 09:45'
labels:
  - skills
dependencies: []
priority: medium
ordinal: 43000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Agents default to generic AI-looking interfaces: decorative gradients, nested cards, invented metrics. Pandino has rules for plain code and none for plain interfaces. The operator asked for a skill that installs with the others, loads only for UI work, and pushes toward subtractive design. Some modes and anti-patterns are distilled from Impeccable by Paul Bakaus (Apache 2.0), rewritten, with no dependency on it. Operator decisions on 2026: the skill is listed in the AGENTS.md playbook index so reviewers find it; product and design context lives in a root DESIGN.md.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 pandino-ui ships as .agents/skills/pandino-ui/ with SKILL.md of at most about 150 lines plus references/anti-patterns.md and references/web.md
- [x] #2 install.sh installs pandino-ui wherever it installs the other Pandino skills, and tests/test_install.sh passes
- [x] #3 AGENTS.md playbook index and README name the skill and when it applies
- [x] #4 The review procedure, applied once to a small sample UI, produces concrete P0-P3 findings
- [x] #5 No sentence is copied from Impeccable; Sources credits it in one line
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Write SKILL.md and the two references. 2. Run tests/test_install.sh and see it fail on the skills diff. 3. Add pandino-ui to install_session_skills and the recap lines in install.sh; test passes. 4. Add the index line to AGENTS.md and update README. 5. Verify install per editor, apply the review procedure to a sample page, run docs-reviewer. 6. Delete the Impeccable clone.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Verification. tests/test_install.sh failed on the skills diff before the install.sh change and passes after. A fresh ./install.sh --yes copied pandino-ui to .agents/skills and .claude/skills, identical to the source. Loading: pi (in this repo) and Codex (in the fresh install) each quoted the frontmatter description from context and reported the skill body absent. pi listed no project skills in the untrusted temp install, the same as for the other four Pandino skills. Claude Code was not probed live (OAuth session expired on this machine) and opencode is not installed; both rest on their documentation. A stand-in taste-reviewer in the fresh install reached the skill and both references through the AGENTS.md index line alone and used them in its report. A fresh agent ran critique on a 53-line sample signup page and returned 17 findings with lines and fixes, 2 of them P0. A 6-word overlap check against Impeccable's skill files and detector rule list leaves only the Saint-Exupery quotation. The Impeccable clone and the temp install are deleted.

Review. docs-reviewer stand-in (general-purpose agent on the orchestrator's model, since this session exposes no pinned specialists): 7 of 20 turns, 5 minutes, no timed-out commands. Fixed: the P0/P1 to must-fix mapping now defers to reviewing.md; description says UI code, UI copy, or visual design; section renamed The central rule; one states list in step 4 that harden and the review refer to; MUST/SHOULD/NEVER defined; focus-ring wording. Rejected with reason: deleting the Saint-Exupery and Rams line, the keep/remove lists that overlap anti-patterns.md, and the capitalized rule format are explicit operator requirements; renaming install_session_skills is pre-existing and outside this change. Critique-agent feedback fixed: the rules and web.md now belong to review pass 5, reviews change no file, a touch web target is 44 px, findings sharing a fix are merged. Taste-reviewer stand-in: 6 of 20 turns, 2 minutes. No correction check was run on the wording fixes: they are the reviewer's own one-sentence replacements. Open for the operator: whether to record a decision for the DESIGN.md and index choices, and whether to keep the optional npx impeccable detect line.

After operator review on 2026-11-27: removed the optional npx impeccable detect line, so Impeccable appears only in Sources; recorded decision-14. Ran a comparison: six models (claude-fable-5-2, claude-opus-5-5, claude-sonnet-5-5, gpt-6.2-astra, gpt-6.2-sol, gpt-6.1-terra) at medium thinking each built the same phone landing page twice in fresh pi sessions, once with no skills and once with only pandino-ui available. All six skill runs opened SKILL.md and both references unprompted. Pages and 390 px screenshots are in /tmp/pui-ab (temporary). tests/test_install.sh passes after the edit.

Second comparison, 2026-11-27, on a product screen: a fictional clinical note editor modelled on the feature list of a real one, same six models, medium thinking, fresh sessions. All six skill runs opened the skill and both references. Effect is smaller than on the landing page: uppercase kickers, numbered section labels and emoji icons go away, and four of six state next to the sign button what still blocks signing; count of controls under 24 px at phone width did not improve (Terra 11 to 20), and page length is unchanged. Added a section to SKILL.md that separates product screens from marketing pages (145 lines); tests/test_install.sh passes.

Third check, 2026-11-27: one fresh agent ran critique, read-only, on a real large product screen (a clinical note editor in another repository, about 4,500 lines of markup and 44 sidebar controls). It returned 15 findings (7 P1, 6 P2, 2 P3) with file and line; six spot-checked against the code and confirmed. Skill gaps it reported: the eraser pass needs a chosen role and state on a state-dependent screen; no guidance when a project rule forbids the natural fix; severity ignores irreversible mistakes; many rules cannot be checked from code on a component-library screen; anti-patterns.md is mostly marketing-page aesthetics; the reference conditions give no gating in critique. Not yet acted on; waiting for the operator.

Applied on the operator's approval, 2026-11-27: a blocked primary action says beside it what is missing; a review reads the product rules first and names the role and state it covers; a mistake the user cannot undo is at least P1. SKILL.md is 145 lines; tests/test_install.sh and the Python unit tests pass.

Renamed on the operator's request, 2026-11-27: the skill is now plain-ui, without the pandino- prefix, because it works alone when its folder is copied elsewhere; its one mention of Pandino is conditional. The description now names the five modes, and the skill lists them when invoked without a request. A first wording of that description contained a colon followed by a space, which is invalid unquoted YAML: pi dropped the skill silently and six comparison runs went ahead without it. tests/test_install.sh now fails on such a description. Fourth comparison: six models rebuilt the real note editor as a static mockup from the critique, once with the critique alone (the runs where the skill failed to load) and once with the skill loaded. Both variants applied the P1 fixes; the skill added little on top of a critique that already existed.

Closed 2026-11-27: pushed to origin/main on the operator's request. The operator liked parts of the critique-plus-skill mockups and may revisit the skill later.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added the pandino-ui skill (SKILL.md, 140 lines, plus references/anti-patterns.md and references/web.md), installed by install.sh with the other skills, listed in the AGENTS.md playbook index and the README. Verified with tests/test_install.sh, a fresh --yes install, context probes on pi and Codex, a reviewer run that found the skill through the index, and one critique of a sample page. Not committed.
<!-- SECTION:FINAL_SUMMARY:END -->
