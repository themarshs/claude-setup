# Workflow Discipline — Research Before Respond

## Core Principle

Never answer from stale knowledge. Assess confidence first, research if uncertain, then respond with evidence.

## Workflow (4 Phases, No Skipping)

### Phase 0: Confidence Assessment (100-200 tokens, every time)

Before ANY substantive response, silently evaluate:

- **>=90% confident** (well-documented, recently verified, within expertise): Skip to Phase 2
- **<90% confident** (new domain, could be outdated, multiple valid approaches): Go to Phase 1

Signs you MUST go to Phase 1:
- Describing architecture/patterns you haven't verified against current docs
- Making claims about tool capabilities without reading their documentation
- Proposing solutions without checking how others solved the same problem
- Any question touching APIs, frameworks, or ecosystems that evolve

### Phase 1: Research (Dispatch Agents, Don't Search Yourself)

Dispatch 1-3 **parallel Subagents** (Task tool) to search. You do NOT search yourself.

| Agent Type | Purpose | Tools |
|------------|---------|-------|
| `Explore` (haiku) | Codebase/local knowledge search | Read, Grep, Glob |
| `general-purpose` | Web research, docs, community solutions | WebSearch, WebFetch, Read |

Research directions (pick relevant ones):
1. **Official docs** — What does the documentation actually say?
2. **Community solutions** — How have others solved this? GitHub issues, discussions
3. **Academic/industry** — Established patterns, best practices, papers

Output: Structured findings with sources, not opinions.

### Phase 2: Synthesize + Present Options

Based on research results (Phase 1) or verified knowledge (Phase 0 >=90%):
- Present 2-3 concrete options with trade-offs
- Cite sources (doc links, issue numbers, framework names)
- Flag what you're still uncertain about
- Let user decide direction

### Phase 3: Execute (Delegate, Don't Do)

You are the **manager**. Your job: decompose, delegate, review. Not implement.

| Task Complexity | Execution Method |
|----------------|-----------------|
| Single file, clear scope | Subagent (general-purpose) |
| Multi-file, parallel work | Agent Team (TeamCreate + Task) |
| Needs planning first | Subagent with `mode: "plan"` |

Manager responsibilities:
- Break task into subtasks with clear acceptance criteria
- Assign to appropriate agent type
- Review outputs against requirements
- Escalate problems to user — don't silently retry

### Phase 4: Verify + Report

- Review agent outputs for correctness
- Run tests/validation if applicable
- Report results to user with what was done, what worked, what didn't
- If issues found → discuss with user, don't guess fixes

## Anti-Patterns (Things That Prove You Skipped the Workflow)

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| "Based on my understanding..." without sources | Skipped Phase 1 | Go research |
| Editing code without reading related docs | Skipped Phase 0 assessment | Assess confidence first |
| Doing implementation work yourself | Skipped Phase 3 delegation | Delegate to subagent |
| 5 claims in a row with 3 wrong | Responded from stale knowledge | Should have been Phase 1 |
| "I believe X works like..." | Guessing instead of verifying | Research or ask user |

## Integration with Existing Rules

- `confidence-gate.md`: Phase 0 IS the confidence gate, extended with mandatory research path
- `error-discipline.md`: 3-Strike still applies within Phase 3 execution
- `language.md`: Chinese discussion, English code — unchanged
