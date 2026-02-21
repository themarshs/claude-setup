---
name: knowledge-evolution
description: Hooks-driven instinct learning framework. Turns spiral iteration experience into atomic instincts with confidence decay, clustering into Rules/Skills/Agents.
version: 2.0.0
---

# Knowledge Evolution Framework

> Meta-review phase of Spiral SOP. Deterministic observation + atomic instincts + confidence decay.

## Activation

- Spiral SOP enters meta-review phase
- Recurring patterns need crystallization
- Existing knowledge staleness check required

## Observation Architecture (Hooks, not Skills)

Skills fire ~50-80% probabilistically. Hooks fire 100% deterministically.

```
PreToolUse / PostToolUse Hooks
      │
      │  append every tool call + outcome
      ▼
observations.jsonl  (rotate: 10MB max, archive after 7 days)
      │
      │  pattern detection (4 categories)
      ▼
┌─ user_corrections    → instinct (confidence 0.5, direct signal)
├─ error_resolutions   → instinct (confidence 0.3, needs validation)
├─ repeated_workflows  → instinct (confidence 0.5, frequency-based)
└─ tool_preferences    → instinct (confidence 0.4, behavioral signal)
```

### Hook Configuration (settings.json)

```json
{
  "hooks": {
    "PreToolUse": [{ "matcher": "*", "hooks": [{
      "type": "command",
      "command": "<observer-script> pre"
    }]}],
    "PostToolUse": [{ "matcher": "*", "hooks": [{
      "type": "command",
      "command": "<observer-script> post"
    }]}]
  }
}
```

## Atomic Instinct Model

One trigger, one action. Smallest knowledge unit.

```yaml
id: <kebab-case-id>
trigger: "when [specific scenario]"
action: "do [specific action]"
confidence: <0.3 - 0.9>
domain: <niche-tag>  # code-style | testing | search | architecture | workflow
source: <origin>     # spiral-observation | user-correction | hook-detection | inherited
evidence:
  - <observation 1>
  - <observation 2>
created: <ISO 8601>
last_validated: <ISO 8601>
```

### Source Layering

| Layer | Path | Description |
|-------|------|-------------|
| personal | `instincts/personal/` | Self-learned from observation |
| inherited | `instincts/inherited/` | Imported from other users/projects |

Inherited instincts start at confidence 0.5 (not auto-approved), must earn trust locally.

## Confidence System

| Score | Meaning | Behavior |
|-------|---------|----------|
| 0.3 | Tentative | Record only, never auto-apply |
| 0.5 | Moderate | Suggest when relevant, don't enforce |
| 0.7 | Strong | Auto-apply, no confirmation needed |
| 0.9 | Core | Promote to `.claude/rules/`, becomes discipline |

### Confidence Dynamics (decay_rate: 0.05/round)

**Growth** (+0.1 per event, cap 0.9):
- Same pattern confirmed across different spiral rounds
- User does not correct the behavior
- Cross-validated by independent sources

**Decay** (automatic, continuous):
- Not triggered for N consecutive rounds: -0.05/round
- User explicit correction: drop to 0.3 immediately
- Contradicting evidence: -0.2

**Elimination**: confidence < 0.3 → move to `archive/deprecated-instincts/`

## Evolution Path

```
Single instinct
    │  same domain accumulates >= 3 related instincts
    ▼
Instinct cluster
    │  cluster mean confidence >= 0.7
    ▼
Upgrade decision:
├─ Constraint/discipline → .claude/rules/   (Rule)
├─ Domain knowledge      → .claude/skills/  (Skill)
└─ Multi-step orchestration → .claude/agents/ (Agent)
```

### Upgrade Thresholds

| Target | Conditions |
|--------|------------|
| Rule | >= 3 instincts, mean >= 0.7, all constraint-type |
| Skill | >= 3 instincts, mean >= 0.7, contains domain knowledge |
| Agent | >= 5 instincts, mean >= 0.7, contains multi-step orchestration |

Post-upgrade: tag source instincts with `evolved_into: <target-path>`.

## Meta-Review Procedure

Execute at each spiral round end:

### Step 1: Extract Instincts
Review all phases. For each pattern detected, create instinct via the 4 detection categories:
- Which search strategies worked/failed? (repeated_workflows)
- What did the user correct? (user_corrections)
- What errors were resolved and how? (error_resolutions)
- Which tools were preferred over alternatives? (tool_preferences)

### Step 2: Update Confidence
- Existing instinct validated this round → +0.1
- Existing instinct contradicted this round → -0.2
- Existing instinct not triggered → -0.05 (decay)

### Step 3: Cluster Check
- Scan same-domain instincts, check upgrade thresholds
- If met: produce new Rule/Skill/Agent file
- Upgraded product must still pass Delta Gate for ARMORY entry

### Step 4: Produce Diff
Must satisfy Mutation Checkpoint (CLAUDE.md ratchet 4):
- Modified CLAUDE.md / settings.json / ARMORY.md, **or**
- Annotated "capped + reason" in ARMORY.md

## Export / Import

```bash
# Export: share instincts (patterns only, no code/conversation content)
# Creates portable YAML bundle from instincts/personal/
/instinct-export → instincts-bundle.yaml

# Import: receive instincts from another user/project
# All imported instincts land in instincts/inherited/ at confidence 0.5
/instinct-import <file> → instincts/inherited/
```

## System Integration

- **ARMORY.md**: evolved Skills must pass Delta Gate to enter ARMORY
- **Highlander**: evolved products follow single-niche constraint
- **Gene Furnace**: instincts come from observation (white-box by nature)
- **Hooks**: observation hooks must be registered in settings.json, not ad-hoc

## NEVER

- NEVER create instincts without evidence (minimum 1 concrete observation)
- NEVER auto-apply instincts below confidence 0.7
- NEVER skip decay calculation during meta-review
- NEVER import inherited instincts at confidence > 0.5
- NEVER promote to rules without cluster validation (>= 3 instincts, mean >= 0.7)
- NEVER store raw conversation content in observations (patterns only)
- NEVER bypass Delta Gate for evolved products entering ARMORY
