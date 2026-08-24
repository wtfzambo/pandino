---
id: decision-4
title: Use commit provenance and manual update checks
date: '2026-08-24 21:09'
status: accepted
---
## Context

Pandino previously left no durable source identity in target repositories. Semantic versions would require a release process that does not exist, while an automatic cross-harness update check would need persistent agent instructions or several tool-specific integrations. The installer can already fetch the rolling `main` kit, and the user needs a low-friction way for humans and agents to identify and compare it without adding session noise.

## Decision

Record the exact source commit when determinable in deterministic `.pandino/install.json`, and install a manual `.pandino/check-update` command that compares it with upstream `main`. Treat the manifest as provenance for the kit used by the latest successful installer run, not proof that `.pandino/merge/` was resolved. Remote installs pin the archive to a resolved commit; resolution failure falls back to the existing branch archive and records unknown. Local installs use HEAD when available and otherwise unknown. Any different upstream commit counts as newer. Add no semantic version, dirty-state analysis, content fingerprint, automatic check, hook, background process, or persistent `AGENTS.md` instruction. The operator approved this design on 2026-08-24.

## Consequences

A target can answer which Pandino source it last ran and can check for updates on demand with one stable command. Repeated installs remain deterministic and offline or legacy states remain explicit without blocking installation. Commits that do not affect installed artifacts may still appear newer, accepted as the simpler transparent rule. Fully automatic notifications are deferred unless Pandino later gains a common runtime or package manager.
