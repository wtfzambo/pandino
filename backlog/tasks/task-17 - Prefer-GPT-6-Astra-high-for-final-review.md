---
id: TASK-17
title: Prefer GPT-6 Astra high for final review
status: Done
assignee:
  - '@zambo'
created_date: '2026-09-08 21:10'
updated_date: '2026-09-08 21:17'
labels: []
dependencies: []
references:
  - 'https://developers.openai.com/codex/subagents/'
  - 'https://opencode.ai/docs/agents/'
type: enhancement
ordinal: 17000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The operator requests GPT-6 Astra at high thinking instead of Opus 5 for final review in harnesses that expose Astra. Local catalogues confirm openai-codex/gpt-6-astra in pi, gpt-6-astra in Codex, and opencode/gpt-6-astra in OpenCode; Claude Code exposes its Claude aliases. Existing saved model assignments remain user-owned. This is an explicit routing choice, not a benchmark claim.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Final-model resolution selects gpt-6-astra before Opus when offered, retaining the existing fallback order when Astra is absent and preserving saved user choices.
- [x] #2 Astra final-review agents receive high reasoning in each supported native format: pi thinking, Codex model_reasoning_effort, and OpenCode reasoningEffort; other roles and read-only boundaries remain unchanged.
- [x] #3 The local pi final-reviewer and saved assignment use Astra high; current routing documentation and targeted installer evidence match the change.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify live catalogue IDs and native effort fields from the Codex/OpenCode agent documentation.
2. Extend existing installer tests with Astra catalogues, high-effort outputs, fallback coverage and saved-final override preservation; observe the expected failure against current routing.
3. Add Astra first in the final preference list and emit high effort only for Astra final agents in Codex/OpenCode; pi already preserves the canonical high setting. Update the local pi pin and saved final assignment.
4. Refresh the README routing example and notes, run installer regressions and diff hygiene, then finalize the task and refresh pickup at handoff. This is a small routing/exporter patch handled directly; no paid model benchmark or broad review pipeline.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Confirmed local catalogue IDs with pi --list-models, opencode models, and the Codex model cache; Codex explicitly lists high as supported for Astra. Codex subagent documentation confirms model_reasoning_effort in agent TOML; OpenCode agent documentation confirms reasoningEffort passthrough. The final preference list now starts with Astra, preserving the previous fallback order and saved-assignment precedence. Native exporters translate the canonical high field only for Astra final review. The local ignored pi agent and saved assignment were updated; README explains how an existing installation can clear only its final entry to re-resolve the recommendation.

Extended existing installer evidence before implementation: the suite exited 1 and the old resolver still chose Opus despite Astra being available. After the change, bash tests/test_install.sh passes, covering model selection and high effort across pi/OpenCode/Codex, Claude opus fallback, Astra-absent fallbacks, saved-final overrides, and removal of Astra-specific effort fields when switching to a saved fallback. Existing installer assertions retain role isolation and read-only output guarantees. bash -n models.sh harnesses.sh tests/test_install.sh and git diff --check pass. A temporary isolated OpenCode agent loaded through opencode debug agent final-reviewer --pure resolves model opencode/gpt-6-astra with options.reasoningEffort high; the temporary directory was removed. Main read the integrated diff and local pi configuration. This bounded routing/exporter change used direct implementation and existing evidence, with no paid model invocation, new benchmark, reviewer pipeline, commit, or push.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Final review now prefers GPT-6 Astra at high reasoning where available. Codex and OpenCode receive their native effort settings from the canonical agent; pi retains thinking high. Claude and Astra-absent catalogues keep their fallbacks, and saved user choices remain authoritative. Updated local pi configuration and routing docs. Verified with installer regressions, shell syntax/diff checks, and the real OpenCode agent loader.
<!-- SECTION:FINAL_SUMMARY:END -->
