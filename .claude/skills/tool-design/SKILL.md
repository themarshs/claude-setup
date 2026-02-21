---
name: tool-design
description: "Design effective tools for AI agents. Consolidation principle (merge ambiguous tools), architectural reduction (generic > specialized), description engineering, error message design, and MCP naming conventions. Use when creating MCP tools, designing Skill interfaces, building CLI commands, or optimizing agent-tool contracts."
---

## Consolidation Principle

If a human engineer cannot definitively say which tool to use in a given situation, an agent cannot do better. This is the fundamental test.

**When to consolidate (merge):**
- Two tools overlap in >30% of use cases
- Users/agents regularly call the wrong one of a pair
- The tools share the same input data shape
- Chaining A->B is the only way either is useful

**When to keep separate:**
- Fundamentally different side effects (read vs write vs delete)
- Used in completely different contexts (never co-occur)
- One is called independently, the other is not
- Safety boundaries require isolation (destructive ops stay separate)

**Example:** `list_users` + `list_events` + `create_event` -> consolidate into `schedule_event` that handles the full workflow internally. The agent should not need to chain 3 calls for one intent.

## Architectural Reduction

Fewer tools > more tools. Each tool in the collection competes for attention. Each description consumes context tokens. Overlapping functionality creates routing ambiguity.

**Guidelines:**
- 10-20 tools for most applications. Beyond 20, use namespacing.
- Before adding a new tool, ask: can an existing tool handle this with a parameter?
- Prefer primitive, general-purpose tools over specialized wrappers.
- Are your tools enabling new capabilities, or constraining reasoning the model could handle alone?
- Build minimal architectures that benefit from model improvements rather than locking in current limitations.

**Reduction fails when:**
- Underlying data is messy, inconsistent, or poorly documented
- Domain requires specialized knowledge the model lacks
- Safety constraints require limiting what the agent can do

## Description Engineering

Tool descriptions ARE prompt engineering. They are loaded into agent context and steer behavior.

**Every description must answer 4 questions:**

| Question | Bad | Good |
|----------|-----|------|
| **What** does it do? | "Search the database" | "Retrieve customer records by ID, email, or name with optional field filtering" |
| **When** to use it? | (missing) | "Use when: user asks about customer details, need customer context for decisions, verifying identity" |
| **What inputs?** | `query: string` | `customer_id: string (format CUST-######), format: "concise" or "detailed" (default: concise)` |
| **What returns?** | (missing) | "Returns customer object. Concise: name, email, status. Detailed: full record with history." |

**Rules:**
- Front-load the verb: "Retrieve...", "Create...", "Analyze..."
- Include parameter defaults in the description, not just the schema
- Specify error conditions: "Returns NOT_FOUND if ID does not exist"
- 40-80 words for the top-level description. Details go in parameter descriptions.

## Error Message Design

Error messages serve two audiences: developers debugging and agents recovering. For agents, every error must be actionable.

**Error message template:**
```
[ERROR_CODE]: What went wrong.
Expected: what the tool expected.
Received: what it got.
Fix: how to correct the call.
```

**Examples:**

```
INVALID_FORMAT: customer_id must match pattern CUST-######.
Expected: CUST-000001
Received: 000001
Fix: Prepend "CUST-" to the numeric ID.
```

```
RATE_LIMITED: Too many requests (limit: 10/min).
Fix: Retry after 60 seconds, or reduce batch size.
```

**Principles:**
- Retryable errors: include retry guidance (delay, backoff).
- Input errors: include corrected format or valid values.
- Missing data: state exactly what is needed.
- Never expose internal stack traces, file paths, or version numbers to the agent.

## MCP Naming Conventions

**Format:** `ServerName:tool_name` (fully qualified)

```
# Correct
BigQuery:bigquery_schema
GitHub:create_issue

# Wrong -- fails with multiple servers
bigquery_schema
create_issue
```

**Tool name pattern:** `verb_noun` (snake_case)
- `get_customer`, `create_issue`, `search_code`, `delete_file`
- Consistent verbs: `get` (single), `list` (multiple), `search` (query-based), `create`, `update`, `delete`
- Same noun = same entity across tools: if one tool says `customer_id`, all tools say `customer_id`, not `user_id` or `client_id`

**Namespace grouping:**
- Group related tools under a common server/prefix
- Agent routes to namespace first, then selects tool within it
- Reduces selection complexity from O(n) to O(k) + O(n/k)

## Response Format Optimization

Implement format options to control token consumption:

- **concise**: essential fields only (confirmations, basic lookups)
- **detailed**: complete objects (decisions requiring full context)

Include guidance in descriptions: "Use concise for confirmation, detailed for analysis."

## Anti-Patterns (NEVER)

- NEVER use vague names: `search`, `process`, `handle`, `do_thing`
- NEVER use cryptic parameter names: `x`, `val`, `param1`, `q`
- NEVER return generic errors: "Something went wrong" gives zero recovery signal
- NEVER use inconsistent naming across tools: `id` here, `identifier` there, `customer_id` elsewhere
- NEVER build tools to "protect" the model from complexity -- these guardrails become liabilities as models improve
- NEVER bundle unrelated operations into one tool just to reduce count
- NEVER omit return type documentation -- agents cannot interpret what they cannot predict
- NEVER add a tool without testing it with actual agent interactions first
- NEVER assume tool descriptions are "just docs" -- they are the highest-leverage prompt in the system
