---
name: prompt-engineering
description: "Expert prompt engineering for LLM interactions. Framework selection (CoT, CoD, RTF, RISEN, Constitutional AI), model-specific optimization (Claude/GPT/open-source), RAG prompt design, and multi-agent prompt architecture. Use when crafting system prompts, optimizing Skill descriptions, designing Agent definitions, or building LLM application prompts."
---

## Framework Selection Matrix

| Scenario | Framework | Why |
|----------|-----------|-----|
| Step-by-step reasoning, debugging, proof | **Chain of Thought (CoT)** | Forces explicit reasoning trace, +30-50% accuracy on analytical tasks |
| Summarization, compression | **Chain of Density (CoD)** | Iterative refinement to essential info, controls information density |
| Role-based expert tasks | **RTF** (Role-Task-Format) | Cleanest role definition + output format contract |
| Complex multi-phase projects | **RISEN** (Role-Instructions-Steps-End goal-Narrowing) | Full structure for deliverable-oriented work |
| System design, architecture | **RODES** (Role-Objective-Details-Examples-Sense check) | Balances detail with self-validation |
| Safety-critical, value-aligned output | **Constitutional AI** | Self-critique loop against explicit principles |
| Audience-aware communication | **RACE** (Role-Audience-Context-Expectation) | Forces audience modeling before content generation |

**Blending rules:**
- Combine 2-3 max. Primary = core task type, secondary = complexity dimension.
- Complex technical project: RODES + CoT. Leadership decision: RISEN + RACE.
- Simple tasks get simple frameworks. Over-engineering a one-liner is an anti-pattern.

## Instruction Hierarchy

```
[System Context] -> [Constraints/Rules] -> [Task Instruction] -> [Examples] -> [Input Data] -> [Output Format]
```

- System context sets identity and boundaries (persists across turns).
- Constraints before task: the model reads top-down, constraints placed after the task are weaker.
- Examples after instruction: show, don't tell. 2-5 few-shot pairs beat paragraphs of rules.
- Output format last: it's the freshest in attention when generation begins.

## Claude-Specific Optimization

**XML tags are first-class citizens.** Claude treats XML tags as structural delimiters with semantic weight:
```xml
<context>background info here</context>
<instructions>task here</instructions>
<examples>
  <example><input>X</input><output>Y</output></example>
</examples>
<output_format>expected structure</output_format>
```

**Claude quirks:**
- Prefill the assistant turn to steer format: `Assistant: {"analysis":` forces JSON.
- `<thinking>` tags enable visible reasoning without polluting output.
- Claude respects NEVER/ALWAYS lists more reliably when placed in `<rules>` tags.
- Numbered lists with explicit step labels outperform bullet lists for sequential tasks.
- Claude handles long system prompts well -- move stable instructions there, keep user messages variable.
- Avoid "be concise" (vague). Use "respond in under 100 words" (measurable).

## Description Engineering

The `description` field of a Skill/Tool/Agent IS a prompt. It is the single highest-leverage piece of text in the system.

**Structure a description to answer 3 questions:**
1. **What** -- capability in one sentence (verb-first: "Analyze...", "Generate...", "Design...")
2. **When** -- trigger conditions ("Use when...", concrete scenarios, not abstract domains)
3. **Differentiator** -- what makes this distinct from adjacent skills

**Techniques:**
- Front-load the verb. "Analyze code for security vulnerabilities" > "A skill that helps with security analysis of code."
- Include 3-5 concrete trigger phrases after "Use when" -- these are the routing signals the model pattern-matches on.
- Avoid meta-language ("This skill...", "It can..."). Speak as capability, not documentation.
- Token budget: 40-80 words. Shorter descriptions route faster. Longer descriptions add noise.

## Progressive Disclosure

Start simple, add complexity only when the simple version fails:

1. **Level 1**: Direct instruction ("Summarize this article")
2. **Level 2**: Add constraints ("Summarize in 3 bullets, focus on findings")
3. **Level 3**: Add reasoning ("Identify main findings, then summarize each in one bullet")
4. **Level 4**: Add examples (2-3 input-output pairs demonstrating desired behavior)

Most tasks are solved at Level 2. Jump to Level 4 only when consistency matters at scale.

## RAG Prompt Design

```
Given the following context:
<context>{retrieved_chunks}</context>

{few_shot_examples}

Question: {user_question}

Answer based solely on the context above. If the context is insufficient,
state exactly what information is missing. Do not hallucinate.
```

**Key principles:**
- Context before question: the model needs the reference material in attention before it sees what to do with it.
- "Based solely on the context" is mandatory -- without it, the model blends retrieval with parametric knowledge.
- Ask for explicit uncertainty signals ("state what's missing") instead of hoping it won't hallucinate.
- Add a self-verification step for production: "After answering, verify your response cites specific passages from the context."

## Multi-Agent Prompt Architecture

- Each agent gets a **role boundary** in its system prompt: what it does AND what it does NOT do.
- Handoff prompts must include: context summary, task description, constraints inherited from upstream.
- Shared vocabulary: define key terms once in a shared context doc, not per-agent.
- Avoid "be helpful" in agent system prompts -- it's noise. Define the specific help.

## Anti-Patterns (NEVER)

- NEVER explain what a prompt framework is inside the prompt. The model already knows.
- NEVER use "be creative" / "be helpful" / "be concise" as instructions. These are unmeasurable.
- NEVER put critical constraints after the input data. They will be weakly attended to.
- NEVER use more than 3 frameworks in one prompt. Blending beyond 3 creates contradictions.
- NEVER write few-shot examples that contradict the instructions. The model follows examples over rules.
- NEVER include meta-commentary in output prompts ("This prompt uses RISEN framework...").
- NEVER ask more than 3 clarifying questions per turn. Batch or prioritize.
- NEVER hardcode model-specific tricks (prefill, XML) into model-agnostic prompts.
- NEVER skip testing on edge cases. The happy path is where every prompt works.
- NEVER treat prompt engineering as a one-shot activity. Prompts are code: version, test, iterate.
