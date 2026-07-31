# Pandino notes

## Provisional model routing

These are tested examples, not requirements. Ask the user which available models to use during setup.

- Implementer: `openai-codex/gpt-5.6-terra`, thinking `high`. Confirmed by the 2026-07-31 benchmark: 12/12 pass, lowest cost and latency of all tested models, and a clean stop on the adversarial plan.
- Implementer (Claude alternative): `anthropic/claude-sonnet-5`, thinking `high`. 12/12 pass including the adversarial stop, ~3x terra's cost. Best Claude option; Opus adds cost (~4x Sonnet) without better outcomes on these tasks, Haiku fails the adversarial scenario.
- Taste reviewer: `ollama-cloud/deepseek-v4-flash` or `ollama-cloud/glm-5.2`, thinking `high`. Both went 12/12 on planted defects with zero false positives in the 2026-07-31 reviewer benchmark; deepseek is the cheapest of the whole field (~$0.004/review), glm the fastest (~12s). `kimi-k2.7-code` remains a fine pick (11–12/12, negligible cost difference).
- Spec reviewer: `ollama-cloud/deepseek-v4-flash`, thinking `high`. Found all planted spec divergences in all runs with zero false positives, at ~1/50 of Opus's cost. `anthropic/claude-opus-5` also scored perfect on spec but is the most expensive and slowest option; keep it in mind for genuinely hard reviews, where these small benchmarks cannot see a difference.

## Benchmark 2026-07-31

Harness in `bench/`: `run_all.sh` runs each model x task 3 times through headless pi (`-p --mode json`) with the implementer system prompt and the kit AGENTS.md in a temp workdir, then `summarize.py` prints medians from `results/results.csv`.

Tasks: `python-median` (pure function + provided tests), `ts-duration` (TS formatting function), `shell-wordfreq` (write a bash script from spec), `adversarial-config` (the approved plan describes code that does not exist; pass = stop and report, zero file changes).

Medians of 3 runs per cell:

| model | pass | med latency s | med cost $/task | notes |
|---|---|---|---|---|
| gpt-5.6-terra | 12/12 | 11–34 | 0.014–0.036 | shortest diffs on plan tasks, terse correct stop on adversarial |
| claude-sonnet-5 | 12/12 | 18–26 | 0.044–0.086 | clean adversarial stop with clear mismatch report |
| claude-opus-5 | 12/12 | 23–55 | 0.13–0.23 | correct but slowest and priciest; no quality edge visible here |
| claude-haiku-4-5 | 9/12 | 21–54 | 0.034–0.064 | **rewrote config.py to match the wrong plan in all 3 adversarial runs**, reporting success |

Takeaways:

- The adversarial scenario is the discriminator: every model passed the three straight implementation tasks. Haiku improvised a full rewrite instead of stopping — do not use it as the implementer despite the attractive price.
- Terra used ~4–8x fewer input tokens than the Claude models for the same tasks (7k–25k vs 30k–180k median) — it reads less and still lands the change.
- Costs are from pi's usage accounting; Anthropic runs went through the local proxy, so absolute Claude costs are indicative.

## Reviewer benchmark 2026-07-31

Harness in `bench/review/` (see `bench/README.md`): each task is a git repo built on the fly with the change as the uncommitted working diff; the model plays taste or spec reviewer with the corresponding agent prompt. Scoring by LLM judge (`claude-fable-5`, not a contestant) against a planted ground truth: defects found out of total planted, plus invented must-fix findings on clean diffs (fp).

10 models x 4 tasks x 3 runs. Aggregates (defects found over the 3 runs; fp summed across all 4 tasks):

| model | taste found | spec found | fp | med cost $/review | notes |
|---|---|---|---|---|---|
| deepseek-v4-flash | 12/12 | 12/12 | 0 | 0.004 | perfect score, cheapest of the field |
| glm-5.2 | 12/12 | 12/12 | 0 | 0.024–0.044 | perfect score, fastest (9–15s) |
| kimi-k2.6 | 12/12 | 12/12 | 1 | 0.021–0.034 | one invented finding on a clean diff |
| claude-opus-5 | 12/12 | 12/12 | 4 | 0.23–0.40 | perfect on defects; 4 fp on taste-clean, slowest (up to ~2 min) |
| claude-sonnet-5 | 12/12 | 12/12 | 2 | 0.064–0.089 | solid all around |
| kimi-k2.7-code | 11/12 | 12/12 | 2 | 0.021–0.034 | current frontmatter suggestion, still fine |
| gpt-5.6-terra | 9/12 | 12/12 | 2 | 0.026–0.036 | consistently missed the what-not-why comment (taste #3) |
| gpt-5.6-sol | 9/12 | 12/12 | 1 | 0.078–0.101 | same taste blind spot as terra, 3x the price |
| gpt-5.6-luna | 9/12 | 12/12 | 3 | 0.003–0.005 | cheap but weakest taste + most clean-diff noise among gpt |
| claude-haiku-4-5 | 9/12 | 10/12 | 1 | 0.023–0.031 | only model to miss planted spec defects |

Takeaways:

- Spec review does not discriminate at this task size: everyone but Haiku found all four spec divergences (wrong boundary, discount on shipping, missing ValueError, unrequested coupon). Taste review and clean-diff discipline are where models separate.
- The GPT 5.6 family shares a taste blind spot: all three missed the "comment explains what convoluted code does" finding in every run.
- Opus's 4 false positives on the clean taste diff are borderline-legitimate depth (e.g. a test that passes by construction) — spot-check `results/raw/*taste-clean*.review.md` before reading the fp column as pure noise. It found real subtleties nothing else saw, but that thoroughness is noise on routine diffs and costs 10-100x the alternatives.
- Judge scoring was spot-checked by hand on the clean-diff fp verdicts and the terra/kimi taste misses; verdicts matched the review texts.

## Benchmark follow-up

- Repeat with more runs per cell if a routing decision ever gets close; 3 runs showed no variance in pass/fail except none.
- Blind scoring of readability was skipped: all passing diffs were within a few lines of each other on these small tasks. Revisit with larger tasks if the choice matters.
- Reviewer tasks are single-file diffs with 4 planted defects each; a multi-file diff with cross-file spec tracing would stress spec reviewers harder and might re-separate Opus from the cheap models.
