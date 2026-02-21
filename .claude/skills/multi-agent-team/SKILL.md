---
name: multi-agent-team
description: "Multi-agent team orchestration and parallel dispatching. File ownership partitioning, staged pipeline (plan->prd->exec->verify->fix), inter-agent messaging, worktree isolation, and parallel agent dispatch patterns. Use when tasks can be parallelized across agents, when coordinating multi-file changes, when dispatching independent sub-tasks, or when setting up team-based development workflows."
---

# Multi-Agent Team Orchestration

## Parallel vs Serial Decision Tree

```
Task arrives
  |
  +-- Can subtasks run independently? (no shared files, no data dependency)
  |     YES --> Are there 3+ independent domains?
  |               YES --> Parallel dispatch (one agent per domain)
  |               NO  --> 2 agents parallel if truly independent, else serial
  |     NO  --> Do subtasks have a clear dependency chain?
  |               YES --> Serial pipeline (plan->exec->verify)
  |               NO  --> Decompose further until dependencies are explicit
  |
  +-- Will agents edit the same files?
        YES --> Serial OR use git worktree isolation
        NO  --> Safe to parallelize
```

**Parallelize when:** 3+ test files failing with different root causes, multiple subsystems broken independently, each problem self-contained without shared state.

**Serialize when:** failures are related (fix one might fix others), agents would edit the same files, need full system state understanding, exploratory debugging with unknown scope.

## Agent Prompt Structure

Every agent prompt MUST be: **Focused + Self-contained + Specific output**.

```markdown
## Template

[ROLE] You are a worker assigned to [SPECIFIC DOMAIN].

[SCOPE] Fix/implement [EXACT FILES OR MODULE]. Do NOT touch anything outside this scope.

[CONTEXT]
- Error messages / test names / relevant code snippets
- Inherited constraints from upstream stages
- File ownership boundaries (which files this agent owns)

[CONSTRAINTS]
- Do NOT modify files outside your ownership partition
- Do NOT spawn sub-agents or use Task tool
- Use absolute file paths only

[OUTPUT] Return:
1. Summary of root cause found
2. List of files changed with description of each change
3. Verification command and its result
```

## File Ownership Partitioning

Before spawning agents, the Lead MUST assign non-overlapping file ownership:

| Strategy | When to Use |
|----------|-------------|
| **By directory** | `src/auth/` -> Agent 1, `src/api/` -> Agent 2 |
| **By file** | `login.ts` -> Agent 1, `session.ts` -> Agent 2 |
| **By layer** | Tests -> Agent 1, Implementation -> Agent 2 |
| **By worktree** | Each agent gets isolated git worktree branch |

Rules:
- No two agents may own the same file unless using worktree isolation
- Shared dependencies (types, utils) belong to a single "foundation" agent that runs FIRST
- Agents consuming shared code run AFTER the foundation agent completes

## Staged Pipeline

```
plan -> prd -> exec -> verify -> fix (loop)
```

| Stage | Purpose | Agent Type | Exit Criteria |
|-------|---------|------------|---------------|
| plan | Decompose task, create task graph | explore/planner | Runnable subtask list with dependencies |
| prd | Clarify acceptance criteria | analyst | Explicit pass/fail criteria documented |
| exec | Implement changes | executor (parallel) | All subtasks reach terminal state |
| verify | Review and test | verifier/reviewer | All gates pass OR fix tasks generated |
| fix | Address defects | executor/debugger | Fixes complete, return to verify |

**Verify/Fix loop stops when:** verification passes with no remaining fix tasks, OR max fix attempts (3) exceeded.

## Handoff Integration

This skill integrates with `handoff-protocol.md` (see `.claude/rules/`):

- **Each stage transition produces a handoff document** per the protocol format
- Lead reads previous handoff BEFORE spawning next stage agents
- Handoff content is injected into agent spawn prompts
- On parallel dispatch, each agent produces independent handoff; Lead merges before passing downstream
- Handoff documents survive cancellation for session resume

Stage-specific handoff focus:

| Transition | Handoff Must Include |
|-----------|---------------------|
| plan -> exec | Task graph, file ownership map, dependency order |
| exec -> verify | Files changed per agent, test commands, known risks |
| verify -> fix | Specific defects with file:line, suggested fix approach |
| fix -> verify | What was fixed, what was retried, remaining concerns |

## Spawn Protocol

```
1. Lead decomposes task into N subtasks
2. Lead assigns file ownership (non-overlapping)
3. Lead creates tasks with dependencies (blockedBy)
4. Lead pre-assigns owners to tasks
5. Lead spawns all agents IN PARALLEL (do not wait sequentially)
6. Lead monitors via polling + inbound messages
7. Lead coordinates: unblock, reassign, handle failures
8. Lead initiates shutdown when all tasks terminal
```

## Worker Preamble (inject into every agent prompt)

```
You are WORKER "{name}" in team "{team}". You report to "team-lead".

PROTOCOL:
1. Check assigned tasks (owner = your name), pick first pending
2. Mark in_progress, execute work, mark completed
3. Report to team-lead via SendMessage with summary
4. Pick next assigned task or report standing by
5. On shutdown_request, respond with shutdown_response

RULES:
- NEVER spawn sub-agents or use Task tool
- NEVER edit files outside your ownership partition
- ALWAYS use absolute file paths
- ALWAYS report via SendMessage to "team-lead"
```

## Communication Patterns

| Pattern | When | Format |
|---------|------|--------|
| Worker -> Lead | Task complete/failed | `SendMessage(recipient="team-lead", content="Completed #ID: summary")` |
| Lead -> Worker | New assignment/guidance | `SendMessage(recipient="worker-N", content="Pick up task #ID")` |
| Lead -> All | Critical shared state change | Broadcast (use sparingly -- sends N messages) |
| Shutdown | All work done | Lead sends shutdown_request, waits for shutdown_response per worker |

## Watchdog Policy

- Task stuck `in_progress` > 5 min without messages -> send status check
- No response + stuck > 10 min -> reassign task to another worker
- Worker fails 2+ tasks -> stop assigning new tasks to it
- Dead worker (no heartbeat) -> reassign orphaned tasks, optionally spawn replacement

## Common Mistakes

| Mistake | Why It Fails | Fix |
|---------|-------------|-----|
| Prompt too broad ("fix all tests") | Agent gets lost, no focus | Scope to specific files/modules |
| No context in prompt | Agent wastes time exploring | Paste error messages, test names |
| No constraints | Agent refactors everything | Explicit file ownership + "do NOT change X" |
| No output spec | Can't verify what changed | Require structured summary |
| Sequential spawn | Wastes time | Spawn all agents in parallel |
| Shared file editing | Merge conflicts | Ownership partitioning or worktree isolation |
| Forgetting dependencies | Agents block each other | Map dependencies BEFORE spawning |

## NEVER

- NEVER let two agents edit the same file without worktree isolation
- NEVER spawn agents without explicit file ownership assignments
- NEVER skip the verify stage -- always verify after exec
- NEVER send broadcast when a targeted message suffices
- NEVER let the Lead do worker-level execution -- delegate everything
- NEVER spawn agents with vague prompts lacking context and constraints
- NEVER skip handoff documents between stages
- NEVER exceed 20 agents per team
- NEVER fabricate shutdown request_ids -- extract from the incoming message
