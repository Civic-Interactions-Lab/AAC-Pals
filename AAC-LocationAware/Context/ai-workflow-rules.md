# AI Workflow Rules

## Approach

Build this app incrementally, one feature at a time. Context files define what to build, how to build it, and current progress. Always implement against these specs — do not invent behavior not described here. When in doubt, add an open question to `progress-tracker.md` before writing code.

## Scoping Rules

- Work on one feature unit at a time (e.g. word grid display, beacon detection, admin room CRUD)
- Prefer small, verifiable increments over large changes that touch multiple layers
- Do not combine unrelated features in a single implementation step

## When to Split Work

Split an implementation step if it combines:

- UI changes and service/backend changes
- Multiple unrelated screens or features
- Behavior not clearly defined in the context files

If a change cannot be verified on the iPad simulator quickly, the scope is too broad — split it.

## Handling Missing Requirements

- Do not invent product behavior not defined in the context files
- If a requirement is ambiguous, resolve it in the relevant context file before implementing
- If a requirement is missing, add it as an open question in `progress-tracker.md`

## Protected Files

Do not modify unless explicitly instructed:

- `context/` — all files in this folder are source of truth; update them, never delete them
- Supabase schema SQL files

## Keeping Docs in Sync

Update the relevant context file whenever implementation changes:

- System architecture or folder structure → `architecture.md`
- UI decisions → `ui-context.md`
- Code conventions → `code-standards.md`
- Feature progress → `progress-tracker.md`

## Before Moving to the Next Feature

1. The feature works end to end in the iPad simulator
2. No invariant defined in `architecture.md` was violated
3. `progress-tracker.md` reflects the completed work
4. The project builds without warnings
