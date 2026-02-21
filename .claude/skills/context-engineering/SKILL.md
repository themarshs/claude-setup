---
name: context-engineering
description: "Manage context health in long agent sessions. Detect context degradation patterns (Lost-in-Middle, Context Poisoning, Context Distraction, Context Confusion, Context Clash), apply compression strategies (anchored iterative summary, opaque compression, regenerative full summary), and optimize tokens-per-task efficiency. Use when sessions exceed 50% context, when output quality degrades, when preparing for compaction, or when managing multi-agent context isolation."
---

# Context Engineering

## 5 Degradation Patterns: Signals & Mitigations

### 1. Lost-in-Middle
- **Signal**: Agent ignores instructions/facts placed mid-context; U-shaped recall — strong at edges, weak in center; 10-40% lower recall accuracy for mid-positioned information.
- **Mitigate**: Place critical info at context start or end. Use explicit section headers as attention anchors. Surface key findings in summary blocks at edges after long tool outputs.

### 2. Context Poisoning
- **Signal**: Output quality degrades on previously-passing tasks; tool calls use wrong parameters; hallucinations persist despite correction; agent references facts that were never true.
- **Mitigate**: Truncate context to before poisoning point. Write explicit correction to MEMORY.md. In severe cases: compact and restart with only verified state from MEMORY.md. Never let unvalidated tool output persist unchallenged.

### 3. Context Distraction
- **Signal**: Agent over-attends to irrelevant retrieved docs; responses drift from task; a single irrelevant document measurably reduces performance (step-function, not proportional).
- **Mitigate**: Filter retrieved content for relevance before injecting. Prefer tool-call access over pre-loading. Namespace context sections so structural boundaries help the model skip irrelevant blocks.

### 4. Context Confusion
- **Signal**: Responses address wrong aspect of query; tool calls appropriate for a different task; output mixes requirements from multiple sources; task-switching within a session produces bleed.
- **Mitigate**: Isolate tasks into separate agent invocations. Use explicit `## CURRENT TASK` headers. Clear transition markers between task phases. Partition via sub-agents for unrelated work.

### 5. Context Clash
- **Signal**: Agent oscillates between contradictory approaches; reasoning contains "but earlier we said X" loops; multi-source retrieval yields conflicting guidance.
- **Mitigate**: Mark conflicts explicitly with `[CONFLICT]` tags. Establish source priority rules (latest > oldest, user > retrieved). Filter outdated versions before they enter context.

## Compression Strategy Decision Tree

```
Context at 70%+ utilization?
├─ YES: What dominates context?
│   ├─ Tool outputs (80%+ of tokens) → Observation Masking
│   │   Replace verbose outputs with: [Obs:{ref} Key: {extracted_finding}]
│   │   Never mask: current-turn outputs, outputs in active reasoning
│   │
│   ├─ Message history → Anchored Iterative Summarization
│   │   Summarize ONLY newly-truncated span, merge into existing summary
│   │   Structured sections: Intent / Files Modified / Decisions / State / Next
│   │   Quality: 3.70/5.0 at 98.6% compression — best for coding sessions
│   │
│   ├─ Retrieved documents → Regenerative Summary or Partition
│   │   Clear phase boundaries? → Regenerative Full Summary (3.44/5.0, 98.7%)
│   │   No clear phases? → Sub-agent partitioning (isolate retrieval context)
│   │
│   └─ Mixed → Layer strategies: mask first, then compact history
│
└─ NO but approaching 50% → Pre-emptive: write key state to MEMORY.md now
```

**When to use Opaque Compression**: Only when max token savings required AND re-fetching cost is near-zero. Yields 99.3% compression but lowest quality (3.35/5.0) and zero verifiability.

## Tokens-Per-Task Optimization

The correct metric is **tokens-per-task** (total tokens from task start to completion), NOT tokens-per-request.

| Principle | Rationale |
|-----------|-----------|
| Compress late, not early | Premature compression forces re-fetching, increasing total cost |
| Preserve file paths and error messages verbatim | These are the #1 re-fetch trigger when lost |
| Prefer structured summary over aggressive truncation | 0.7% more tokens buys 0.35 quality points |
| Budget allocation: system prompt > recent turns > tool output > old history | Compress in reverse priority order |
| Trigger compaction at 70-80%, not at limit | Compacting under pressure produces worse summaries |
| Never compress system prompt | It anchors all subsequent reasoning |

**Three-Phase Workflow for Large Tasks** (5M+ token codebases):
1. **Research**: Explore architecture → produce single structured research doc
2. **Plan**: Convert research → implementation spec (~2,000 words for 5M tokens)
3. **Execute**: Work against spec, not raw codebase — context stays focused

## Artifact Trail: The Weakest Link

Artifact trail integrity scores 2.2-2.5/5.0 across ALL compression methods. File tracking degrades fastest.

**Required countermeasures**:
- Maintain a dedicated `## Files Modified` section in every compaction summary
- Track: created / modified (what changed) / read-only / deleted
- Preserve function names, variable names, error messages verbatim — never paraphrase
- On compaction, cross-check file list against git status before finalizing summary
- Consider a separate artifact index outside the main conversation flow

**Structured summary template** (use in compaction hooks):
```markdown
## Session Intent
[One sentence: what the user is trying to accomplish]

## Files Modified
- path/to/file.ts: What changed and why
- path/to/test.ts: Added/updated which tests

## Decisions Made
- Decision X: chosen option and reasoning (1 line each)

## Current State
- Test status, build status, blocking issues

## Next Steps
1. Immediate next action
2. Subsequent actions (max 3)
```

## Integration with MEMORY.md + Compact Hooks

| Trigger | Action |
|---------|--------|
| Context hits 50% | Write current Intent + Files + Decisions to MEMORY.md proactively |
| Pre-compact hook fires | Generate structured summary using template above; write to MEMORY.md |
| Post-compact / new session | First action: silent-read MEMORY.md to restore state (per CLAUDE.md boot protocol) |
| Task boundary reached | Commit, then compact — clean summaries at logical boundaries |
| Sub-agent returns | Mask full output; extract key findings into parent context |

**MEMORY.md is the artifact trail backup**. Compaction loses file tracking; MEMORY.md preserves it across compactions. Always write MEMORY.md BEFORE triggering compact.

**Probe after compaction**: Ask yourself 4 questions to verify compression quality:
1. Recall: "What was the original error/goal?"
2. Artifact: "Which files have I modified?"
3. Continuation: "What should I do next?"
4. Decision: "What did I decide about [key choice]?"

If any answer feels uncertain → re-read MEMORY.md or source files immediately.

## NEVER

- Never compress the system prompt or CLAUDE.md instructions
- Never trust that compacted context preserved file paths — verify against MEMORY.md
- Never keep unvalidated tool output in context across compaction boundaries
- Never load irrelevant documents "just in case" — each distractor has step-function cost
- Never compact under extreme context pressure (>95%) — quality crashes; if here, partition instead
- Never assume larger context = better results — degradation is non-linear and onset is unpredictable
- Never paraphrase error messages, function names, or paths in summaries — preserve verbatim or lose them
- Never mix multiple unrelated tasks in one context without explicit isolation headers
