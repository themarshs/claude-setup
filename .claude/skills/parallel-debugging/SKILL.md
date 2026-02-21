---
name: parallel-debugging
description: "Systematic multi-hypothesis debugging using Analysis of Competing Hypotheses (ACH). Spawn parallel investigation agents for each fault hypothesis, collect evidence with strength grading, and arbitrate root cause through structured comparison. Use when facing complex bugs with multiple possible causes, when linear debugging (3-Strike) hits Strike 2+, or when debugging distributed/async systems."
---

# Parallel Debugging

## Entry Conditions

- Bug has multiple plausible root causes
- 3-Strike protocol (error-discipline.md) reached Strike 2 without resolution
- Issue spans multiple modules, services, or async boundaries
- Need to avoid confirmation bias in debugging

## 6 Fault Hypothesis Categories

Generate at least one hypothesis from each applicable category:

### 1. Logic Error
Incorrect conditionals, off-by-one, missing edge cases, wrong algorithm.

### 2. Data Issue
Type mismatch, null/undefined where value expected, encoding/serialization,
data truncation, invalid input passing validation.

### 3. State Problem
Race condition, stale cache, incorrect initialization, unintended shared-state
mutation, state machine transition error.

### 4. Integration Failure
API contract violation, version incompatibility, config mismatch between
environments, missing env vars, network timeout.

### 5. Resource Issue
Memory leak, connection pool exhaustion, file descriptor leak, disk quota
exceeded, CPU saturation from inefficient processing.

### 6. Environment
Missing runtime dependency, wrong library version, platform-specific behavior,
permission/access control issue, timezone/locale difference.

## Evidence Strength Grading

| Type             | Strength | Example                                              |
|------------------|----------|------------------------------------------------------|
| **Direct**       | Strong   | Code at `file.ts:42` shows `>` should be `>=`        |
| **Correlational**| Medium   | Error rate spiked after commit `abc123`               |
| **Testimonial**  | Weak     | "It works on my machine"                              |
| **Absence**      | Variable | No null check found in the entire code path           |

Always cite evidence with `file:line` references. No uncited claims.

## Confidence Gradient

| Level              | Criteria                                                        |
|--------------------|-----------------------------------------------------------------|
| **High (>80%)**    | Multiple direct evidence, clear causal chain, no contradictions |
| **Medium (50-80%)**| Some direct evidence, plausible chain, minor ambiguities        |
| **Low (<50%)**     | Mostly correlational, incomplete chain, contradicting evidence  |

## Arbitration Protocol (4 Steps)

### Step 1: Categorize
Each hypothesis gets one label:
- **Confirmed** — High confidence, strong evidence, clear causal chain
- **Plausible** — Medium confidence, some evidence, reasonable chain
- **Falsified** — Evidence directly contradicts the hypothesis
- **Inconclusive** — Insufficient evidence to confirm or falsify

### Step 2: Rank Confirmed Hypotheses
If multiple confirmed, rank by:
1. Confidence level (highest first)
2. Number of Direct evidence pieces
3. Strength of causal chain
4. Absence of contradicting evidence

### Step 3: Determine Root Cause
- Single dominant hypothesis → declare root cause
- Multiple equally likely → compound issue (multiple contributing causes)
- No hypotheses confirmed → generate new hypotheses from gathered evidence

### Step 4: Validate Fix
- [ ] Fix addresses identified root cause
- [ ] Fix does not introduce new issues (run full test suite)
- [ ] Original reproduction case no longer fails
- [ ] Related edge cases covered
- [ ] Regression test added

## Integration with 3-Strike Protocol

| Strike | Action                                                      |
|--------|-------------------------------------------------------------|
| 1      | Standard: diagnose + targeted fix (stay in error-discipline)|
| 2      | **Fork**: if fix fails, switch to parallel-debugging        |
| 2→ACH  | Generate hypotheses across 6 categories, spawn investigators|
| 3      | If ACH also inconclusive, escalate to user with full report |

Switching trigger: when Strike 2 fix fails, do NOT attempt Strike 3 blindly.
Instead, generate the hypothesis matrix and run parallel investigations.

## Investigation Agent Template

Each investigator receives:
```
Hypothesis: [specific hypothesis statement]
Category: [one of 6 categories]
Scope: [files/modules to investigate]
Task: Collect evidence FOR and AGAINST this hypothesis.
      Cite every finding with file:line. Grade evidence strength.
      Return verdict: Confirmed / Plausible / Falsified / Inconclusive.
```

## NEVER

- NEVER pursue a single hypothesis without considering alternatives
- NEVER skip evidence citation (file:line is mandatory)
- NEVER declare root cause with only Correlational/Testimonial evidence
- NEVER modify code during investigation phase (read-only until arbitration)
- NEVER continue past Strike 3 without escalating to user
- NEVER let confirmation bias drive — actively seek disconfirming evidence
