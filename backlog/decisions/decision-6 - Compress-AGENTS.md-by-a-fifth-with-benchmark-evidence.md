---
id: decision-6
title: Compress AGENTS.md by a fifth with benchmark evidence
date: '2026-09-02 21:35'
status: accepted
---
## Context

`AGENTS.md` is read by every agent on every turn, so its length is a per-turn cost and its prose is what the model actually follows. Two audits asked how much could go without losing a rule: DeepSeek V4 Flash found about 5% of pure duplication, and GLM 5.3 Flash produced a full rewrite at 20% shorter. Whether that rewrite still steered the production models the same way was an open question, and the only test that answered it was running them.

## Decision

Adopt the GLM rewrite as the core of `AGENTS.md`, with the four regressions found by hand repaired: review timing stays "near the end of a logical slice", the pickup snapshot keeps `absolute date`, the governance no-machinery rule keeps its full enumeration, and the tests paragraph keeps the exploration-then-stable-cut-point sequence. Two of GLM's own cuts were reverted because they removed a rule rather than words: the priority order is a list again, and "never compress straightforward behavior into clever expressions" is back. The two appended snippets were compressed with the same discipline and the installed `AGENTS.md` is assembled from them verbatim.

Evidence: `bench/agents-variants/` ran the current file, the GLM rewrite, and the DeepSeek edit through five existing tasks on the production model for each role, three runs each. All three matched on every recall measure (taste 12/12, negations 9/9 with controls kept, test evidence 12/15 missing the same known item, implementer stop 3/3); the only spread was on `taste-clean`, where the disagreement is with the fixture rather than between variants. The rewrite was cheaper per run on input tokens. Rules the benchmark cannot exercise — fallback-runner, adjudication, continuity — were checked by hand, 32 for 32 present.

Versions are marked with Git tags: `agents-v1` is the last long-form file, `agents-v2` the rewrite. `git diff agents-v1 agents-v2 -- AGENTS.md` shows the whole change; `.pandino/install.json` already records which commit a downstream repository installed.

## Consequences

The file is 2,270 words against 2,734, a 17% cut overall and 22% on the editable core once the fixed Backlog block is excluded. Downstream repositories pick it up on their next Pandino update; their own `AGENTS.md` is never overwritten, so the new core lands in `.pandino/merge/` where it differs. The benchmark harness stays for the next rewrite: a candidate goes under `variants/` and runs against the same ground truth, so "shorter" can be checked against "still works" before it ships.
