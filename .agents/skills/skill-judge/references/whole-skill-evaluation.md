# Whole-Skill Evaluation — 8 维度评分框架

> 当 SKILL.md 路由到 Mode 1 时加载此文件

## Evaluation Protocol

### Step 1: Knowledge Delta Scan

Read SKILL.md completely, for each section ask: "Does Claude already know this?"

Mark each section:
- **[E] Expert**: Claude genuinely doesn't know — value-add
- **[A] Activation**: Claude knows but reminder useful — acceptable
- **[R] Redundant**: Claude definitely knows — should delete

Calculate ratio:
- Good: >70% E, <20% A, <10% R
- Mediocre: 40-70% E, high A
- Bad: <40% E, high R

### Step 2: Structure Analysis

```
[ ] Check frontmatter validity (name + description)
[ ] Count total lines
[ ] List reference files and sizes
[ ] Identify pattern (Mindset/Navigation/Philosophy/Process/Tool)
[ ] Check loading triggers (if references exist)
```

### Step 3: Score Each Dimension

---

#### D1: Knowledge Delta (20 points) — THE CORE DIMENSION

| Score | Criteria |
|-------|----------|
| 0-5 | Explains basics Claude knows |
| 6-10 | Mixed: some expert, diluted by obvious |
| 11-15 | Mostly expert, minimal redundancy |
| 16-20 | Pure knowledge delta — every paragraph earns its tokens |

**Red flags** (instant ≤5): "What is X" sections, standard library tutorials, generic best practices
**Green flags**: Decision trees, expert-only trade-offs, "NEVER X because [non-obvious]"

---

#### D2: Mindset + Procedures (15 points)

| Score | Criteria |
|-------|----------|
| 0-3 | Only generic procedures |
| 4-7 | Domain procedures but no thinking frameworks |
| 8-11 | Good balance of both |
| 12-15 | Expert: shapes thinking AND provides unknown procedures |

**Valuable**: "Before X, ask yourself..." / Non-obvious ordering / Easy-to-miss steps
**Redundant**: Generic file ops / Standard patterns / Well-documented library usage

---

#### D3: Anti-Pattern Quality (15 points)

| Score | Criteria |
|-------|----------|
| 0-3 | No anti-patterns |
| 4-7 | Generic warnings ("be careful") |
| 8-11 | Specific NEVER list with some reasoning |
| 12-15 | Expert-grade with WHY — things only experience teaches |

**Test**: Would an expert say "yes, I learned this the hard way"?

---

#### D4: Specification Compliance (15 points)

| Score | Criteria |
|-------|----------|
| 0-5 | Missing frontmatter |
| 6-10 | Frontmatter but vague description |
| 11-13 | Description has WHAT but weak WHEN |
| 14-15 | Perfect: WHAT + WHEN + KEYWORDS |

**Description is THE MOST CRITICAL FIELD**:
```
User Request → Agent sees ALL descriptions → Decides which to activate
               (only descriptions!)
Poor description = Skill NEVER gets loaded = useless content
```

Description checklist:
- [ ] Specific capabilities (not "helps with X")
- [ ] Explicit trigger scenarios ("Use when...")
- [ ] Searchable keywords (file extensions, domain terms)
- [ ] MUST-use scenarios (not just "can be used")

---

#### D5: Progressive Disclosure (15 points)

Three layers:
```
Layer 1: Metadata (always in memory) — name + description, ~100 tokens
Layer 2: SKILL.md Body (loaded on trigger) — ideal < 500 lines
Layer 3: References (loaded on demand) — no limit
```

| Score | Criteria |
|-------|----------|
| 0-5 | Everything in SKILL.md (>500 lines) |
| 6-10 | Has references, unclear when to load |
| 11-13 | Good layering with MANDATORY triggers |
| 14-15 | Decision trees + triggers + "Do NOT Load" guidance |

---

#### D6: Freedom Calibration (15 points)

| Task Type | Should Have | Why |
|-----------|-------------|-----|
| Creative | High freedom | Multiple valid approaches |
| Code review | Medium freedom | Principles + judgment |
| File format ops | Low freedom | One wrong byte = corruption |

| Score | Criteria |
|-------|----------|
| 0-5 | Severely mismatched |
| 6-10 | Partially appropriate |
| 11-13 | Good calibration |
| 14-15 | Perfect match throughout |

**Test**: "If Agent makes a mistake, what's the consequence?" High → Low freedom.

---

#### D7: Pattern Recognition (10 points)

5 patterns from 17+ official Skills:

| Pattern | ~Lines | When to Use |
|---------|--------|-------------|
| Mindset | ~50 | Creative tasks requiring taste |
| Navigation | ~30 | Multiple distinct sub-scenarios |
| Philosophy | ~150 | Art/creation requiring originality |
| Process | ~200 | Complex multi-step projects |
| Tool | ~300 | Precise operations on specific formats |

| Score | Criteria |
|-------|----------|
| 0-3 | No recognizable pattern |
| 4-6 | Partial with significant deviations |
| 7-8 | Clear with minor deviations |
| 9-10 | Masterful application |

---

#### D8: Practical Usability (15 points)

| Score | Criteria |
|-------|----------|
| 0-5 | Confusing, incomplete, contradictory |
| 6-10 | Usable with gaps |
| 11-13 | Clear for common cases |
| 14-15 | Comprehensive including edge cases |

Check: Decision trees? Working examples? Fallbacks? Edge cases? Immediate actionability?

---

### Step 4: Calculate & Grade

```
Total = D1 + D2 + D3 + D4 + D5 + D6 + D7 + D8 (max 120)
```

| Grade | % | Meaning |
|-------|---|---------|
| A | 90%+ (108+) | Production-ready |
| B | 80-89% (96-107) | Minor improvements |
| C | 70-79% (84-95) | Clear improvement path |
| D | 60-69% (72-83) | Significant issues |
| F | <60% (<72) | Fundamental redesign needed |

### Step 5: Report

```markdown
# Skill Evaluation Report: [Name]

## Summary
- **Total Score**: X/120 (X%)
- **Grade**: [A-F]
- **Pattern**: [type]
- **Knowledge Ratio**: E:A:R = X:Y:Z
- **Verdict**: [one sentence]

## Dimension Scores
| Dimension | Score | Max | Notes |
|-----------|-------|-----|-------|
| D1-D8... |

## Critical Issues
[must-fix]

## Top 3 Improvements
1. [highest impact]
2. [second]
3. [third]
```

---

## Common Failure Patterns

| # | Name | Symptom | Fix |
|---|------|---------|-----|
| 1 | Tutorial | Explains basics | Delete, focus on expert decisions |
| 2 | Dump | 800+ lines | Split: core in SKILL.md, details in references/ |
| 3 | Orphan References | References never loaded | Add MANDATORY triggers + "Do NOT Load" |
| 4 | Checkbox Procedure | Step 1, 2, 3... mechanical | Transform to "Before X, ask yourself..." |
| 5 | Vague Warning | "Be careful" | Specific NEVER + concrete reasons |
| 6 | Invisible Skill | Great content, never activates | Fix description: WHAT + WHEN + KEYWORDS |
| 7 | Wrong Location | "When to use" in body not description | Move triggers to description |
| 8 | Over-Engineered | README, CHANGELOG, CONTRIBUTING | Delete auxiliary files |
| 9 | Freedom Mismatch | Rigid scripts for creative tasks | Match freedom to fragility |

## NEVER When Evaluating

- NEVER give high scores for professional formatting alone
- NEVER ignore token waste
- NEVER let length impress you (43 lines can beat 500)
- NEVER skip mentally testing decision trees
- NEVER forgive basics with "helpful context"
- NEVER overlook missing NEVER lists
- NEVER assume all procedures are valuable
- NEVER undervalue description field
