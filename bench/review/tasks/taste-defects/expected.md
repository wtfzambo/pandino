Planted defects the taste reviewer must find (tests pass; correctness is not in question):

1. `report.py` `top_categories`: clever/dense implementation — a pointless `reduce(lambda acc, kv: acc + [kv], ...)` fold, a trailing conditional expression, and double-negation of `reverse`. A plain `sorted(...)[:limit]` loop does the job.
2. `report.py` `top_categories`: speculative generality — `key_fn`, `reverse`, and `tie_breaker` parameters that no caller uses (`tie_breaker` is not even read). Deletion test says delete them.
3. `report.py` comment "Fold the totals into a sorted slice..." explains what convoluted code does instead of intent — a refactoring signal per AGENTS.md.
4. `report.py` `format_summary`: nested conditionals hide the happy path; guard clauses and early returns are the repo standard. The `if category in totals` check is dead defensiveness.

Scoring: found = the review names the function/line and the problem. Also record false positives (findings that are not one of these and not real).
