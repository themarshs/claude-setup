# Claude Code Arsenal / Claude Code 武器库

> 34 Skills + 4 Agents + 12 Rules + 7 Hooks — forged from 2,137 community assets
>
> 34 个 Skills + 4 个 Agents + 12 条 Rules + 7 个 Hooks — 从 2,137 条社区资产中基因锻造而来

---

## What is this? / 这是什么？

**EN:** A production-ready Claude Code configuration — not a collection of copy-pasted community files, but a **gene-forged arsenal**. Every weapon was created by scanning 2,137 community assets across 23 high-star repos, dissecting them into atomic elements, extracting only expert-level knowledge Claude doesn't already have, and forging it into concise, actionable Skills/Agents/Rules/Hooks.

**CN:** 一套生产级 Claude Code 配置 — 不是社区文件的复制粘贴合集，而是一个**基因锻造的武器库**。每件武器都经过：扫描 23 个高星仓库的 2,137 条社区资产 → 元素解剖 → 只提取 Claude 不具备的专家级知识 → 锻造为精炼的 Skills/Agents/Rules/Hooks。

### The Gene Forge Protocol / 基因熔炉协议

```
Community Asset (e.g. 14,813 chars)
    ↓ Element Dissection / 元素解剖
Expert Knowledge + Activation Hints + Redundant Content
    ↓ Filter / 过滤
Expert Only (Claude doesn't know this)
    ↓ Forge / 锻造
Concise Skill (~150 lines, pure knowledge delta)
```

**Core formula / 核心公式:**
> Good Skill = Expert-only Knowledge − What Claude Already Knows

---

## Arsenal Overview / 武器库总览

### Skills (34)

| Category | Skill | Description |
|----------|-------|-------------|
| **Search & Retrieval** | `hunt` | 4-step progressive search + anti-bias checks |
| | `deep-research` | 5-stage pipeline + parallel search + cross-validation |
| | `rag` | Orama hybrid search + 19-language text splitting |
| | `distillery-search` | BM25+vector search over 2,137 community assets |
| | `retrieval-methodology` | Intent classification + channel routing + search strategy |
| | `context7` | Live documentation retrieval via Context7 API |
| **Engineering** | `tdd-workflow` | Red-green-refactor decision trees + Playwright flaky isolation + EDD |
| | `api-design` | URL decision table + HTTP method matrix + pagination + rate limiting |
| | `docker-patterns` | Multi-stage Dockerfile + security hardening + network isolation |
| | `database-expertise` | Index selection matrix (B-tree/GIN/BRIN/Hash) + RLS + concurrency |
| | `code-refactoring` | knip/depcheck + SAFE/CAREFUL/RISKY grading + debt budget |
| | `mcp-development` | @modelcontextprotocol/sdk stdio server development guide |
| | `office-documents` | docx/xlsx/pdf/pptx creation and editing |
| **Methodology** | `context-engineering` | 5 degradation patterns + compression strategies + tokens-per-task |
| | `prompt-engineering` | 7-framework selection matrix + Claude XML optimization |
| | `tool-design` | Consolidation principle + description engineering + MCP naming |
| | `parallel-debugging` | ACH multi-hypothesis + evidence strength grading |
| | `multi-agent-team` | Parallel dispatch + file ownership + 5-stage pipeline |
| **Meta (Self-Evolution)** | `skill-creator` | Skill creation wizard |
| | `writing-skills` | TDD approach to writing Skills |
| | `skill-judge` | 8-dimension evaluation (120 points) + element dissection forge |
| | `skill-testing` | TDD for Skills: 7 pressure types + rationalization capture |
| | `self-learning` | Autonomous web-based skill generator |
| | `knowledge-evolution` | Hooks-driven instinct learning with confidence decay |
| | `find-skills` | Discover and install community skills |
| | `spiral-bootstrap` | Double-helix evolution orchestrator with L1-L4 graded response |
| | `evolution-session` | Independent evolution session executor for L3 tool forging |
| **Automation** | `ralph-loop` | Stop Hook self-loop for unattended iteration with completion signals |
| | `hookify` | Declarative Hook rules via Markdown+YAML with 6 operators |
| **Code Review** | `pr-review-toolkit` | 6-perspective parallel PR review (code/test/error/type/comment/simplify) |
| | `code-review` | 5-agent compliance review with per-issue confidence scoring |
| **Workflow** | `feature-dev` | 7-phase gated pipeline: Discovery→Explore→Questions→Design→Implement→Review→Summary |
| **Quality** | `requesting-code-review` | Size triage + content-aware routing + static analysis pre-check |
| | `agent-browser` | Browser automation CLI for web interaction |

| 分类 | Skill | 说明 |
|------|-------|------|
| **搜索检索** | `hunt` | 4 步渐进搜索 + 反偏见检查 |
| | `deep-research` | 5 阶段 Pipeline + 并行搜索 + 交叉验证 |
| | `rag` | Orama 混合搜索 + 19 语言分块 |
| | `distillery-search` | 2,137 条社区资产 BM25+向量搜索 |
| | `retrieval-methodology` | 意图分类 + 通道选择 + 搜索策略 |
| | `context7` | 通过 Context7 API 实时查文档 |
| **工程实践** | `tdd-workflow` | 红绿循环决策树 + Playwright flaky 隔离 + EDD |
| | `api-design` | URL 决策表 + HTTP 方法矩阵 + 分页 + 限流 |
| | `docker-patterns` | 多阶段 Dockerfile + 安全加固 + 网络隔离 |
| | `database-expertise` | 索引选择矩阵 + RLS 优化 + 并发模式 |
| | `code-refactoring` | knip/depcheck 工具链 + 风险分级 + 债务预算 |
| | `mcp-development` | 基于 @modelcontextprotocol/sdk 的 MCP Server 开发 |
| | `office-documents` | docx/xlsx/pdf/pptx 生成与编辑 |
| **方法论** | `context-engineering` | 5 种退化模式 + 压缩策略 + tokens-per-task |
| | `prompt-engineering` | 7 框架选择矩阵 + Claude XML 优化 |
| | `tool-design` | 合并原则 + Description Engineering + MCP 命名 |
| | `parallel-debugging` | ACH 多假设竞争 + 证据强度分级 |
| | `multi-agent-team` | 并行派发 + 文件所有权 + 5 阶段 pipeline |
| **元能力（自进化）** | `skill-creator` | Skill 创建向导 |
| | `writing-skills` | TDD 方式写 Skill |
| | `skill-judge` | 8 维度评分（120 分制）+ 元素解剖锻造 |
| | `skill-testing` | TDD for Skills：7 种压力类型 + 合理化捕获 |
| | `self-learning` | 自主 Web 搜索生成 Skill |
| | `knowledge-evolution` | Hooks 驱动的本能学习 + 置信度衰减 |
| | `find-skills` | 搜索安装社区 Skills |
| | `spiral-bootstrap` | 双螺旋进化编排器 + L1-L4 分级响应 |
| | `evolution-session` | 独立进化夜班执行器 + L3 工具锻造 |
| **自动化** | `ralph-loop` | Stop Hook 自循环 + 完成信号匹配 + 无人值守迭代 |
| | `hookify` | Markdown+YAML 声明式 Hook 规则 + 6 种 operator |
| **代码审查** | `pr-review-toolkit` | 6 视角并行 PR 审查 (code/test/error/type/comment/simplify) |
| | `code-review` | 5-Agent 合规性审查 + 逐 issue 置信度评分 |
| **工作流** | `feature-dev` | 7 阶段硬门控 Pipeline：Discovery→Summary + 三哲学架构对比 |
| **质量守护** | `requesting-code-review` | 大小分级 + 内容感知路由 + 静态分析预检 |
| | `agent-browser` | 浏览器自动化 CLI |

### Agents (4)

| Agent | Role | Tools | Description |
|-------|------|-------|-------------|
| `architect` | Architecture Design / 架构设计 | Read-only | 4-phase workflow + ADR template + 8 anti-pattern detection |
| `security-reviewer` | Security Audit / 安全深审 | Read-only | OWASP deep review + language-specific patterns (JS/Py/Go) + severity SLA |
| `retrieval-orchestrator` | Search Dispatch / 检索调度 | All search tools | Intent decomposition + multi-channel dispatch + cross-validation |
| `memory-updater` | Memory Maintenance / 记忆维护 | Read, Edit, Glob, Grep | Analyze dirty files and update MEMORY.md |

### Rules (12)

| Rule | Purpose / 用途 |
|------|----------------|
| `coding` | 5 golden rules + TDD + context efficiency + 3-tier architecture |
| `error-discipline` | 3-Strike escalation + error persistence + anti-repeat failure |
| `confidence-gate` | 3-tier confidence gate (>=90% act, 70-89% options, <70% ask) |
| `security-gate` | Pre-commit security checklist + secret management |
| `code-review-standards` | 4-level severity + structured output template |
| `git-workflow` | Conventional Commits + atomic split + PR workflow |
| `dependency-management` | Pre-add checklist + license compliance + audit |
| `naming` | Multi-language naming conventions (JS/TS/Python/DB) |
| `documentation` | What to / NOT to document |
| `lead-discipline` | Lead role constraints: delegate, don't execute |
| `handoff-protocol` | Agent handoff document format + verdict system |
| `language` | Chinese discussion, English code/config |

### Hooks (7)

| Hook | Trigger | Purpose / 用途 |
|------|---------|----------------|
| `pre-compact-save` | PreCompact | Backup MEMORY.md before context compaction |
| `post-compact-restore` | SessionStart | Inject MEMORY.md into context after compaction |
| `stop-guard` | Stop | Prevent accidental stops during autonomous iteration |
| `post-tool-dirty-tracker` | PostToolUse | Track files modified by Edit/Write/Bash |
| `pre-tool-guard` | PreToolUse | **Hard-block** writes to mcp-servers/, warn on main branch |
| `prompt-submit` | UserPromptSubmit | Auto-read MEMORY.md on first prompt per session |
| `pain-tracker` | PostToolUse | Sliding-window detection of repeated searches → pain ledger |

---

## Architecture / 架构

### Three-Body File System / 三体文件架构

```
CLAUDE.md    — System BIOS (bootloader, immutable rules, <=50 lines)
MEMORY.md    — State Machine (breakpoint resume, overwrite-only, <=30 lines)
ARMORY.md    — Arsenal Registry (active weapons, retired list, vacant niches)
```

### Six-Layer Coverage / 六层覆盖体系

```
┌─────────────────────────────────────────────────┐
│  Layer 6: Governance / 治理层                     │
│  12 Rules + 7 Hooks                              │
├─────────────────────────────────────────────────┤
│  Layer 5: Quality / 质量守护层                     │
│  security-reviewer, requesting-code-review,      │
│  security-gate, code-review-standards            │
├─────────────────────────────────────────────────┤
│  Layer 4: Methodology / 方法论层                   │
│  context-engineering, prompt-engineering,         │
│  tool-design, multi-agent-team, architect        │
├─────────────────────────────────────────────────┤
│  Layer 3: Engineering / 工程实践层                  │
│  tdd-workflow, api-design, docker-patterns,      │
│  database-expertise, code-refactoring,           │
│  mcp-development, office-documents               │
├─────────────────────────────────────────────────┤
│  Layer 2: Retrieval / 检索层                      │
│  hunt, rag, deep-research, distillery-search,    │
│  context7, retrieval-methodology,                │
│  retrieval-orchestrator                          │
├─────────────────────────────────────────────────┤
│  Layer 1: Meta (Self-Evolution) / 元能力层         │
│  skill-creator, skill-judge, skill-testing,      │
│  self-learning, knowledge-evolution, find-skills │
└─────────────────────────────────────────────────┘
```

### Double-Helix Self-Evolution / 双螺旋自进化

```
Pain Signal (repeated search, empty results, stale cache)
      │
      ▼
┌─────────────────────────────────────────────────┐
│  spiral-bootstrap (L1-L4 Graded Response)       │
│                                                  │
│  L1: Silent log (0 cost)                        │
│  L2: Data distillation (~2K tokens)             │
│  L3: Tool forging (~50K tokens, async)    ──────┼──► evolution-session
│  L4: Architecture overhaul (user-authorized)    │      (independent /evolve)
└──────────┬──────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────┐
│  Pain Detection Infrastructure                   │
│  pain-tracker.sh → .pain_ledger.json            │
│  dirty-tracker.sh → ARCHITECTURE_MAP [STALE]    │
│  overnight-plan.md → L3 work orders             │
└──────────┬──────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────┐
│  Methodology Binding (non-negotiable)            │
│  Every L2/L3 success MUST update                │
│  retrieval-methodology routing rules            │
└─────────────────────────────────────────────────┘
```

**EN:** The system can detect its own retrieval friction (repeated failed searches, stale caches) and autonomously heal — from zero-cost logging (L1) up to forging entirely new tools (L3) in dedicated evolution sessions. Every improvement is permanently bound into methodology routing rules.

**CN:** 系统能自主检测检索摩擦（重复失败搜索、缓存过期），并自主修复——从零成本记录（L1）到在独立进化会话中锻造全新工具（L3）。每次改进都永久绑定到方法论路由规则中。

### Four Ratchets / 4 道棘轮（不可违背）

1. **Delta Gate**: New weapon must score strictly > current highest in same niche
2. **Highlander**: Only one weapon per niche — old weapon physically deleted on replacement
3. **Forced Bootstrap**: Must route through ARMORY.md to highest-tier weapon, no raw commands
4. **Mutation Checkpoint**: Each iteration must produce real diff or declare "capped + reason"

---

## How it was built / 怎么造的

```
Step 1: Full Scan / 全量扫描
        2,137 community assets across 23 repos
        8 parallel scanning agents

Step 2: Niche Analysis / 生态位分析
        ~910 new niches identified
        4 red-alert competitors found

Step 3: Wave 1 Forge / 第一波锻造
        8 parallel forging agents
        → 11 Skills + 1 Agent + 4 Rules + 2 Hooks

Step 4: Wave 2 Red Alert Upgrade / 第二波红色警报升级
        4 parallel upgrade agents
        → 2 upgrades + 1 new Skill + 1 new Agent

Step 5: Wave 3 Supplement / 第三波补充
        → mcp-development Skill

Step 6: Verification / 二轮验证
        15 dimensions × Top 10 cross-validation
        → Confirmed: no major gaps
```

---

## Related Repos / 相关仓库

| Repo | Purpose |
|------|---------|
| [claude-setup](https://github.com/themarshs/claude-setup) | The arsenal (this repo) / 武器库（本仓库） |
| [claude-distillery](https://github.com/themarshs/claude-distillery) | Search infrastructure: 2,137 community assets indexed / 检索基础设施 |

---

## Quick Start / 快速开始

```bash
# Clone / 克隆
git clone git@github.com:themarshs/claude-setup.git
cd claude-setup

# The .claude/ directory contains all Skills, Agents, Rules, and Hooks.
# Claude Code will automatically detect them when you open a session
# in this directory.
#
# .claude/ 目录包含所有 Skills、Agents、Rules 和 Hooks。
# 在此目录下启动 Claude Code 会话时会自动加载。
```

### Prerequisites / 前置要求

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- Node.js >= 18
- Git configured with SSH

### Optional: Distillery MCP / 可选：蒸馏器 MCP

To enable community asset search via MCP:

```bash
# Clone distillery / 克隆蒸馏器
git clone git@github.com:themarshs/claude-distillery.git
cd claude-distillery && npm install

# Register in .mcp.json (already configured in this repo)
# 在 .mcp.json 中注册（本仓库已配置）
```

---

## License

MIT
