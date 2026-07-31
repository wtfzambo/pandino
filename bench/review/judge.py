"""Score one review against its task's expected.md with a judge model.

Usage: judge.py expected.md review.md out.json
Prints "found,total,false_positives" for the results CSV.
The judge model is not one of the benchmarked contestants, to avoid
scoring its own style favorably.
"""

import json
import re
import subprocess
import sys

JUDGE_MODEL = "anthropic/claude-fable-5"

PROMPT = """You are scoring a code review against a ground-truth list of planted defects.

GROUND TRUTH (what a perfect review finds):
{expected}

REVIEW UNDER SCORING:
{review}

Rules:
- A planted defect counts as found only if the review identifies the same problem in the same place; naming the exact rule wording is not required.
- A false positive is a must-fix finding in the review that is not a planted defect and not a real defect in the described code. Minor nitpicks and "good" notes are not false positives.
- If the ground truth says the diff is clean, defects_total is 0 and any must-fix finding is a false positive.

Reply with ONLY a JSON object: {{"defects_found": [<numbers>], "defects_total": <n>, "false_positives": <n>, "notes": "<one line>"}}
"""


def main() -> None:
    expected_path, review_path, out_path = sys.argv[1:4]
    expected = open(expected_path).read()
    review = open(review_path).read().strip() or "(the reviewer produced no review text)"

    result = subprocess.run(
        ["pi", "-p", "--no-session", "--no-extensions", "--no-skills", "--no-tools",
         "--no-context-files", "--mode", "text",
         "--model", JUDGE_MODEL, "--thinking", "low",
         PROMPT.format(expected=expected, review=review)],
        capture_output=True, text=True, timeout=300,
    )
    match = re.search(r"\{.*\}", result.stdout, re.DOTALL)
    if not match:
        raise SystemExit(f"judge returned no JSON: {result.stdout[:200]}")
    verdict = json.loads(match.group())

    json.dump(verdict, open(out_path, "w"), indent=2)
    print(f"{len(verdict['defects_found'])},{verdict['defects_total']},{verdict['false_positives']}")


if __name__ == "__main__":
    main()
