Tests pass (`test_billing: PASS`). No formatter/linter/type-checker config exists in the repo, so I judged style against AGENTS.md directly.

The core of the diff — `collection_action` with its three-way threshold logic, the precedence check, the named constants, and the boundary tests — is correct, linear control flow with a genuine decision (wait wins when both thresholds are hit) covered by `collection_action(30, 3)`. The problems are concentrated in its wording.

**Must-fix**

1. `billing.py:26` — `age_days_not_status_text` embeds a contrastive negation in an identifier; no plausible reader would assume this argument is status text (the signature `-> CollectionAction` rules it out). Rename to `age_days`.

2. `billing.py:22-23` — `# Return not a status message, but the total in cents.` restates `return total_cents` (AGENTS.md: "comments ... never restate the code") and adds an unmotivated negation on top. Delete the comment.

3. `billing.py:16` — the parse_amount docstring now ends "into cents, not a pre-parsed integer cent value." Nobody who sees `amount_text: str` and the `".".split()` body can misread the input as an integer. Revert to the original "Convert a dollar amount with two decimal places into cents."

**Minor**

4. `billing.py:6` and `:10` — the negated clauses "not business days" and "not retries" pass AGENTS.md's stated-reason test only because the reason sentence follows, and that sentence alone carries the information ("feed includes weekends"; "initial call plus two retries uses all three attempts"). Under this AGENTS.md's strict rule — reread without the negated clause and nothing is lost — each could drop the negation. Borderline; I would shorten to the reason sentence, but the constant comments are otherwise the strongest part of the diff.

**Good**

- `CollectionAction` Literal is a justified domain type: it names the three valid states instead of returning bare `str`.
- Constants are named, typed, and co-located with the behavior they govern; the reason comments convey real constraints (weekend-inclusive aging feed, initial call counting as an attempt).
- Test expectations are hand-derived at both boundary pairs (age 30/31, calls 2/3) including the precedence case; they fail under plausible defects (off-by-one in either direction, swapped branch order) and don't recompute the implementation.

Diff overall: good structure and coverage; clean up the three negations and it reads plainly.
