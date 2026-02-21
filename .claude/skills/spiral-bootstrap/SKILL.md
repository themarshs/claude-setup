---
name: spiral-bootstrap
description: |
  WHAT: Double-helix evolution orchestrator with L1-L4 graded response. Detects retrieval pain signals, routes to minimal-cost healing actions, enforces methodology binding after every evolution event.
  WHEN: Any retrieval friction detected (repeated queries, empty results, stale caches, user complaints). Runs as background triage for all search-related activity.
  KEYWORDS: evolution, bootstrap, pain, retrieval improvement, self-improvement, spiral, L1-L4, pain-ledger, stale-cache, overnight-plan
---

# Spiral Bootstrap — Double-Helix Evolution Orchestrator

> Core constraint: evolution has cost. Grade the response. Never sacrifice current work for self-improvement.

## The Bootstrap Paradox

Retrieval improvement depends on retrieval itself. Solution — two helices:
- **Helix 1 (Data)**: distill knowledge structures with dumb tools, reduce retrieval difficulty
- **Helix 2 (Tool)**: use code generation to forge new retrieval tools

Both helices advance in lockstep, each lowering the bar for the other.

## L1-L4 Graded Response Decision Tree

```
PAIN SIGNAL DETECTED
    │
    ├─ Sporadic tool friction (1-2 retries)
    │   → L1 IMMUNE: silent bookkeeping
    │     Hook appends to .claude/.search_history
    │     Cost: 0 tokens | Timing: real-time background, invisible
    │
    ├─ Single significant waste (>3 retries) OR [STALE] tag encountered
    │   → L2 SCAB: data reduction + methodology micro-patch
    │     1. Purify fragments → write to ARCHITECTURE_MAP.md (section-level)
    │     2. Update retrieval-methodology SKILL.md routing rules (MANDATORY)
    │     Cost: ~2,000 tokens | Timing: inline, as fallback breakthrough
    │
    ├─ Same pain class >= 3 occurrences (pain_ledger alert)
    │   → L3 MUTATION: tool forging (async)
    │     1. File evolution ticket → overnight-plan.md
    │     2. Trigger skill-creator + tdd-workflow in isolated /evolve session
    │     3. Rewrite methodology routing (MANDATORY)
    │     Cost: ~50,000 tokens | Timing: separate session (Context Purity)
    │
    └─ Entire retrieval channel failure
        → L4 RECOMBINATION: diagnostic report + user authorization
          1. Generate failure diagnostic (affected channels, blast radius, evidence)
          2. Present to user with options
          Cost: extreme | Timing: after explicit user approval only
```

## Pain Signal Detection Table

| Signal | Detection Method | Pain Level |
|--------|-----------------|------------|
| Same query repeated 3+ times | Hook sliding window (.search_history) | L2 |
| Search returns empty/very short 3+ times | Hook checks response length | L2 |
| pain_ledger same-class count >= 3 | Agent scans on startup | L3 |
| User says "wrong/missed/redo" | System prompt iron law | Highest → file ticket immediately |
| ARCHITECTURE_MAP section has [STALE] | Agent detects on read | L2 |
| Tool timeout/crash on search call | Hook captures exit code | L1 (first), L2 (repeat) |
| retrieval-methodology route leads to dead end | Post-search outcome check | L2 |

## Methodology Binding Rules (MANDATORY)

After every successful L2 or L3 execution, you MUST update `retrieval-methodology/SKILL.md`:

```
Rule N: When searching [domain], use [action], never [old method]. Source: L[2/3] [date]
```

Failure to update routing = task FAILED. This is non-negotiable — the焊死 principle.

## STALE Cache Invalidation

ARCHITECTURE_MAP.md sections carry source annotations:
```html
<!-- sources: file1.py, file2.ts -->
```

When dirty-tracker detects changes in listed files → append `[STALE]` to that section header.
Agent sees `[STALE]` → trigger L2 section-level update (~1,000 tokens).
Only section-level staleness — never whole-file (prevents cache avalanche).

## overnight-plan.md Ticket Format

```markdown
## Evolution Ticket #N
- **Pain point**: [concrete description from pain_ledger]
- **Pain level**: L3
- **Cumulative count**: [read from pain_ledger]
- **Expected artifact**: [Skill / Tool / Index update]
- **Constraints**: [no external services / must run local / etc]
- **Collaborators**: skill-creator, tdd-workflow, skill-judge
- **Status**: PENDING | IN_PROGRESS | DONE | REJECTED
```

## Execution Protocol

### L1 Flow
```
Hook fires → append {query, tool, timestamp, retries} to .claude/.search_history → done
```

### L2 Flow
```
Pain detected → read ARCHITECTURE_MAP.md target section
  → purify & rewrite section (remove [STALE])
  → append routing rule to retrieval-methodology/SKILL.md
  → log resolution to pain_ledger
```

### L3 Flow
```
pain_ledger alert (count >= 3) → draft evolution ticket
  → write to overnight-plan.md (Status: PENDING)
  → DO NOT execute in current session
  → in /evolve session: skill-creator forges → tdd-workflow validates
  → skill-judge scores → Delta Gate check vs ARMORY
  → if PASS: install + update retrieval-methodology + update ARMORY.md
```

### L4 Flow
```
Channel failure detected → generate diagnostic report
  → list affected queries, channels, blast radius
  → present report to user → WAIT for authorization
  → user approves → execute recovery plan
```

## Weapon Collaboration Map

| Collaborator | Role in Spiral Bootstrap |
|-------------|--------------------------|
| knowledge-evolution | Receives L2/L3 outcomes as instinct candidates for confidence tracking |
| skill-creator | L3 executor — forges new Skills from evolution tickets |
| tdd-workflow | L3 validator — red-green-refactor for forged Skills |
| retrieval-methodology | MANDATORY update target after every L2/L3 success |
| skill-judge | L3 gatekeeper — scores forged Skills for Delta Gate entry |

## NEVER

- NEVER trigger any LLM reflection at L1 (zero-cost principle)
- NEVER execute L3 tool-forging during current task (Context Purity principle)
- NEVER skip methodology update after L2/L3 success (焊死 principle)
- NEVER let Agent self-judge "am I inefficient" (use physical signals, not subjective judgment)
- NEVER mark whole-file as STALE (section-level only, prevent cache avalanche)
- NEVER load current task context during L3 forging (prevent coupling)
- NEVER trigger more than 1 L3 per session (budget ceiling)
- NEVER take autonomous action at L4 without user authorization
- NEVER count the same query instance toward multiple pain classes simultaneously
- NEVER delete pain_ledger entries — archive them with resolution status
