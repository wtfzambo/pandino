---
id: decision-13
title: Adopt SnitchBro GPT-6.1 routing with per-agent model and effort pairs
date: '2026-11-14 21:12'
status: accepted
---
## Context

The operator ran SnitchBro on Pi with GPT-6.1 Sol and Terra, because at equal intelligence scores they cost much less than the Claude models: implementer Sol medium, taste and spec Terra medium, docs Terra low, test Sol high, final Sol max. The operator asked to make this Pandino's Pi routing. Recommendations were per role group with a separate kit effort, so a fallback model inherited an effort chosen for a different model, and Claude Code would have received Opus at max.

## Decision

Every pinned agent has an ordered list of model and effort pairs in `models.sh`. A harness takes the first pair its catalogue carries. The SnitchBro pairs come first; the previous routing follows as fallbacks with its own efforts. Final review shares Sol with the implementer, which the operator accepts for cost.

The alternatives were per-harness defaults, which add a second mechanism, and editing the kit efforts in `agents/*.md`, which would also change Claude Code and every fallback.

## Consequences

Pi and Codex get the SnitchBro routing because both catalogues carry Sol and Terra. Claude Code keeps `sonnet` and `opus` at their previous efforts. OpenCode gets Sol where available and the next pair otherwise. No reviewer runs on a model family different from the writer on Pi or Codex so final review has no model diversity there. `agents/*.md` effort only applies to a saved model outside the pairs. The routing has no new benchmark evidence.
