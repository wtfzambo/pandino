# Falsified hypotheses

## 2026-10-22. A Pi reviewer deadline must also stop detached tool groups

**Hypothesis:** Terminating the reviewer's process group stops the commands it launched.

**Evidence:** Pi coding agent 1.3.0 starts its bash tool with `detached: process.platform !== "win32"` in `dist/core/tools/bash.js`. Two TypeScript mutation probes survived the interrupted timing benchmark in their own process groups. The detached-tool regression in `tests/test_bench_timeout.py` failed under group-only cleanup and passes when the wrapper discovers descendant groups before terminating the reviewer.

**Consequence:** The benchmark wrapper captures and stops descendant groups on timeout and cancellation. This covers attached descendants that create a separate group, including Pi tools. It does not promise cleanup of processes that deliberately reparent themselves before discovery.

**References:** The benchmark deadline fix and reviewer timing comparison (TASK-27), `bench/run_with_timeout.py`, `tests/test_bench_timeout.py`.

## 2026-09-29 — OpenCode GPT-6 effort needs an explicit reasoning capability override

**Hypothesis:** Setting `reasoningEffort: medium` or `high` on an OpenCode GPT-6 agent is sufficient to serialize the requested effort.

**Evidence:** An offline dummy-fetch probe of `@ai-sdk/openai` 3.0.53 extracted from the installed OpenCode 1.15.10 binary called `sdk.languageModel("gpt-6-sol")` with each effort. Both `/responses` request bodies omitted `reasoning`. Adding provider option `forceReasoning: true` produced `reasoning: { effort: "medium" }` and `reasoning: { effort: "high" }` respectively. The bundled SDK uses `forceReasoning ?? modelCapabilities.isReasoningModel`; its prefix detection misses GPT-6. OpenCode's Zen loader uses this Responses path without supplying the override. This verifies serialization offline, not live provider acceptance.

**Consequence:** Pandino emits `forceReasoning: true` alongside canonical effort for GPT-6 OpenCode agents. Catalogue reasoning support and successfully loaded agent options alone do not establish the outgoing request's effort. Re-evaluate this compatibility option when the OpenCode SDK changes.

**References:** [TASK-19](backlog/tasks/task-19%20-%20Refresh-specialist-models-and-native-thinking-levels.md), [routing specification](backlog/docs/specs/doc-4%20-%20Specialist-model-routing.md), [OpenCode v1.15.10 provider selection](https://github.com/anomalyco/opencode/blob/v1.15.10/packages/opencode/src/provider/provider.ts).
