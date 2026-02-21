# 文档纪律

## What to Document

- Public API: parameters, return types, error conditions, usage example.
- Architecture decisions: use ADRs (date, status, context, decision, consequences) in `docs/adr/`.
- Configuration: all options, defaults, environment variables.
- Non-obvious behavior: edge cases, gotchas, workarounds.

## What NOT to Document

- Obvious code (getters, setters, simple wrappers, self-descriptive functions).
- Implementation details that change frequently — they rot immediately.
- Anything the type system already expresses. `function getUser(id: string): User` needs no "returns a User" comment.
- Temporary workarounds without a tracking issue.

## Keep Docs in Sync

- Update docs in the **same PR** that changes the code. No separate "update docs" PR later.
- Stale docs are worse than no docs. Review docs during code review.
- Use CI to verify doc examples compile/run where possible.

## Comment Principles

- Explain **why**, not what. The code already says what.
- One line above the code, not inline trailing comments.
- JSDoc/docstrings for public APIs only. Internal functions rarely need them.
- TODOs must include a tracking issue: `// TODO(#123): migrate to v2 API`.

## Anti-Patterns

- Do not write docs to hit a coverage metric. Document what matters, skip what doesn't.
- Do not duplicate information across README, CLAUDE.md, and inline comments. Single source of truth.
- Do not document intent to document ("this section will be updated later").
