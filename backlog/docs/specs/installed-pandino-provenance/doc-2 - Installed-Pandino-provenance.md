---
id: doc-2
title: Installed Pandino provenance
type: specification
created_date: '2026-08-24 21:09'
updated_date: '2026-08-24 21:29'
---
# Installed Pandino provenance

## Purpose

Humans and agents can identify which Pandino kit powered the latest successful installer run and manually check whether upstream `main` has advanced. This is commit provenance, not semantic versioning or proof that staged merge candidates were applied.

## Installation manifest

A successful installer run writes deterministic `.pandino/install.json`:

```json
{
  "repository": "https://github.com/wtfzambo/pandino",
  "revision": "975a309000000000000000000000000000000000"
}
```

`revision` is the validated 40-hex kit commit when determinable and JSON `null` otherwise. No timestamp, dirty-worktree state, content fingerprint, merge state, or release version is stored. The installer replaces this Pandino-owned file on every successful run. Its revision identifies the source kit used by that run; `.pandino/merge/`, when present, remains the separate signal that candidates still require semantic reconciliation.

For a local checkout, use its Git HEAD when available and valid, otherwise `null`. For remote bootstrap, resolve upstream `main`, download the archive pinned to that commit, and record it. If resolution fails, preserve the existing branch-archive installation fallback and record `null`; provenance lookup must not make installation less available.

## Manual update check

The installer copies executable `.pandino/check-update`. It reads the adjacent manifest, resolves current upstream `main`, validates both revisions, and compares exact commits. Any different upstream commit counts as an available update.

- Current: print both identity and current status; exit `0`.
- Update available: print installed and upstream short revisions plus their comparison URL; exit `1`.
- Missing, null, or malformed installed revision, or unavailable/malformed upstream response: print an unknown-status explanation; exit `2`.

The checker never changes the manifest or repository. It is manual only: Pandino adds no startup check, hook, background process, or persistent `AGENTS.md` instruction.

## Update procedure

The human and agent update instructions run `.pandino/check-update` first when it exists. A current result stops the update when `.pandino/merge/` is absent unless the user explicitly wants a reinstall; when merge candidates exist, skip the installer and reconcile those candidates instead. An update-available result continues with the latest installer. A missing checker or unknown result is expected for older or unidentifiable installations and also continues with the normal update flow.
