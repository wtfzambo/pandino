---
id: TASK-33
title: >-
  Ship review-lens: a skill that turns a PR into a guided HTML walkthrough for
  the human reviewer
status: Done
assignee:
  - '@agent'
created_date: '2026-11-20 16:47'
updated_date: '2026-11-23 16:32'
labels: []
dependencies: []
priority: medium
type: enhancement
ordinal: 40000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The operator reviews PRs in codebases and languages they don't know (C#, a newly joined project) and scrolling the diff in repo order does not build understanding. A prototype viewer built on PR 350 of LumaMDX (Azure DevOps) proved the shape: steps ordered by importance, per-file priority and context note, glossary, comments for the PR and questions for an AI, minimal UI, many themes. The review exists only to help the human understand; it verifies nothing. The skill must be self-contained so it can be copied outside Pandino, and may spawn subagents for large PRs by itself. Prototype: /tmp/review-lens (template.html, render.py, vendor/), sample run in /tmp/pr350.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A self-contained skill folder holds SKILL.md, a prepare script, the renderer, the template and vendored assets with their licenses, and references nothing outside itself
- [x] #2 The prepare script records only facts every git repository provides (per-file diff, status, line counts, touching commits) plus standard generated-file markers as hints, never path- or project-specific rules
- [x] #3 The renderer rejects a review that misses, duplicates or invents a file, anchors a finding outside its step, or leaves a file without a note
- [x] #4 Regenerating PR 350 from scratch through the skill produces a page that opens without console errors
- [x] #5 The skill ships inside the Pandino kit and the installer copies it next to the session skills
- [x] #6 One agent writes review.json directly from the prepared change, using ordered priority rules and no mandatory per-file investigation.
- [x] #7 The normal run needs no delegation or intermediate AI artifacts.
- [x] #8 The page opens on an overview: what the change is for, its architecture, the steps, and the glossary; step text stays short and the renderer enforces word limits.
- [x] #9 Priority filters show every file when none is selected and only the selected levels otherwise.
- [x] #10 A per-repository glossary persists on the user machine; the agent reads it before writing and rendering merges new terms into it.
- [x] #11 A step explanation has four parts (what it adds, how it connects, concepts to know, how to read it) within 200 words; steps follow one coherent area of about 15 files at most.
- [x] #12 Each diff hunk shows the enclosing declarations when indentation reveals them, and the reader can expand context up, down, or to the whole file.
- [x] #13 The side panel keeps the explanation visible in its own resizable pane, and slides in from the right edge when hidden.
- [x] #14 Against two independent oracles on six PRs in seven languages, each of Haiku, Sonnet, Sol and Opus classifies at least 90% of the files the oracles agree on correctly.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Self-contained skill in .agents/skills/review-lens: prepare.py captures the change and Git facts (status, counts, touching commits, moved lines, generated-file hints, full file contents); one agent reads the previews and writes review.json directly; render.py validates coverage, categories, word limits and step titles, maps category to priority, and inlines a minimalist viewer. Priority comes from five categories with ordered rules, tuned against blind oracles. Installer copies the skill next to the session skills.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Single-agent rerun of PR 350 from a clean work dir with Sonnet 5.5, low thinking: 53 s, 156 files covered, 31 high / 57 mid / 62 low / 6 skip, migration high and its generated Designer and snapshot skip, 15-term glossary stored in ~/.review-lens/glossaries. Pi loads project skills from the working directory, so run it from a repo that has the skill installed.

Round 2 rerun of PR 350 from scratch, one Sonnet 5.5 agent, low thinking: 123 s, 12 steps of 6-20 files, explanations 107-134 words in four paragraphs, 32 high / 34 mid / 83 low / 7 skip, 13 glossary terms. Breadcrumbs found for 318 of 487 hunks. Page is 15 MB with full file contents; opens with no console errors. Renderer now enforces four explanation paragraphs, 110-200 words, at most 20 files per step.

Consistency test on PR 350, 5 independent Sonnet 5.5 runs per variant, same input. Level rule: 49/156 identical, skip count 6-43. Categories + Git moved-line counts: 97/156. Plus 'tests and docs are support': 143/156 identical (92%), 151 with 4 of 5 agreeing, one file 2+ levels apart. Inputs and runs in /tmp/rlcons, /tmp/rlcons2, /tmp/rlcons3.

Cross-language consistency, 5 Sonnet 5.5 runs each on open PRs: pydantic #14123 (Rust+Python, 13 files) 12/13 same priority; spring-boot #52241 (Java, 18 files) 16/18; TypeScript #65613 (Go+TS, 26 files) 22/26. Splits are borderline files (package-info.java, generated JSON schema, code generator script, a Rust validator registry). Work in /tmp/rlx.

Accuracy test against two blind oracles (Opus 5.5 by hand from full diffs, Astra 6.2 high thinking with repo access) on 5 open PRs, 86 files: pydantic #14123, spring-boot #52241, TypeScript #65613, aspnetcore #70618 (C#), tokio #8450 (Rust). Oracles agree on 73 files. Accuracy on those 73, 3 runs each: Haiku 5.5 97%, Sonnet 5.5 98%, Opus 5.5 97%, GPT-6.2 Sol 95%; two-level errors only Sonnet's generated JSON schema marked skip twice. Run-to-run agreement 88-97%. Oracle disagreements are contract vs behavior on internal wire signatures and package-info files. Work in /tmp/rlx.

Rule: internal interfaces changed on both sides are behavior; package-info is mechanical; generated mirrors stay mechanical inside a multi-file change; split steps are named by sub-area. PR 350 rerun with Sonnet 5.5: 64 s, 15 steps, overview follows one action through the layers.

Internal-interface rule retested on the 5 PRs (3 runs x 4 models + new Astra oracle): oracle agreement 73->76/86. aspnetcore internal hub signatures now behavior in 12/12 runs, package-info mechanical in 12/12. TypeScript protocol (Go server <-> TS client, version bump) still split: Astra oracle and Sonnet/Opus say contract, Haiku mostly behavior. Accuracy on agreed files: Haiku 98, Opus 99, Sol 94, Sonnet 93 (Sonnet now over-promotes internal Go/Rust driver code to high). No two-level errors.

Rule v3 (contract only when something outside the product depends on it; implementing internals are behavior) on the 5 PRs: oracles agree 78/86; accuracy on agreed files Haiku 97, Sonnet 98, Sol 100, Opus 100; run stability 93-98%. TypeScript Go/TS protocol: all 4 models and the Astra oracle say behavior in 11 of 12 runs per file; my oracle said contract. Remaining contested files are one-line accessor changes in tokio and a generator script.

Rule v4 (every API endpoint is contract; internal transport and signatures are behavior). 5 PRs: oracles agree 82/86; accuracy Haiku 99, Sonnet 97, Sol 99, Opus 100; stability 95-100%. PR 350 (156 files, Astra oracle only): endpoints high in 21/21 runs for Haiku, Sonnet, Sol, 14/21 for Opus. Agreement with oracle lower on the large PR: Haiku 90, Sol 94, Opus 84, Sonnet 70 (two Sonnet runs wrote headers as keys and one put 104 files in mid). Main split on PR 350: domain rule helpers and UI gates (NoteAddendumRules, NoteSubmitValidation, NoteWorkflows) high for Astra, mid for Opus/Sonnet.

PR 350 v5 (permission-deciding code is contract; paths printed alone on ### lines). Second oracle by Opus 5.5 from full diffs: oracles agree 139/156; all 17 disagreements are UI and page code that calls the access policy (Astra contract, Opus behavior). Accuracy on agreed files: Haiku 96, Sol 97, Opus 93, Sonnet 92; stability 87-94%; no format errors. Two-level errors: Sonnet 8, Opus 3, Haiku 2, Sol 0.

AC 'five runs agree on 90% of PR 350' replaced: on the final rules, 3 runs per model on PR 350 gave stability 92-94% for Haiku and Sol, 87% for Opus and Sonnet; the measured accuracy criterion replaces it. Final PR 350 run with Sonnet 5.5: 106 s, 15 steps, 32 high, endpoints contract 6 of 7, generated files skip; it produced a repeated step title, so render.py now rejects repeated titles. Viewer: top bar holds navigation, title, one progress counter, glossary, export, settings, panel; the filter sits beside each step's file list and persists; the legend lives in settings. Checks: tests/test_review_lens.py (6 tests), tests/test_install.sh pass; pages verified in headless Chrome with no console errors.

Review costs (wall clock ~34 min for the whole round, parallel): docs 4/20 turns 0.4 min; taste 4/20 0.8 min; spec 5/20 0.9 min; test 11/20 2.0 min; final 22/40 7.4 min; final correction check 8-turn budget, ~1 min. No timed-out commands. Outcome: spec 2 must-fix (quoted paths, markup-only notes), test 2 must-fix (contents/breadcrumb and structure coverage), final 3 must-fix (blank page after saved comment, core.quotePath=false crash, merge commits missing), all fixed with regression tests; correction check clean. Rejected: extracting hunk expansion from template.html, typed review payload.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added the review-lens skill to the Pandino kit: it turns a PR or branch into one self-contained HTML walkthrough for a human reader. Git-based preparation, a single agent pass, and a validating renderer; priority comes from five change categories that the renderer maps to high, mid, low and skip. Tuned against two blind oracles on six PRs in six languages (C#, Java, Rust, Python, Go, TypeScript): 92-100% accuracy across Haiku, Sonnet, Sol and Opus on the files the oracles agree on. Verified with unit tests, a browser filter test, the installer test, and headless-Chrome checks of the rendered PR 350 page. Follow-up: tracking glossary definition changes (TASK-34).
<!-- SECTION:FINAL_SUMMARY:END -->
