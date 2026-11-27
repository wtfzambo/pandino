---
name: plain-ui
description: Build, change, or review a user interface, such as a screen, component, form, chart, or table, and its copy. Use only when the work touches UI code, UI copy, or visual design. Offers five modes by name (distill, quieter, clarify, harden, critique).
---

# Interface design

Use this skill to build, change, or review a user interface. The project's design system, `DESIGN.md`, component library, and platform conventions override the taste in this skill.

## The central rule

Every visible element has a job. It carries information, shows what the user can do, gives feedback, or shows a state. Remove an element that has no job.

Keep these signals:

- a shadow or border that shows a button can be pressed;
- an inset field that says "type here";
- a pressed state that confirms the click;
- motion that shows where something came from or where it went.

Remove this decoration:

- decorative gradients and ornamental illustrations;
- an icon beside every heading;
- entrance animations on static content;
- badges, metrics, and testimonials nobody asked for;
- border, shadow, and background stacked on one element.

Saint-Exupéry: perfection is reached when there is nothing left to take away. Rams: good design is as little design as possible.

## Product screens and marketing pages

Decide which kind of screen you have, because the job of an element differs.

- **Product screen.** People come to do a task, often many times a day: a form, a record, a dashboard, a settings page. An element's job is a step toward that task. Illustration, mood, and brand character have no job here. This skill is written first for these screens.
- **Marketing page.** People decide whether the product is for them: a landing page, a pricing page. Showing the product and giving it a recognizable character are jobs. Keep one image that shows the product or its result, and one deliberate choice of typeface or color. The anti-patterns still apply.

## References

Open a reference only when its condition holds.

- `references/anti-patterns.md`: you touch visual details, or you review a UI.
- `references/web.md`: the platform is web.

## Context first

Know five facts before you touch a UI:

1. who uses it, and in what situation;
2. the main task they come to do;
3. the platform: web, iOS, Android, or desktop;
4. the constraints: accessibility target, languages, devices, brand;
5. the design system or component library already in use.

Read `DESIGN.md`, the specifications, the README, and the existing UI code. Treat a fact inferred from code as a guess and confirm it. Ask the user once, in one message, for the facts still missing. Record the answers in `DESIGN.md` at the repository root, and create that file with only those facts when it is missing. In a review, change no file and report a missing fact as a question.

- When the project has a design system, reuse its components and tokens before adding new ones.
- On a native platform, use the system controls and follow Apple's Human Interface Guidelines or Material 3. A mobile website, and a website inside a native wrapper, are web.
- For a new UI with no existing style, ask for a reference (a screenshot, a URL, or an existing product) before choosing a style.

## Principles

**Krug.** Users scan, pick the first plausible option, and muddle through. Make each screen obvious without explanation. A click costs nothing when the choice is obvious. Cut half the words, then half of what is left.

**Nielsen.** Check each screen against the ten heuristics:

1. The system shows its current status.
2. It speaks the user's language.
3. The user can undo and leave.
4. The same thing looks and behaves the same everywhere.
5. The design prevents errors before reporting them.
6. Options are visible, so the user recognizes them without recalling.
7. Experts have shortcuts.
8. Nothing irrelevant competes with what matters.
9. An error message says what happened and how to fix it.
10. Help exists at the point of need.

**Norman.** A control shows what it does (affordance and signifier), responds when used (feedback), and sits where its effect is (mapping). These justify tactile details such as shadows and pressed states.

**Tufte, for charts and tables.** Spend ink on data. Apply the eraser test to each mark: keep it only when erasing it loses information. Label the data directly and drop the legend. Use flat charts and only the gridlines a reader needs to read a value.

**One obvious way.** Give each screen one primary action, each task one path, and each action one control.

## Decision order

Build any screen in this order:

1. **Task.** State the user's main task on this screen in one sentence.
2. **Primary action.** Make the one primary action dominant, and keep secondary actions findable and quiet.
3. **Structure.** Build hierarchy from content order, spacing, and contrast before color, boxes, or bold.
4. **States.** Design empty, loading, error, success, disabled, very long and very short content, huge numbers, missing data, slow or failed requests, double submits, and translated text that is longer or reads right to left.
5. **Copy.** Write short labels (verbs or nouns) and errors that say how to fix the problem. Keep marketing tone out of product UI.
6. **Visual details.** Add them last, and test each against the central rule.

## Rules

These rules hold on every platform. MUST and NEVER have no exceptions; SHOULD yields to a stated reason.

- **Color.** Color MUST mean something: a state, a danger, a selection. Everything else SHOULD stay neutral. NEVER carry meaning by color alone. Pair it with text or an icon.
- **Typography.** Use few sizes, with a clear step between them. Body lines SHOULD stay near 60 to 75 characters. Numeric columns MUST use tabular figures.
- **Forms.** Labels MUST stay visible while the user types. Validation messages MUST sit beside their field. NEVER use a placeholder as the label.
- **Interaction.** Focus MUST be visible and follow reading order. When the primary action is blocked, say beside it what is missing. Touch targets MUST be at least 44 pt on iOS, 48 dp on Android, 44 px on a touch web page, and 24 px for a pointer.
- **Motion.** Motion MUST explain a change, stay short, and stop when the user acts. It MUST respect the reduced-motion setting. NEVER animate content that does not change.
- **Accessibility.** Text MUST meet the project's contrast target, WCAG AA by default. Use the platform's semantic elements before custom ones. Every control MUST have a name that assistive technology can read.

## Modes

Run a mode when the user names it. When the user invokes this skill without a request, or asks what it can do, list the five modes with one line each and ask which to run. Each one changes an existing UI, except `critique`.

- **distill.** Remove every element that fails the central rule, merge duplicate controls, and cut repeated text. Output: the edited UI and a list of what you removed and why. Stop when removing one more element would lose a function, a signal, or information the user needs.
- **quieter.** Lower the intensity of a loud UI: fewer colors, lighter weights, less motion, flatter surfaces. Output: the edited UI. Stop when the primary action is still the first thing seen and every signal still reads.
- **clarify.** Rewrite labels, messages, and errors so each says what happened and what to do next. Keep one term per concept. Output: the changed strings, before and after. Ask before changing a factual, legal, or domain term. Stop when a new user understands each string without product knowledge.
- **harden.** Design every state in step 4 of the decision order that the UI lacks. Output: the edited UI and the states covered. Stop when each of those states has a designed result.
- **critique.** Run the review procedure and change nothing. Output: the findings list.

## Review procedure

Use this procedure to review a UI change. Read the project's product rules first, so a deliberate rule is not reported as a defect. On a screen that changes with role and state, choose the role and state to review and name them in the report. Run the passes in order. Review from the code, render the UI when a tool allows it, and mark a finding you could not see rendered as inferred.

1. **Eraser pass.** List each visible element with its job, and mark it keep or remove.
2. **Krug pass.** For each screen, check that a new user knows within five seconds what it is and what to do.
3. **Nielsen pass.** Apply the ten heuristics and report only violations you can point to on a screen.
4. **States pass.** Check that every state in step 4 of the decision order has a designed result.
5. **Rules pass.** Compare the UI with the rules above, with `references/anti-patterns.md`, and on web with `references/web.md`.
6. **Break-it pass.** Feed the UI the worst input it can receive, such as a very long name, an empty list, a huge number, a slow network, or a failed request, and skip a case the screen cannot meet.

Report a short list of findings ordered by severity, each with `file:line` and the fix. Merge findings that share one fix. Leave out the element list, praise, and filler.

| Severity | Meaning |
|---|---|
| P0 | The user cannot complete the task. |
| P1 | The user completes it with real difficulty or confusion. |
| P2 | An annoyance with a workaround. |
| P3 | Polish with no effect on the task. |

A problem that would make a user contact support, or a mistake the user cannot undo, is at least P1. In a Pandino repository, a reviewer following `.pandino/playbooks/reviewing.md` keeps its report format and its definitions of `must-fix` and `minor`, and adds the P level to each finding.

## Sources

- Steve Krug, *Don't Make Me Think*.
- Jakob Nielsen, [10 Usability Heuristics for User Interface Design](https://www.nngroup.com/articles/ten-usability-heuristics/).
- Don Norman, *The Design of Everyday Things*.
- Edward Tufte, *The Visual Display of Quantitative Information*.
- Vercel, [Web Interface Guidelines](https://vercel.com/design/guidelines).
- Some modes and rules are inspired by [Impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus, Apache 2.0.
