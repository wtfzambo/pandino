"""Score one review against its task's expected.md with a judge model.

Usage: judge.py expected.md review.md out.json
Prints "found,total,false_positives,minor_found,minor_total" for the results CSV.
The judge model is not one of the benchmarked contestants, to avoid
scoring its own style favorably.
"""

import json
import os
import re
import subprocess
import sys

JUDGE_MODEL = os.environ.get("BENCH_JUDGE_MODEL", "anthropic/claude-fable-5")
MAX_ATTEMPTS = 2

PROMPT = """You are scoring a code review against a ground-truth list of planted defects.

GROUND TRUTH (what a perfect review finds):
{expected}

REVIEW UNDER SCORING:
{review}

Rules:
- A planted defect counts as found only if the review identifies the same problem in the same place; naming the exact rule wording is not required. A concern on the same line or in the same code area does not count when it describes a different failure mode.
- If a ground-truth item is compound, count it only when the review identifies every required component of that item.
- `Must-fix` ground-truth items count in `defects_found` and `defects_total`. `Minor excess` ground-truth items count separately in `minor_found` and `minor_total`.
- Older ground truth without those headings treats every numbered planted defect as must-fix and has a minor total of zero.
- A must-fix or minor finding in the review that is not a listed planted defect and not a real defect in the described code is a false positive. "Good" notes and observations the reviewer explicitly rejects or self-dismisses are not false positives.
- If the ground truth says the diff is clean, the relevant total is zero and any actionable finding in that severity is a false positive.

Reply with ONLY a JSON object: {{"defects_found": [<must-fix numbers>], "defects_total": <n>, "minor_found": [<minor numbers>], "minor_total": <n>, "false_positives": <n>, "notes": "<one line>"}}
"""


def main() -> None:
    expected_path, review_path, out_path = sys.argv[1:4]
    expected = open(expected_path).read()
    review = open(review_path).read().strip() or "(the reviewer produced no review text)"
    command = [
        "pi", "-p", "--no-session", "--no-extensions", "--no-skills", "--no-tools",
        "--no-context-files", "--mode", "text", "--model", JUDGE_MODEL, "--thinking", "low",
        PROMPT.format(expected=expected, review=review),
    ]
    failures = []

    for attempt in range(1, MAX_ATTEMPTS + 1):
        try:
            result = subprocess.run(command, capture_output=True, text=True, timeout=300)
        except subprocess.TimeoutExpired as error:
            failures.append((attempt, "timed out", error.stdout or "", error.stderr or ""))
            print(f"judge attempt {attempt}/{MAX_ATTEMPTS} timed out; retrying same model", file=sys.stderr)
            continue

        if result.returncode:
            failures.append((attempt, f"exited {result.returncode}", result.stdout, result.stderr))
            print(f"judge attempt {attempt}/{MAX_ATTEMPTS} exited {result.returncode}; retrying same model", file=sys.stderr)
            continue

        match = re.search(r"\{.*\}", result.stdout, re.DOTALL)
        if not match:
            failures.append((attempt, "returned no JSON", result.stdout, result.stderr))
            print(f"judge attempt {attempt}/{MAX_ATTEMPTS} returned no JSON; retrying same model", file=sys.stderr)
            continue

        try:
            verdict = json.loads(match.group())
        except json.JSONDecodeError:
            failures.append((attempt, "returned invalid JSON", result.stdout, result.stderr))
            print(f"judge attempt {attempt}/{MAX_ATTEMPTS} returned invalid JSON; retrying same model", file=sys.stderr)
            continue

        json.dump(verdict, open(out_path, "w"), indent=2)
        print(
            f"{len(verdict['defects_found'])},{verdict['defects_total']},"
            f"{verdict['false_positives']},{len(verdict.get('minor_found', []))},"
            f"{verdict.get('minor_total', 0)}"
        )
        return

    details = "\n\n".join(
        f"attempt {attempt}/{MAX_ATTEMPTS} {reason}\nstdout:\n{stdout}\nstderr:\n{stderr}"
        for attempt, reason, stdout, stderr in failures
    )
    raise SystemExit(f"judge {JUDGE_MODEL} failed after {MAX_ATTEMPTS} attempts:\n{details}")


if __name__ == "__main__":
    main()
