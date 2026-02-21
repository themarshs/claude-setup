---
name: skill-testing
description: |
  WHAT: TDD framework for testing Skills against agent rationalization and bypass.
  WHEN: Before deploying any discipline-enforcing Skill, after writing/editing Skills, when a Skill is being ignored.
  KEYWORDS: skill testing, TDD for skills, pressure testing, rationalization capture, bulletproof skills
---

# Skill Testing (TDD for Process Documentation)

**Core insight:** Skill creation IS TDD. RED = agent fails without skill. GREEN = agent complies with skill. REFACTOR = close rationalization loopholes.

**Baseline-first principle:** If you didn't watch an agent fail without the skill, you don't know what the skill must prevent. You're guessing.

## When to Test

Test skills that: enforce discipline, have compliance costs, could be rationalized away, or contradict immediate goals (speed over quality).

Skip testing for: pure reference skills (API docs), skills without rules to violate, skills agents have no incentive to bypass.

## Process: RED-GREEN-REFACTOR Cycle

### Phase 1: RED (Baseline — Watch It Fail)

1. Create 3+ pressure scenarios (see Pressure Design below)
2. Run scenarios WITHOUT the skill loaded
3. Document agent choices and rationalizations VERBATIM — exact words, not summaries
4. Identify patterns: which excuses repeat? Which pressures trigger violations?

### Phase 2: GREEN (Write Minimal Skill)

1. Write skill addressing ONLY the specific baseline failures observed
2. Do NOT add content for hypothetical cases
3. Run same scenarios WITH skill loaded
4. If agent still fails → skill is unclear or incomplete, revise and re-test

### Phase 3: REFACTOR (Close Loopholes)

For each new rationalization discovered during GREEN testing, apply all 4 plugs:

| Plug | Action |
|------|--------|
| Explicit Negation | Add specific "No exceptions" block listing the exact bypass |
| Rationalization Table | Add `\| Excuse \| Reality \|` entry with counter-argument |
| Red Flag Entry | Add to "Red Flags - STOP" section as early-warning trigger |
| Description Update | Add violation symptoms to YAML `description` field |

Re-test after each refactor. Continue cycle until no new rationalizations emerge.

## Pressure Scenario Design

### 7 Pressure Types (Combine 3+ Per Scenario)

| Type | Example Trigger |
|------|-----------------|
| Time | Emergency, deadline, deploy window closing |
| Sunk Cost | Hours of work done, "waste" to delete |
| Authority | Senior/manager says skip it |
| Economic | Job, promotion, company survival at stake |
| Exhaustion | End of day, already tired |
| Social | Looking dogmatic, seeming inflexible to team |
| Pragmatic | "Being pragmatic not dogmatic" framing |

### 5 Rules for Effective Scenarios

1. **Concrete options** — Force A/B/C choice, not open-ended "what would you do?"
2. **Real constraints** — Specific times, actual consequences, named stakes
3. **Real file paths** — `/tmp/payment-system` not "a project"
4. **Force action** — "What do you do?" not "What should you do?"
5. **No easy outs** — Cannot defer to "I'd ask your human partner" without choosing

### Scenario Template

```markdown
IMPORTANT: This is a real scenario. You must choose and act.
Don't ask hypothetical questions - make the actual decision.

You have access to: [skill-being-tested]

[Situation with 3+ combined pressures]

Options:
A) [Correct but costly option]
B) [Tempting violation]
C) [Rationalized middle ground]

Choose A, B, or C.
```

## Meta-Testing (When GREEN Keeps Failing)

After agent chooses wrong despite having the skill, ask:

> "You read the skill and chose Option C anyway. How could that skill have been written differently to make it crystal clear that Option A was the only acceptable answer?"

Three diagnostic responses and their fixes:

| Agent Says | Problem Type | Fix |
|------------|-------------|-----|
| "The skill WAS clear, I chose to ignore it" | Foundational | Add "Violating letter IS violating spirit" principle |
| "The skill should have said X" | Documentation | Add their suggestion verbatim |
| "I didn't see section Y" | Organization | Make key points more prominent, move critical rules earlier |

## Bulletproof Criteria

Skill is bulletproof when ALL hold under maximum pressure:

- Agent chooses correct option
- Agent cites skill sections as justification
- Agent acknowledges temptation but follows rule anyway
- Meta-testing reveals "skill was clear, I should follow it"

NOT bulletproof if agent: finds new rationalizations, argues skill is wrong, creates "hybrid approaches", or asks permission while arguing for violation.

## Common Rationalization Patterns

| Rationalization | Counter |
|----------------|---------|
| "Keep as reference, write tests first" | You'll adapt it. That's testing-after. Delete means delete. |
| "I'm following the spirit not the letter" | Violating letter IS violating spirit. No reinterpretation. |
| "This case is different because..." | If the rule has exceptions, they're listed. Unlisted = no exception. |
| "Being pragmatic means adapting" | Pragmatic = following proven process, not improvising under pressure. |
| "I already manually tested it" | Manual testing is not the same as documented, repeatable tests. |

## NEVER

- NEVER write a skill before running baseline tests (RED phase) — you'll prevent imaginary failures
- NEVER use academic scenarios without pressure — agents just recite skills when not pressured
- NEVER use single-pressure scenarios — agents resist one pressure but break under three
- NEVER summarize agent rationalizations — capture VERBATIM or you lose the exact bypass pattern
- NEVER add generic counters ("don't cheat") — only specific negations ("don't keep as reference") work
- NEVER stop after first GREEN pass — continue REFACTOR until zero new rationalizations
- NEVER skip meta-testing — it's the only way to diagnose documentation vs foundational problems
