---
id: decision-2
title: Route test review separately to Sol high
date: '2026-08-20 22:49'
status: accepted
---
## Context

Taste, spec, and documentation review share the inexpensive routine `reviewer` model role. The evidence-review benchmark showed that this routing is not strong enough for test review: on comparable original-plus-language r1 tasks, Sol high found 13/15 must-fix gaps while Flash high found 8/15. Across repeated finalist runs, Sol high and medium both found 40/45 must-fix gaps, but high kept a 4/5 floor where medium fell to 3/5 and produced one fewer language defect false positive. Medium was faster, cheaper, and produced one fewer clean false positive. The detailed authority is `bench/review/results/manual-audit.md`.

## Decision

Add a separate saved `test` model role and recommend `openai-codex/gpt-5.6-sol` at high thinking for `test-reviewer`. Keep taste, spec, and docs review on the shared `reviewer` role. Resolve the test model independently for every selected harness from that harness's available catalogue, preserve an existing `.pandino/models.json` choice, and use the documented fallback preference order when Sol is unavailable. Keep `fallback-runner` unpinned and absent from saved routing. The operator approved this routing on 2026-08-20.

## Consequences

Relevant commits gain a more stable mutation-minded test review at higher latency and cost than Flash, while documentation-only and trivial non-behavioral changes incur no test-review call. Installations gain a fourth persisted model key (`test`) and a seventh helper across Pi, Claude Code, opencode, and Codex. Harnesses without Sol use the best available fallback rather than receiving an unusable pin, and user-edited model assignments continue to outrank Pandino's recommendation.
