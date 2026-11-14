---
id: decision-11
title: Define must-fix and report operator decisions separately
date: '2026-10-30 00:14'
status: accepted
---
## Context

The review audit of one SLYE session (TASK-30) found two failures that more orchestrator instructions had not prevented. A taste review that found no correctness bug labelled four return branches and an overbuilt class must-fix, and the orchestrator then applied every minor suggestion. A spec reviewer identified old-Pi support as the operator's choice, yet the orchestrator built it, and the operator later had it deleted. The SLYE rules at the time already said to surface scope-creep findings to the user, so the rule existed and was not followed. The report format offered only `must-fix` and `minor`, with no definition of must-fix and no place for a choice that belongs to the operator.

## Decision

`reviewing.md` defines must-fix as a change that breaks behavior working today, or that leaves an in-scope requirement of the task, specification, or definition of done unmet. Style, readability, naming, structure, and wording are minor. A third heading, `user decision`, carries product, scope, and support choices the task leaves open, with their options; the spec reviewer files unrequested behavior there. Minor findings and user decisions alone leave a verdict clean. The orchestrator judges severity by these definitions rather than the reviewer's heading, and brings user decisions to the user in one checkpoint before building any of them. The operator approved the must-fix threshold and the separate heading on 2026-10-30.

The alternatives were to keep the format and wait for a delivery under the current kit to show whether the orchestrator rules suffice, or to complete the full blocking-finding rubric (TASK-23) with uncertain risks, deferred checks, and worked examples. The first leaves both observed failures to the same instruction that already failed once. The second is larger than one audit justifies.

## Consequences

A reviewer can no longer escalate a style preference through the must-fix heading, and a choice for the operator arrives already labelled as one, so the orchestrator has to reclassify it explicitly to treat it as work. The rest of TASK-23 remains open. The benchmark judge counts an invented user decision as a false positive, like any other invented finding; existing ground truth lists unrequested behavior as a spec defect to find, and a spec reviewer filing it under the new heading still finds it. Whether this reduces discarded work is visible only in later real sessions; no benchmark measures it.
