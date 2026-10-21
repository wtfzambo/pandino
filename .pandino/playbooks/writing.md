# Writing

Use this playbook to write or edit documentation, specifications, decisions, README files, playbooks, or multi-line commit messages. The prose rules in `AGENTS.md` always apply.

## Pick the document's mode

One document has one mode; move other content to its own document and link it.

| Document | Mode | Write |
|---|---|---|
| Specification | reference | Current promises only: behavior, options, limits, errors. Mirror the structure of the thing described. |
| Runbook | how-to | Steps toward one goal for a competent reader, named by the task. Forks as "If you want X, do Y". |
| Decision | explanation | Context, the choice, the alternatives, the consequences. Opinion belongs here. |
| Playbook, agent definition | how-to for an agent | Imperative steps with their trigger. Every sentence is an instruction. |
| README | orientation | What it is, how to start, links to the authoritative documents. |

## Shape it for a reader in a hurry

- Make the first line say what the document is for, or the first action to take.
- Start with the content and end when it is done: the first sentence carries information, and the last one is the final step or fact.
- Number multi-step work. Each step is one action, and the list has the fewest steps that still work.
- Give quantities and times in concrete units ("about 15 minutes", "three files").
- Write a problem as its cause and its fix.
- Put a side topic in its own section or document and link it.
- Use headings that let a reader scan back to a point.

## Write the sentences

- Use the real name of the symbol, file, flag, or command, in code font, and one name per thing everywhere.
- Name the actor, in active voice.
- Say the mechanism or the number. "A column rename fails the build" says something; "types that follow your schema" names a feeling. Cut a sentence that could appear unchanged in another project.
- Use the plain word, one idea per sentence, and the condition before the instruction.
- Introduce a list with a full sentence, and keep its items parallel.
- Make every count, path, and command true at the commit that lands it.
- Write a commit message or pull request as a briefing read in under a minute: why the change exists and what changes for the user. Link logs instead of pasting them.

## Check before you finish

Reread and rewrite:

- em dashes, as a period or a comma;
- colons in the middle of a sentence, as two sentences (a colon stays before a list or an example);
- AI vocabulary (additionally, crucial, delve, enhance, foster, intricate, leverage, pivotal, robust, seamless, showcase, underscore, utilize), as the plain word;
- "serves as" or "boasts", as "is" or "has";
- "not just X, but Y", ideas forced into groups of three, and filler ("in order to", "it is important to note"), as the direct statement;
- stacked hedges, as one hedge that carries real uncertainty;
- abstract metaphors (substrate, north star, surface for an interface), as the concrete word;
- bold on every other phrase, decorative emoji, and chatbot phrases, by deleting them.

Then read only the first and the last line. A reader should know what the document is for and what to do next.
