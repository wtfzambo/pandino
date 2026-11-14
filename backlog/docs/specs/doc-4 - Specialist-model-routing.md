---
id: doc-4
title: Specialist model routing
type: specification
created_date: '2026-09-28 22:19'
updated_date: '2026-11-14 21:11'
---
# Specialist model routing

## Current recommendations

These are the operator-selected defaults from 2026-11-14 (TASK-31), copied from the SnitchBro Pi setup for cost: GPT-6.1 Sol and Terra match the Claude models' intelligence scores at a much lower price. They replace the 2026-09-29 routing (TASK-19, TASK-26) where those models are available. They do not claim new benchmark results.

Each agent has an ordered list of model and effort pairs. A harness takes the first pair whose model its catalogue carries, so a fallback model brings its own effort.

| Agent | First choice | Fallbacks, in order |
|---|---|---|
| implementer | GPT-6.1 Sol · medium | Sonnet 5.5 · medium, `sonnet` · medium |
| taste / spec reviewer | GPT-6.1 Terra · medium | DeepSeek V4.1 Flash, GLM 5.3, Kimi K2.6, Kimi K2.7 Code, Sonnet 5.5, `opus`, `sonnet`, GPT-6 Luna, all high |
| docs reviewer | GPT-6.1 Terra · low | the same as taste and spec |
| test reviewer | GPT-6.1 Sol · high | Sonnet 5.5, `sonnet`, `opus`, DeepSeek V4 Pro, DeepSeek V4.1 Flash, GLM 5.3, all high |
| final reviewer | GPT-6.1 Sol · max | Opus 5.5, `opus`, GPT-6 Astra, Sonnet 5.5, `sonnet`, all medium |

Pi and Codex carry Sol and Terra and get the first choices. Claude Code gets `sonnet` medium for implementation, `opus` high for taste, spec and docs review, `sonnet` high for test review and `opus` medium for final review. OpenCode gets Sol where its catalogue has it and the next pair elsewhere.

The writer, test reviewer and final reviewer share Sol on Pi and Codex, at different efforts. Their responsibilities and sessions remain separate; different effort is not model diversity. The operator accepts this for cost. Claude Code receives the `sonnet` and `opus` aliases rather than full model IDs, so each agent follows the newest version of that family available to the account.

## Configuration ownership

`models.sh` owns the ordered model and effort pairs per agent. `agents/*.md` holds the effort used only for a saved model outside those pairs: medium for implementation and final review, high for routine and test review. `harnesses.sh` translates the assigned model and effort into native agent definitions.

Automatic recommendations omit superseded generations: GPT-5.x, GPT-6 Sol, Claude Opus/Sonnet 5, DeepSeek V4 Flash and GLM 5.2. GLM 5.3 replaces its older fallback entry. Kimi is an operator-selected exception: keep K2.6 followed by K2.7 Code, excluding K3 because its operation in the user setup is uncertain. Catalogue presence alone does not verify runtime availability. DeepSeek V4 Pro remains eligible because the inspected catalogue has no newer Pro successor. Removing a recommendation does not invalidate an explicitly saved model choice or rewrite historical benchmark records (TASK-20).

## Saved assignments

`.pandino/models.json` is the one file an operator edits to choose models and efforts. It holds one block per harness and one entry per pinned agent:

```json
{
  "pi": {
    "final-reviewer": { "model": "openai/gpt-6.1-sol", "effort": "max" }
  }
}
```

The installer reads it, fills in anything missing, writes it back complete, and regenerates the agent files from it. Generated agent files are output. To change a model or effort, edit `models.json` and re-run the installer. A Pi agent file that differs from the kit only in its `model` and `thinking` lines is Pandino output and is rewritten without staging a merge candidate.

- Saved models win over recommendations unless the model is on the superseded list in `models.sh` (GPT-5.6 Terra, Sol and Luna, GPT-6 Sol, Claude Opus 5 and Sonnet 5, DeepSeek V4 Flash, GLM 5.2). A superseded model is resolved again, and the recap names its replacement. To keep an older model deliberately, pin one that is not on that list.
- A saved effort applies to that agent in that harness. The recap reports an effort the harness does not accept, and the agent takes the effort its preferences pair with the model. Accepted levels are `off`, `minimal`, `low`, `medium`, `high`, `xhigh` and `max` on Pi, and `low`, `medium`, `high`, `xhigh` and `max` on Claude Code, Codex and OpenCode.
- A saved model without a saved effort takes the effort its preferences pair with it, or the `agents/*.md` effort for a model outside them. On Pi, an installed agent whose `thinking` differs from the kit keeps its own level, and the recap names it. This carries efforts edited by hand before `models.json` held effort into the file.
- Earlier versions keyed models by role (`implementer`, `reviewer`, `test`, `final`) without effort. The installer reads that format and rewrites it per agent, applying `reviewer` to the taste, spec and docs reviewers.
- `fallback-runner` has no saved entry. Its caller supplies an explicit model.

## Fallbacks

If a recommendation is unavailable, the resolver uses the next matching catalogue entry from `models.sh`. The installer reports substitutions for provider-qualified catalogues such as Pi and OpenCode; native Codex/Claude adaptations appear in the assignment matrix without separate substitution notices. If it finds no suitable model, the installer reports main-model inheritance. `fallback-runner` remains unpinned and absent from saved model routing; its caller must supply an explicit model.

## Effort translation

Pi preserves `thinking` in agent frontmatter. Claude Code uses `effort`. Codex uses `model_reasoning_effort` for pinned agents. OpenCode uses `reasoningEffort` for GPT/DeepSeek pins and `effort` for Claude 5.5 pins; older Claude pins and unrelated model families do not receive guessed provider options. GPT-6 OpenCode agents also receive `forceReasoning: true`: the OpenAI Responses SDK bundled in inspected OpenCode 1.15.10 otherwise omits their reasoning effort because its model-prefix detection predates GPT-6. An offline serialization probe confirmed that this option emits the requested medium/high effort. OpenCode Opus 5.5 is configured directly rather than using a nonexistent medium variant in the inspected catalogue.

These fields express the requested effort through native configuration. Actual service behavior still depends on the harness adapter and provider. Tests of generated files and loader output are distinct from paid inference verification.

## Evidence and rationale

On 2026-10-22 a focused test-review comparison ran seven cases three times at high effort. GPT-6.1 Sol matched 39/45 seeded problems and completed every attempt with no verified harmful recommendation; DeepSeek V4.1 Flash matched 42/45 but recommended deleting useful tests at least six times and timed out once. GPT-6 Astra matched Sol's 39/45; an incomplete Haiku 5.5 screen matched 12/15 in its only round. The [focused report](../../../bench/review/results/sol61-flash41-test-review.md) holds the evidence. Decision-10 records keeping Sol for test review and the Claude Code aliases; decision-8 records the earlier operator routing choice; decision-2 remains historical rationale for separate test review.
