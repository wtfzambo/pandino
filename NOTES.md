# Pandino notes

## Provisional model routing

These are tested examples, not requirements. Ask the user which available models to use during setup.

- Implementer: `openai-codex/gpt-5.6-terra`, thinking `high`. It produced the shortest precise solution in the first shell-task benchmark. The current user-reported cost is roughly one fifth of GPT-5.6 Sol.
- Taste reviewer: `ollama-cloud/kimi-k2.7-code`, thinking `high`.
- Spec reviewer: `anthropic/claude-opus-5`, thinking `high`.

## Benchmark follow-up

- Test the implementer with the available Claude models after the current rate limit resets.
- Add an adversarial scenario where the approved plan contradicts the real code; verify that the implementer stops and reports the mismatch instead of improvising.
- Run a broader comparison across representative Python, TypeScript, and shell tasks rather than drawing conclusions from one installer test.
- Repeat each scenario enough times to expose run-to-run variance.
- Compare correctness, scope discipline, readability, latency, token usage, and actual cost using the same prompts and blind scoring where practical.
- Revisit the frontmatter suggestions when that evidence is available.
