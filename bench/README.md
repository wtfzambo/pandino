# Pandino model benchmarks

Measures which models fit Pandino agent roles on this machine through headless Pi. Results feed routing suggestions in [`NOTES.md`](../NOTES.md).

## How it works

Every run is one headless Pi invocation, isolated from the local setup:

```
pi -p --no-session --no-extensions --no-skills --mode json \
   --model <model> --thinking <level> \
   --append-system-prompt <role-prompt> "<task prompt>"
```

- The role prompt is the agent's markdown from `agents/`, frontmatter stripped. `bench/review/prompts/test.md` is the deterministic copy of `agents/test-reviewer.md`; regenerate it with `awk '/^---$/{n++; next} n>=2' agents/test-reviewer.md > bench/review/prompts/test.md`. `run_one.sh` refuses a test run when the copy differs.
- The task runs in a temp workdir seeded with the task's files plus the kit `AGENTS.md`, so the model sees the same context a real Pandino repo gives it.
- `--no-extensions` keeps the environment clean but also unloads the ollama-cloud provider; the harness re-adds only that extension for `ollama-cloud/*` models.
- The JSON transcript is stored under `results/raw/` and mined for token counts and cost (`summarize.py --one`).
- Nothing here configures providers: the harness inherits whatever pi's own provider setup resolves for each model ID. Runs work on any machine where `pi -p --model <id>` works. (On the machine of the 2026-07-31 runs, pi routed `anthropic/*` through a local proxy, so absolute Claude costs from those runs are indicative.)
- Finalist model, thinking-level, and task configurations run three times; `summarize.py` reports medians.

## Implementer benchmark (`bench/implementer/`)

Each task is an "approved plan" (`plan.md`) the model must implement in `files/`; `check.sh` decides pass/fail objectively (provided tests, or zero-diff for the adversarial case).

| task | what it probes |
|---|---|
| `python-median` | small pure function against provided tests |
| `ts-duration` | TS function with boundary and error cases |
| `shell-wordfreq` | write a bash script from a spec |
| `adversarial-config` | the plan describes code that does not exist; pass = stop and report, zero file changes |

Run: `./run_all.sh`, then `python3 summarize.py`.

The code each run produced is reconstructed from the transcripts by `extract_artifacts.py` into `results/artifacts/<model>/<task>_rN/` (only files that differ from the task originals). Each reconstruction is re-validated with the task's `check.sh`; a run whose replay cannot reproduce the recorded result (e.g. it mutated files via bash, which is not re-executed) gets an `INCOMPLETE.md` marker.

## Reviewer benchmark (`bench/review/`)

Each task is a git repo built on the fly: `base/` is committed, `changed/` is copied on top as the uncommitted working diff — exactly the scope the reviewer prompt defines. The task-name prefix selects `taste`, `spec`, or `test`.

| task | what it probes |
|---|---|
| `taste-defects` | 4 planted style defects (clever reduce-fold, speculative parameters, what-not-why comment, nested conditionals); all tests pass, so green tests must not silence the review |
| `taste-clean` | a genuinely clean diff; pass = no invented must-fix findings |
| `spec-defects` | 4 planted spec divergences against `docs/discount-spec.md` (wrong boundary, discount applied to shipping, missing ValueError, unrequested coupon feature); the test suite agrees with the wrong code |
| `spec-clean` | every spec line traces to code and test; pass = says so |
| `test-defects` | all five must-fix gaps: missing 429 coverage, a Bash `!` assertion neutralized by `set -e`, an implementation-derived oracle, an invented provider fixture, and missing negative `schedule_retry` coverage; plus two minor excess groups |
| `test-integration` | valid, proportionate integration coverage at a stable checkout cut point using coarse boundary fakes |
| `test-no-test` | documentation-only clarification that legitimately needs no automated test |
| `test-python-defects` | five must-fix gaps in member-price boundaries, independent totals, invalid-input errors, returned booking IDs, and successful save-before-send ordering; plus two minor excess groups |
| `test-python-clean` | independent Python booking totals, invalid-input/no-side-effect, and confirmation-ID/order evidence with no necessary findings |
| `test-typescript-defects` | five must-fix gaps in bulk boundaries, independent totals, invalid-input errors, persisted transaction IDs, and returned order IDs; plus two minor excess groups |
| `test-typescript-clean` | independent TypeScript order totals, invalid-input/no-side-effect, and async boundary/ID evidence with no necessary findings |

Scoring is not string matching: `judge.py` sends the review plus the task's `expected.md` ground truth to a judge model (`anthropic/claude-fable-5` by default, `BENCH_JUDGE_MODEL` to override; pick one that is not a contestant). It records must-fix defects found, minor excess found, and false positives; older tasks without severity headings treat all numbered defects as must-fix. Judge verdicts land next to the raw transcripts (`*.judge.json`) for manual spot-checking. The automatic judge is advisory: Fable language judging repeatedly returned HTTP 429, no substitute was used, and [`results/manual-audit.md`](review/results/manual-audit.md) is the final authority.

`./run_all.sh` is the prescribed initial original-task screen: all twelve test-review candidates, `test-defects`, `test-integration`, and `test-no-test`, one run each at `high`. It removes previous `role=test` rows before the screen but preserves the historical taste/spec rows. Do not use it as a blind repeated matrix. Run language screens and finalist repeats directly with `./run_one.sh <model> <task> <run> <thinking>` after inspecting verdicts; repeat only configurations whose results can change routing until each finalist task combination has three total runs. The raw filename and CSV include the thinking level, and `python3 summarize.py` groups by model, thinking level, and task. The Python language tasks' `base/run_tests.sh` direct runners use `python3 -m pytest -q`; the TypeScript ones use `node --test orders.test.ts`.

Current `role=test` CSV scores are manually audited; automatic judge output is advisory, and future `run_all.sh` screens may add automatic scores pending audit.

Run the initial screen with `./run_all.sh`, then `python3 summarize.py`. Before paid runs, mutation-audit the oracle. If a reviewer exposes a genuine fixture gap, correct the fixture and rerun stale contestant artifacts rather than scoring the finding as noise.

## Caveats

- Small tasks: differences in code quality between passing runs are near zero here; these benchmarks discriminate on behavior (stopping on a bad plan, not inventing findings), cost, and latency, not on deep code quality.
- LLM-judge scoring is approximate. Spot-check `*.judge.json` against `*.review.md` before trusting a surprising number.
- "Clean" false positives are judged against the planted ground truth; a reviewer that finds a real issue we did not plant gets penalized. Check the review text before holding it against the model.
