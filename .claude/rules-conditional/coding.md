---
globs:
  - "**/*.{ts,tsx,js,jsx,py,go,rs,java,sh}"
---

# Coding Disciplines (extracted from 16 high-star repos, 67k+ stars)

## Golden Rules

- **One Task, One Chat**: mixing topics causes ~39% performance drop. Finish or commit before switching.
- **Simple > Clever**: simple code significantly outperforms complex code. Avoid inheritance or clever hacks when composition or plain functions suffice.
- **Explore → Plan → Code → Commit**: never jump straight to coding. Understand first, plan second, implement third.
- **Surgical changes**: change the minimum necessary. Fixing 1 file doesn't mean refactoring 5. Scope creep in patches is the #1 cause of regressions.
- **File size**: 200-400 lines typical, 800 max. Split by function/domain, not by type.
- **Subtask sizing**: keep each subtask completable within 50% of remaining context. Compact proactively at 50%.
- **Commit often**: as soon as a task is completed, commit. Small atomic commits > large batches.

## Testing Discipline

- Write failing tests BEFORE implementation (TDD red-green-refactor).
- The one thing you cannot outsource is verifying the code actually works. Always run it.
- Comprehensive logging so agents can read logs and self-diagnose failures.

## Context Efficiency

- CLAUDE.md ≤ 50 lines — use `@imports` and `.claude/rules/*.md` for overflow.
- Provide `examples/` folder when teaching patterns — AI performs much better with visible examples.
- For libraries released after training cutoff, provide recent examples or use context7.

## Architecture Pattern

- Three-tier: **Command** (user entry `/slash`) → **Agent** (orchestration `.claude/agents/`) → **Skill** (knowledge `.claude/skills/`)
- State persistence: use files (state.json, MEMORY.md) not ephemeral context for cross-command data.
