---
id: doc-4
title: Specialist model routing
type: specification
created_date: '2026-09-28 22:19'
updated_date: '2026-09-28 22:43'
---
# Specialist model routing

## Current recommendations

These are the operator-selected defaults from 2026-09-29 (TASK-19), resolved against each harness catalogue. They do not claim new benchmark results.

| Harness | Implementer | Taste / spec / docs | Test reviewer | Final reviewer |
|---|---|---|---|---|
| Pi / OpenCode | GPT-6 Sol · medium | DeepSeek V4.1 Flash · high | GPT-6 Sol · high | Claude Opus 5.5 · medium |
| Codex | GPT-6 Sol · medium | GPT-6 Luna · high | GPT-6 Sol · high | GPT-6 Astra · medium |
| Claude Code | sonnet alias · medium | opus alias · high | opus alias · high | opus alias · medium |

The writer and test reviewer deliberately share Sol with different effort settings. Their responsibilities and sessions remain separate; different effort is not model diversity. Claude Code aliases resolve to the versions available to the account, rather than an explicit 5.5 pin.

## Configuration ownership and fallbacks

`models.sh` owns ordered recommendations and agent-to-role mapping. `agents/*.md` owns canonical effort: medium for implementation/final review and high for routine/test review. `harnesses.sh` translates these into native agent definitions.

Automatic recommendations omit superseded generations: GPT-5.x, Claude Opus/Sonnet 5, DeepSeek V4 Flash and GLM 5.2. GLM 5.3 replaces its older fallback entry. Kimi is an operator-selected exception: keep K2.6 followed by K2.7 Code, excluding K3 because its operation in the user setup is uncertain. Catalogue presence alone does not verify runtime availability. DeepSeek V4 Pro remains eligible because the inspected catalogue has no newer Pro successor; Claude Code keeps the current `opus` and `sonnet` aliases. Removing a recommendation does not invalidate an explicitly saved model choice or rewrite historical benchmark records (TASK-20).

`.pandino/models.json` stores the selected model for each harness and role (`implementer`, `reviewer`, `test`, `final`). Saved choices win over recommendations, including a separately chosen test model. Existing installations do not automatically migrate to new model defaults. To adopt a recommendation, remove the corresponding saved role entry or set the desired model explicitly, re-run the installer, and reconcile any `.pandino/merge/` candidates while preserving project-specific instructions.

If a recommendation is unavailable, the resolver uses the next matching catalogue entry from `models.sh`. The installer reports substitutions for provider-qualified catalogues such as Pi and OpenCode; native Codex/Claude adaptations appear in the assignment matrix without separate substitution notices. If it finds no suitable model, the installer reports main-model inheritance. `fallback-runner` remains unpinned and absent from saved model routing; its caller must supply an explicit model.

## Effort translation

Pi preserves `thinking` in agent frontmatter. Claude Code uses `effort`. Codex uses `model_reasoning_effort` for pinned agents. OpenCode uses `reasoningEffort` for GPT/DeepSeek pins and `effort` for Claude 5.5 pins; older Claude pins and unrelated model families do not receive guessed provider options. GPT-6 OpenCode agents also receive `forceReasoning: true`: the OpenAI Responses SDK bundled in inspected OpenCode 1.15.10 otherwise omits their reasoning effort because its model-prefix detection predates GPT-6. An offline serialization probe confirmed that this option emits the requested medium/high effort. OpenCode Opus 5.5 is configured directly rather than using a nonexistent medium variant in the inspected catalogue.

These fields express the requested effort through native configuration. Actual service behavior still depends on the harness adapter and provider. Tests of generated files and loader output are distinct from paid inference verification.

## Evidence and rationale

The earlier test-review benchmark found Sol 13/15 defects versus Flash 8/15 and favored high over medium effort. That historical result explains the separate test-review role; it does not establish the performance of Sol 6 or Flash 4.1. TASK-19 records catalogue probes, native format evidence and verification for this routing change. Decision-8 records the operator routing choice; decision-2 remains historical rationale for separate test review.
