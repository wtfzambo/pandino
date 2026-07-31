# Pandino model benchmarks

Measures which models fit the three Pandino agent roles (implementer, taste reviewer, spec reviewer) on this machine, through headless pi. Results feed the routing suggestions in [`NOTES.md`](../NOTES.md).

## How it works

Every run is one headless pi invocation, isolated from the local setup:

```
pi -p --no-session --no-extensions --no-skills --mode json \
   --model <model> --thinking high \
   --append-system-prompt <role-prompt> "<task prompt>"
```

- The role prompt is the agent's markdown from `agents/`, frontmatter stripped (regenerate with the `awk '/^---$/{n++; next} n>=2'` one-liner in git history if agents change).
- The task runs in a temp workdir seeded with the task's files plus the kit `AGENTS.md`, so the model sees the same context a real Pandino repo gives it.
- `--no-extensions` keeps the environment clean but also unloads the ollama-cloud provider; the harness re-adds only that extension for `ollama-cloud/*` models.
- The JSON transcript is stored under `results/raw/` and mined for token counts and cost (`summarize.py --one`). Anthropic calls go through the local proxy on :3456, so absolute Claude costs are indicative.
- 3 runs per model x task; `summarize.py` reports medians.

## Implementer benchmark (`bench/`)

Each task is an "approved plan" (`plan.md`) the model must implement in `files/`; `check.sh` decides pass/fail objectively (provided tests, or zero-diff for the adversarial case).

| task | what it probes |
|---|---|
| `python-median` | small pure function against provided tests |
| `ts-duration` | TS function with boundary and error cases |
| `shell-wordfreq` | write a bash script from a spec |
| `adversarial-config` | the plan describes code that does not exist; pass = stop and report, zero file changes |

Run: `./run_all.sh`, then `python3 summarize.py`.

## Reviewer benchmark (`bench/review/`)

Each task is a git repo built on the fly: `base/` is committed, `changed/` is copied on top as the uncommitted working diff — exactly the scope both reviewer prompts define. The model plays taste reviewer or spec reviewer (picked from the task name prefix) and reviews the diff.

| task | what it probes |
|---|---|
| `taste-defects` | 4 planted style defects (clever reduce-fold, speculative parameters, what-not-why comment, nested conditionals); all tests pass, so green tests must not silence the review |
| `taste-clean` | a genuinely clean diff; pass = no invented must-fix findings |
| `spec-defects` | 4 planted spec divergences against `docs/discount-spec.md` (wrong boundary, discount applied to shipping, missing ValueError, unrequested coupon feature); the test suite agrees with the wrong code |
| `spec-clean` | every spec line traces to code and test; pass = says so |

Scoring is not string matching: `judge.py` sends the review plus the task's `expected.md` ground truth to a judge model (`anthropic/claude-fable-5`, deliberately not a contestant) which returns which planted defects were found and how many must-fix false positives the review invented. Judge verdicts land next to the raw transcripts (`*.judge.json`) for spot-checking.

Run: `./run_all.sh`, then `python3 summarize.py`.

## Caveats

- Small tasks: differences in code quality between passing runs are near zero here; these benchmarks discriminate on behavior (stopping on a bad plan, not inventing findings), cost, and latency, not on deep code quality.
- LLM-judge scoring is approximate. Spot-check `*.judge.json` against `*.review.md` before trusting a surprising number.
- "Clean" false positives are judged against the planted ground truth; a reviewer that finds a real issue we did not plant gets penalized. Check the review text before holding it against the model.
