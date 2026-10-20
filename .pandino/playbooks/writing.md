# Writing

Use this playbook to write or edit documentation, specifications, decisions, README files, playbooks, or multi-line commit messages. The prose rules in `AGENTS.md` always apply.

## Pick the document's mode

One document has one mode; split other content out and link it.

| Document | Mode | Write |
|---|---|---|
| Specification | reference | Current behavior only: facts, options, limits, errors. Mirror the structure of the thing described. |
| Runbook | how-to | Steps toward one goal for a competent reader, named by the task. Forks as "If you want X, do Y". |
| Decision | explanation | Context, the choice, the alternatives, the consequences. Opinion belongs here. |
| Playbook, agent definition | how-to for an agent | Imperative steps with their trigger. Cut every sentence that is not an instruction. |
| README | orientation | What it is, how to start, links to the authoritative documents. |

## Write the sentences

- Use the real name of the symbol, file, flag, or command, in code font, and one name per thing everywhere.
- Name the actor, in active voice.
- Say the mechanism or the number. "A column rename fails the build" says something; "types that follow your schema" names a feeling. Cut a sentence that could appear unchanged in another project.
- Use the plain word, one idea per sentence, and the condition before the instruction.
- Number sequences, bullet everything else, and introduce a list with a full sentence.
- Make every count, path, and command true at the commit that lands it.
- Write a commit message or pull request as a briefing read in under a minute: why the change exists and what changes for the user. Link logs instead of pasting them.

## Check before you finish

Reread and remove:

- em dashes and colons in the middle of a sentence (a colon stays only before a list or an example);
- AI vocabulary: additionally, crucial, delve, enhance, foster, intricate, leverage, pivotal, robust, seamless, showcase, underscore, utilize;
- "serves as" or "boasts" where "is" or "has" works;
- "not just X, but Y" and ideas forced into groups of three;
- filler ("in order to", "it is important to note"), stacked hedges, and generic conclusions;
- abstract metaphors (substrate, north star, surface for an interface);
- bold on every other phrase, decorative emoji, and chatbot phrases.
