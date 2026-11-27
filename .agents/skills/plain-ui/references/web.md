# Web rules

Apply these rules when the platform is web. They paraphrase the parts of Vercel's [Web Interface Guidelines](https://vercel.com/design/guidelines) that hold in any framework; read the source for the full list.

## Forms

- Every control MUST have a `<label>` that focuses it when clicked.
- Inputs MUST set the matching `type`, `inputmode`, `name`, and `autocomplete` so keyboards and autofill work.
- Enter MUST submit a form from a text input. In a `<textarea>`, Enter adds a line and Ctrl or Cmd with Enter submits.
- Keep the submit button enabled until the request starts, then disable it and show progress with the label still visible.
- Show each error beside its field, and move focus to the first error on submit.
- Warn before navigation discards unsaved input.
- NEVER block paste, and NEVER reject keystrokes silently. Accept the input and explain what is wrong.
- Input text SHOULD be at least 16 px on mobile, which stops iOS Safari from zooming on focus.

## Focus and keyboard

- Every flow MUST work with the keyboard alone.
- Every focusable element MUST show a focus ring on keyboard focus. Use `:focus-visible`.
- A dialog or menu MUST trap focus while open and return it to its trigger on close.
- An icon-only button MUST have an `aria-label`.
- Use native elements (`button`, `a`, `label`, `table`) before ARIA roles.
- Announce toasts and inline validation through a polite `aria-live` region.
- NEVER disable browser zoom.

## Links and buttons

- Navigation MUST be an `<a>` with an `href`, so open-in-new-tab and middle click work.
- An action MUST be a `<button>`. NEVER attach a click handler to a `<div>` or `<span>`.
- A destructive action MUST ask for confirmation or offer undo.
- A label that opens a further step SHOULD end with an ellipsis, as in "Rename…".

## States

- Hover, active, and focus states MUST have more contrast than the resting state.
- A disabled control MUST look disabled and use the `disabled` attribute.
- The whole visible area of a control MUST respond to clicks.
- Filters, tabs, pagination, and open panels SHOULD live in the URL, so reload, share, and Back keep them.
- Delay a spinner by about 150 ms and then keep it for at least 300 ms, so fast responses do not flicker.

## Responsive layout

- Check each screen at phone, laptop, and very wide widths.
- Lay out with flex, grid, and intrinsic sizes before measuring in JavaScript.
- Very long and very short user content MUST wrap or truncate without breaking the layout.
- Respect safe-area insets on devices with notches.
- A horizontal scrollbar on the page is a bug.

## Perceived performance

- Images MUST have explicit dimensions, so loading them does not shift the layout.
- A skeleton MUST have the size and shape of the content that replaces it.
- Animate `transform` and `opacity` only, and name the properties. NEVER write `transition: all`.
- Wrap motion in a `prefers-reduced-motion` check.
- Virtualize lists of several hundred rows or more.
- Lazy-load images below the first screen.
