---
name: evolution-session
description: |
  Independent evolution session executor — the "night shift" of the double-helix mechanism.
  Reads overnight-plan.md work orders, forges tools from pain ledger signals, and binds results
  into retrieval-methodology routing. Pure L3 toolmaking in a clean context.
  KEYWORDS: evolve, evolution, overnight, nightly, forge, L3, pain ledger, work order, toolmaking
---

# Evolution Session — L3 Night Shift Executor

> Standalone session for tool forging. No user business tasks. Pure evolution.

## Prerequisites

- `overnight-plan.md` exists with PENDING work orders
- `pain_ledger.jsonl` contains pain signals referenced by work orders
- Clean session context (no business task contamination)

## Process (6 phases, strict order)

### Phase 1: LOAD

1. Read `overnight-plan.md`, collect all work orders with status `PENDING`
2. If zero PENDING orders: output "No work orders. Session complete." and stop
3. Cap at 3 orders maximum per session (prevent context overload)

### Phase 2: TRIAGE

1. Sort PENDING orders by: pain_level DESC, cumulative_count DESC
2. Select top N (max 3) highest-priority orders
3. Log selected orders with rationale

### Phase 3: FORGE (per work order)

For each selected work order, execute sequentially:

#### 3a. Understand Pain
- Read `pain_ledger.jsonl` entries matching the work order's pain_id
- Summarize: what hurts, how often, what workarounds exist

#### 3b. Search Community (retrieval-methodology routing)
- Load `retrieval-methodology` to determine optimal search channels
- `mcp__distillery__search` — check community Skill/Rule/Agent inventory
- `hunt` Skill — scan GitHub for emerging solutions
- Cross-validate results per retrieval-methodology protocol

#### 3c. Decide Strategy
| Signal | Strategy |
|--------|----------|
| Community asset scores > 80 | Distill: extract essence via skill-judge Mode 2 |
| Community asset scores 60-80 | Hybrid: extract patterns, build custom Skill |
| No viable community asset | Build: forge from scratch via skill-creator |
| Existing tool upgradeable | Upgrade: enhance current tool in-place |

#### 3d. Execute
- **Distill/Hybrid**: skill-judge Mode 2 (element dissection) on candidate, extract essence, feed to skill-creator
- **Build**: skill-creator with pain context + search findings as input
- **Upgrade**: edit existing SKILL.md, preserve backward compatibility
- All artifacts: zero external dependencies (self-contained)

#### 3e. Judge (Delta Gate — mandatory)
1. Run skill-judge Mode 1 on the forged artifact
2. Compare score against ARMORY.md same-niche current highest
3. **New score must be strictly greater** — equal or lower = destroy artifact
4. Failed artifact: log reason, mark work order `BLOCKED`, move to next

#### 3f. Test (tdd-workflow — mandatory)
1. Run tdd-workflow validation on the forged artifact
2. Skill-type artifacts: run skill-testing pressure scenarios
3. Failed tests: iterate fix (max 2 attempts), then mark `BLOCKED`

### Phase 4: BIND

For each successfully forged artifact:
1. Read `retrieval-methodology` SKILL.md
2. Add routing entry: intent signal -> new tool channel
3. Verify no orphan routes (every route points to existing tool)

### Phase 5: REGISTER

1. Update ARMORY.md:
   - Add new tool to active weapons table (niche, name, type, score, usage, trigger)
   - If replacing: delete old entry (Highlander rule)
   - If new niche: add to active + remove from unfilled niches
2. Verify ARMORY.md integrity (no duplicate niches, no dangling references)

### Phase 6: CLOSE

1. Update `overnight-plan.md`: mark completed orders `DONE`, blocked orders `BLOCKED`
2. Update `MEMORY.md` with session outcomes
3. Output session briefing:

```
## Evolution Session Briefing
- Orders processed: N/M
- Forged: [list with scores]
- Blocked: [list with reasons]
- Routes added: [list]
- Next priority: [top remaining PENDING order, if any]
```

## Collaborating Weapons

| Weapon | Role in This Session |
|--------|---------------------|
| retrieval-methodology | Route search intent to optimal channel |
| distillery-search | Search 2,100+ community assets |
| hunt | GitHub-wide progressive search |
| skill-creator | Forge new Skills from pain context |
| skill-judge | Score artifacts (Mode 1) + dissect community assets (Mode 2) |
| tdd-workflow | Validate forged artifacts |
| skill-testing | Pressure-test discipline-enforcing Skills |

## NEVER

- NEVER skip skill-judge scoring (Delta Gate is inviolable)
- NEVER process user business tasks (pure evolution, no work)
- NEVER process more than 3 work orders per session (context overload prevention)
- NEVER skip retrieval-methodology route update (welded closure)
- NEVER install tools that haven't passed sandbox audit
- NEVER forge tools with external dependencies (zero-dependency principle)
- NEVER accept equal or lower scores at Delta Gate (strictly greater only)
- NEVER modify ARMORY.md without passing both judge and test phases
