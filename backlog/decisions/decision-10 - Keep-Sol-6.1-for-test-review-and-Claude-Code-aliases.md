---
id: decision-10
title: Keep Sol 6.1 for test review and Claude Code aliases
date: '2026-10-22 18:01'
status: accepted
---
## Context

The operator considered moving test review from GPT-6.1 Sol to DeepSeek V4.1 Flash, the routine reviewer. The historical reason for Sol (13/15 against Flash V4 8/15) predated both current models. A focused comparison on 2026-10-22 ran seven test-review cases three times at high effort. Flash matched 42/45 seeded problems against Sol's 39/45, a difference from one gap missed in all three Sol runs. Flash also recommended deleting useful tests at least six times, each disproved by a counterexample, executed file-changing mutations despite its read-only role, and timed out once. Sol completed 21/21 with no verified harmful recommendation. GPT-6 Astra matched Sol's 39/45. Haiku 5.5 matched 12/15 in its only complete round and repeated harmful deletion advice before a safety stop ended the screen. The [focused report](../../bench/review/results/sol61-flash41-test-review.md), the [Astra report](../../bench/review/results/astra6-flash41-test-review.md) and the [Haiku report](../../bench/review/results/haiku55-test-review.md) hold the evidence.

The operator had also asked for an explicit Sonnet 5.5 pin on Claude Code, while the installer emits the `sonnet` and `opus` aliases.

## Decision

Keep GPT-6.1 Sol high as the test reviewer. A reviewer that recommends deleting protective tests does damage a missed finding does not, and three extra matches on one gap do not outweigh it. Flash stays the routine taste, spec and docs reviewer.

Keep the `sonnet` and `opus` aliases on Claude Code. Claude Code resolves each alias to the newest model of that family available to the account, so installations follow new releases without a Pandino update. Full model IDs would freeze each installation at the pinned version.

## Consequences

`models.sh` keeps its test-role preferences and Claude Code catalogue unchanged. Saved assignments need no migration. The writer and test reviewer keep sharing Sol with different effort, so that pair has separate sessions and responsibilities without model diversity. A Claude Code agent's exact model version depends on the account and the alias at run time. The comparison covers small fixtures and establishes no statistical ranking; a new candidate needs fresh evidence before it replaces Sol.
