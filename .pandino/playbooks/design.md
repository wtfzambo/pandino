# Design

Use this playbook to design new modules, public interfaces, or types that cross a module boundary, and to check any code against the rules in `AGENTS.md`.

## Sketch new structure before code

1. Write two or three real call sites first, as they will read in the codebase. Derive the types from that usage.
2. Sketch the domain types, signatures, and module map with bodies that raise "not implemented". A reader should trace data from input to output through the signatures alone.
3. Trace the main access patterns through the types. A pattern that needs an index or cache "added later" means the structure is wrong now.
4. Screen the sketch against the red flags below and revise it.
5. Put the sketch in the plan, so the user sees the shape before implementation starts.

## Red flags in any code

- **Cleverer than the problem**: bit tricks, dense expressions, exotic control flow. Write the plain version.
- **Pass-through**: a layer that forwards its arguments unchanged. If deleting it removes complexity, delete it.
- **Single-use abstraction**: an interface, base class, factory, or helper with one trivial caller. Inline it.
- **Speculative generality**: parameters nothing passes, hooks nothing uses, configuration nobody asked for. Delete them.
- **Shallow module**: callers coordinate several calls to finish one operation. Move the coordination behind one call.
- **Split ownership**: two modules write the same state or keep copies of it. Give it one named owner.
- **Two ways to do one task**: keep one, move its callers, delete the other in the same change.
- **Hand-synced lists**: keep one list and derive the others.
- **Leaking boundaries**: wire formats, storage schemas, or framework objects past the edge. Parse them into domain types there.
- **Hidden side effects**: I/O, clock, randomness, or mutation inside business logic. Move them to the boundary.
- **Deep nesting**: three levels, or a happy path hidden in branches. Use guard clauses.
- **Comment as excuse**: a comment explaining a workaround, or a suppression in our own code. Fix the cause.
