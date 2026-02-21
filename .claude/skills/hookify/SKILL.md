---
name: hookify
description: |
  WHAT: Declarative Hook 规则系统 — 用 Markdown+YAML 声明式配置替代手写 bash Hook 脚本，实现模式匹配拦截/警告
  WHEN: 需要新增 Hook 规则（拦截危险命令、警告不良代码模式、强制完成检查）时；需要批量管理 Hook 规则时
  KEYWORDS: hookify, hook, guard, block, warn, rule, pattern, PreToolUse, PostToolUse, Stop, UserPromptSubmit
---

# Hookify — Declarative Hook Rules

> Source: `anthropics/claude-plugins-official/plugins/hookify` (Anthropic official)

## Architecture

```
.claude/hookify.{name}.local.md   ← Declarative rules (config)
        ↓ (read dynamically)
Python executor scripts            ← Rule engine (runtime)
        ↓ (registered in)
hooks.json / settings.local.json   ← Hook registry
```

**Core insight**: Rules are `.local.md` files read at EVERY hook invocation — no restart needed. The Python engine loads rules, evaluates conditions, outputs JSON response.

**Python 3.7+ required** (stdlib only, no pip deps). Our env has Python available.

## Rule Declaration Format

### Simple Rule (single pattern)

```markdown
---
name: block-dangerous-rm
enabled: true
event: bash
pattern: rm\s+-rf
action: block
---

Warning message shown to Claude (supports **markdown**).
```

### Advanced Rule (multiple conditions, AND logic)

```markdown
---
name: warn-hardcoded-keys
enabled: true
event: file
action: warn
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.tsx?$
  - field: new_text
    operator: regex_match
    pattern: (API_KEY|SECRET|TOKEN)\s*=\s*["']
---

Hardcoded credential detected in TypeScript. Use env vars.
```

## Condition Engine

### 6 Operators

| Operator | Behavior | Use Case |
|----------|----------|----------|
| `regex_match` | Python re.search (IGNORECASE) | Most common, pattern matching |
| `contains` | Substring `in` check | Literal string presence |
| `equals` | Exact match | Tool name, specific value |
| `not_contains` | Substring NOT present | Ensure something exists (stop event) |
| `starts_with` | Prefix check | Path prefix |
| `ends_with` | Suffix check | File extension |

**All conditions are AND'd** — every condition must match for rule to fire.

### Field Reference by Event

| Event | Fields Available | Default (simple pattern) |
|-------|-----------------|--------------------------|
| `bash` | `command` | `command` |
| `file` | `file_path`, `new_text`, `old_text`, `content` | `new_text` |
| `stop` | `reason`, `transcript` (reads file) | `content` |
| `prompt` | `user_prompt` | `content` |

`tool_matcher` field (optional): Override tool filter, e.g. `"Edit|Write"`, `"Bash"`, `"*"`.

## Action Modes

| Action | PreToolUse | Stop | Other |
|--------|-----------|------|-------|
| `warn` | Shows `systemMessage`, allows op | Shows message | Shows message |
| `block` | Returns `permissionDecision: "deny"` | Returns `decision: "block"` | Shows message only |

**Decision matrix**: Use `block` for security/data-loss risks; `warn` for style/quality.

## File Convention

- Path: `.claude/hookify.{descriptive-name}.local.md`
- Naming: kebab-case, verb-first (`block-rm-rf`, `warn-console-log`, `require-tests`)
- Gitignore: Add `.claude/*.local.md`
- Toggle: Set `enabled: false` in frontmatter (no delete needed)

## Integration with Our Existing Hooks

Our 7 hooks serve DIFFERENT purposes than hookify:

| Our Hook | Type | Hookify Replacement? |
|----------|------|---------------------|
| `pre-tool-guard.sh` | Imperative (path check, git branch) | NO — logic too complex |
| `stop-guard.sh` | Imperative (MEMORY.md state check) | NO — file I/O logic |
| `prompt-submit.sh` | Imperative (session marker, inject) | NO — stateful |
| `pre-compact-save.sh` | Imperative (file backup) | NO — side effect |
| `post-compact-restore.sh` | Imperative (inject content) | NO — side effect |
| `pain-tracker.sh` | Imperative (search counting) | NO — accumulator |
| `post-tool-dirty-tracker.sh` | Imperative (dirty file list) | NO — side effect |

**Verdict**: Our hooks do imperative stateful operations. Hookify does declarative pattern matching. They are complementary, not competitive. Use hookify for NEW pattern-match rules only.

### How to Add Hookify to Our System

Option A (Plugin install — recommended if available):
```bash
claude /plugin install hookify@claude-plugin-directory
```

Option B (Manual integration — add to `settings.local.json`):
```json
{
  "hooks": {
    "PreToolUse": [
      { "hooks": [{ "type": "command", "command": "python3 /path/to/hookify/hooks/pretooluse.py", "timeout": 10 }] }
    ]
  }
}
```

Option C (Pure bash alternative — no Python needed):
Create a single `hookify-eval.sh` that reads `.local.md` files and uses `grep -P` for regex. Tradeoff: loses `not_contains` on transcript, loses multi-condition AND. Viable for simple single-pattern rules only.

## Practical Examples for Our Setup

### Block writes to protected paths (hookify version of our guard)

```markdown
---
name: block-mcp-servers-write
enabled: true
event: file
action: block
conditions:
  - field: file_path
    operator: contains
    pattern: mcp-servers
---

RED LINE: mcp-servers directory is protected.
```

### Warn on credential patterns

```markdown
---
name: warn-hardcoded-secrets
enabled: true
event: file
action: warn
conditions:
  - field: new_text
    operator: regex_match
    pattern: (sk-|ghp_|AKIA|password\s*[:=])
---

Possible hardcoded credential detected. Use environment variables.
```

### Require tests before stop

```markdown
---
name: require-tests
enabled: false
event: stop
action: block
conditions:
  - field: transcript
    operator: not_contains
    pattern: npm test|pytest|cargo test
---

No test execution detected in session. Run tests before completing.
```

## NEVER List

1. NEVER install hookify without verifying Python 3 is available: `python3 --version`
2. NEVER use `action: block` on `event: all` — will block every operation
3. NEVER put hookify `.local.md` files in the plugin directory — they go in PROJECT `.claude/`
4. NEVER use overly broad patterns (`.*`, `log`, `test`) — false positive storm
5. NEVER migrate our existing imperative hooks to hookify — they need stateful logic hookify cannot express
6. NEVER forget `enabled: true` in frontmatter — rules are inert without it
7. NEVER use YAML quoted strings for patterns (`"\\s"`) — use unquoted (`\s`) to avoid double-escape hell
8. NEVER create hookify rules for things better handled by `.claude/rules/*.md` — rules guide Claude's behavior at prompt level, hooks intercept at tool level

## Quick Decision: hookify vs hand-written hook vs rule

| Need | Solution |
|------|----------|
| Pattern match on tool input → warn/block | **hookify** `.local.md` |
| Stateful logic (counters, file I/O, git ops) | **Hand-written** bash hook |
| Guide Claude's reasoning/approach | **`.claude/rules/`** markdown |
