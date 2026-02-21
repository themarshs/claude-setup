# OpenClaw 架构深度解析 — 可提取模式分析

> 调研日期：2026-02-20
> 方法：4 个并行 Task agent 分别研究 openclaw/openclaw、openclaw/lobster、openclaw/clawhub、openclaw/skills
> 报告状态：VERIFIED（全部基于 GitHub API 直接读取源码，无 Web 搜索幻觉）

## Executive Summary

OpenClaw（小龙虾）是 Peter Steinberger (steipete) 创建的 213K 星多渠道 AI 个人助手网关，而非此前搜索 Agent 幻觉中描述的"持续学习框架"。其真正价值在三个子系统：**Lobster**（管道工作流引擎）、**ClawhHub**（Skill 注册中心 + 质量门控）、以及**标准化 Skill 格式**。从中可提取 7 个高价值模式用于强化我们的武器库，其中 3 个可直接内化，4 个作为架构参考。

## 1. OpenClaw 主框架真实面貌

### 不是什么

| 幻觉描述 | 实际情况 |
|----------|---------|
| "持续学习/迭代循环" | 不存在。无自改进机制 |
| "龙虾之道哲学" | 仅是 Logo emoji 和欢迎语 |
| "Skill 发现→安装→组合→执行→学习 生命周期" | Skill 是简单 MD 文件 + npm 分发 |
| "与 Claude Code 集成" | 仅开发时用 CLAUDE.md（→AGENTS.md 符号链接） |

### 实际是什么

**多渠道 AI 网关**：TypeScript 单仓（pnpm monorepo），通过插件接入 WhatsApp/Telegram/Slack/Discord/Signal/iMessage/Teams 等渠道。核心依赖包括 `@whiskeysockets/baileys`（WhatsApp）、`grammy`（Telegram）、`playwright-core`（浏览器自动化）、`sqlite-vec`（向量存储）。

**技术栈**：Node 22+、TypeScript ESM、tsdown 构建、Vitest 测试（70% 覆盖率）、Oxlint+Oxfmt（非 ESLint/Prettier）。

### 可提取模式

**模式 A：AGENTS.md / CLAUDE.md 符号链接**
每个目录放 `AGENTS.md`（详细开发指令），`CLAUDE.md` 是指向它的符号链接。Claude Code 自动读取 `CLAUDE.md`。

**模式 B：多 Agent 安全规则**（来自 AGENTS.md）
- 禁止创建/应用/删除 `git stash`（除非明确要求）
- 禁止切换分支（除非明确要求）
- 禁止操作 `git worktree`（除非明确要求）
- `push` 时可 `git pull --rebase`，但不得丢弃其他 Agent 的工作
- `commit` 时只 scope 到自己的变更
- 格式化差异自动解决，不询问

**模式 C：Scripts Committer 模式**
使用 `scripts/committer "<msg>" <file...>` 替代手动 `git add/commit`，确保多 Agent 环境下 staging 区互不干扰。

## 2. Lobster — 管道工作流引擎

> `openclaw/lobster` | 517 stars | MIT | 2 个运行时依赖（ajv + yaml）| ~30 源文件 ~100KB

### 三层管道模型

| 层级 | 定义方式 | 适用场景 |
|------|---------|---------|
| CLI Pipeline | Unix 管道文本 DSL：`exec --json 'echo [1,2,3]' \| where '0>=0' \| json` | 快速临时操作 |
| SDK Pipeline | Fluent builder：`new Lobster().pipe(exec(...)).pipe(approve(...)).pipe(fn)` | 程序化编排 |
| Workflow File | YAML/JSON 声明式：steps + stdin 引用 + condition | 持久化自动化 |

### 核心架构模式

**AsyncIterable 流式传输**：所有阶段间数据流为 `AsyncIterable<any>`。阶段可以是惰性（generator）或贪心（array-collecting function），管道无需全量缓存。

**Stage 接口**：
```typescript
// 每个阶段接收
{ input: AsyncIterable, args, ctx }
// 返回
{ output: AsyncIterable, halt?: boolean, rendered?: boolean }
```

**Halt-and-Resume Token**（最有价值的模式）：
- 管道遇到 `approve` 命令时硬停止
- 将完整管道状态序列化为 base64url JSON token
- Token 包含：`{ protocolVersion, pipeline, resumeAtIndex, items, prompt }`
- 恢复：`lobster resume --token <token> --approve yes|no`
- 支持链式审批（恢复后遇到下一个 approve 生成新 token）
- Workflow 文件的 resume 状态持久化到 `~/.lobster/state/`（非仅 token）

**双模输出**（Human vs Machine）：
- Human 模式：渲染到 stdout + TTY 交互
- Tool 模式：结构化 JSON 信封协议
```typescript
{
  protocolVersion: 1,
  ok: boolean,
  status: 'ok' | 'needs_approval' | 'cancelled' | 'error',
  output: any[],
  requiresApproval: null | { type, prompt, items, resumeToken },
  error?: { type: string, message: string }
}
```

**Side-Effect 声明**：命令显式声明副作用标签（`['local_exec']`、`['calls_clawd_tool']`、`['writes_state']`），用于工具发现和安全推理。

**State-Based Diff**：`diffAndStore` 模式 — 存储当前状态 → 与上次对比 → 仅在变化时触发动作。适用于轮询监控。

**Auth-Free 执行层**：Lobster 不管理凭证。通过环境变量（`CLAWD_URL`、`CLAWD_TOKEN`）委托认证，最小化攻击面。

### 23 个内置命令

| 类别 | 命令 |
|------|------|
| 数据整形 | `where`, `pick`, `head`, `sort`, `dedupe`, `map`, `group_by`, `template` |
| 执行 | `exec`, `clawd.invoke`, `llm_task_invoke` |
| 状态 | `state.get`, `state.set`, `diff.last` |
| 渲染 | `json`, `table` |
| 控制流 | `approve` |
| 工作流 | `workflows.list`, `workflows.run` |

## 3. ClawhHub — Skill 注册中心

> `openclaw/clawhub` | 2,412 stars | MIT | TanStack Start + Convex + OpenAI Embeddings

### 架构

| 层 | 技术 | 职责 |
|----|------|------|
| Web App | TanStack Start (React/Vite/Nitro) | 浏览、搜索、发布 |
| Backend | Convex (DB + 文件存储 + HTTP Actions) | Schema、查询、变更、API |
| CLI | `clawhub` binary | login/search/install/publish/sync |
| 搜索 | OpenAI `text-embedding-3-small` + Convex 向量搜索 | 语义发现 |

### 三层质量门控

**Gate 1 — 自动质量评分**（发布时）：
```typescript
quality: {
  score: number,
  decision: 'pass' | 'quarantine' | 'reject',
  trustTier: 'low' | 'medium' | 'trusted',
  signals: {
    bodyChars, bodyWords, uniqueWordRatio,
    headingCount, bulletCount,
    templateMarkerHits, genericSummary,
  }
}
```

**Gate 2 — 安全分析**（发布后）：
- VirusTotal 扫描
- LLM 多维度安全评估（置信度 + 维度评分 + 发现列表）
- 元数据-行为一致性检查（声明的环境变量 vs 实际使用）

**Gate 3 — 社区信号 + 人工审核**：
- Stars、评论、下载量、安装遥测
- 4+ 举报自动隐藏
- Moderator/Admin 可授予徽章（highlighted/official/deprecated）

### CLI 全生命周期

| 命令 | 功能 |
|------|------|
| `clawhub search <query>` | 向量语义搜索 |
| `clawhub explore --sort trending` | 浏览（按趋势/下载/星标排序）|
| `clawhub inspect <slug>` | 查看元数据（不安装）|
| `clawhub install <slug>` | 下载 + 解压到 `./skills/<slug>` |
| `clawhub update [--all]` | 指纹比对增量更新 |
| `clawhub publish <path>` | 发布新版本 |
| `clawhub sync` | 自动扫描 + 发布变更 Skill |

### 本地状态追踪

- `.clawhub/lock.json`：工作区级别锁文件（追踪所有已安装 Skill）
- `<skill>/.clawhub/origin.json`：Skill 级别溯源（安装来源 + 版本）

## 4. Skill 格式规范

### 标准结构

```
skills/{owner}/{slug}/
  SKILL.md          # 必需：YAML frontmatter + Markdown body
  _meta.json        # 必需：平台元数据 + 版本历史
  README.md         # 可选：人类可读文档
  example.md        # 可选：使用示例
  references/       # 可选：参考文档、排障指南
  scripts/          # 可选：可执行脚本
```

### Frontmatter Schema

```yaml
---
name: bw-cli
description: "Interact with Bitwarden... bitwarden bw password safe vaultwarden"
metadata:
  openclaw:
    emoji: "🔑"
    requires:
      env: [TODOIST_API_KEY]
      bins: [curl, jq]
      anyBins: [brew, apt]
      config: [~/.config/app/config.toml]
    primaryEnv: TODOIST_API_KEY
    install:
      - kind: brew
        formula: jq
        bins: [jq]
      - kind: node
        package: typescript
        bins: [tsc]
    os: ["macos"]
    always: false
    homepage: https://example.com
---
```

### _meta.json 双轨版本

```json
{
  "owner": "0x7466",
  "slug": "bw-cli",
  "displayName": "Bitwarden CLI",
  "latest": {
    "version": "1.1.1",
    "publishedAt": 1771097879493,
    "commit": "https://github.com/openclaw/skills/commit/2ad1f93..."
  },
  "history": [
    { "version": "1.4.1", "publishedAt": 1771062878380, "commit": "..." },
    { "version": "1.1.0", "publishedAt": 1770638576181, "commit": "..." }
  ]
}
```

### 与 Claude Code SKILL.md 对比

| 维度 | OpenClaw | 我们的 Claude Code |
|------|---------|-------------------|
| 文件位置 | `skills/{owner}/{slug}/SKILL.md` | `.claude/skills/{name}/SKILL.md` |
| Frontmatter | YAML（name/description/metadata） | YAML（name/description） |
| 元数据文件 | 独立 `_meta.json` | 无（ARMORY.md 集中管理） |
| 版本管理 | Semver + commit 链接 + 历史数组 | 无（仅 git 历史） |
| 依赖声明 | `requires.bins/env/config` | 无（散落在正文） |
| 路由触发 | description 关键词填充 | settings.json 斜杠命令 |
| 补充文件 | README.md / example.md / references/ | 无标准化 |
| 分发 | 中心化注册中心（clawhub.ai） | 仅本地文件系统 |
| 质量门控 | 自动评分 + LLM 安全分析 + 社区信号 | skill-judge 120 分制 |

## 5. 可提取模式总览

### Tier 1 — 可直接内化（改善现有武器库）

| # | 模式 | 来源 | 内化方式 | 收益 |
|---|------|------|---------|------|
| 1 | **Skill Frontmatter 增强** | ClawhHub + Skills | 在 SKILL.md frontmatter 中增加 `requires`（bins/env）、`triggers`（路由关键词）、`emoji` 字段 | 更精确的 Skill 路由 + 前置条件检查 |
| 2 | **references/ 目录模式** | Skills | 允许 Skill 目录下放 `references/` 子目录存放参考文档 | 主 SKILL.md 保持精简，深度知识按需加载 |
| 3 | **多 Agent 安全规则** | OpenClaw AGENTS.md | 内化到 `.claude/rules/` 新规则文件 | 防止多 Agent 并发时的 git 冲突和状态破坏 |

### Tier 2 — 架构参考（暂不实施，留作路线图）

| # | 模式 | 来源 | 备注 |
|---|------|------|------|
| 4 | Halt-and-Resume Token | Lobster | 需要自定义 CLI 工具，超出纯 Skill 范畴 |
| 5 | 双模输出协议 | Lobster | 已有 Claude Code 的 Task tool 覆盖 |
| 6 | State-Based Diff 监控 | Lobster | 可用于 MEMORY.md 变更检测，但当前 Hook 已覆盖 |
| 7 | 向量语义搜索注册中心 | ClawhHub | 需要 embedding 服务，当前 ARMORY.md 人工管理足够 |

## 6. 与我们当前架构的差距分析

| 能力 | OpenClaw 方案 | 我们的方案 | 差距评估 |
|------|-------------|-----------|---------|
| Skill 发现 | 向量搜索 + 趋势排序 | ARMORY.md 手动 + hunt Skill 搜索 | 中等（我们够用但不自动）|
| Skill 安装 | `clawhub install` 一键安装 | 手动 clone → 沙箱审判 → 基因熔炉 | 大（但我们的更安全）|
| Skill 组合 | Lobster 管道串联 | Task tool 手动编排 | 中等（Lobster 更优雅但我们够用）|
| 质量门控 | 三层自动化（评分+安全+社区） | skill-judge 120 分 + 沙箱双重安检 | 小（我们的更严格）|
| 版本管理 | Semver + commit 溯源 | 无 | 大（但单用户场景需求低）|
| 工作流引擎 | Lobster（管道+审批+恢复） | 无等价物 | 大（但 Claude Code 的 Task tool 部分覆盖）|

## 来源列表

全部来自 GitHub API 直接读取（mcp__github__get_file_contents），无 Web 搜索来源：

1. `openclaw/openclaw` — README.md, AGENTS.md, VISION.md, CONTRIBUTING.md, package.json
2. `openclaw/lobster` — README.md, src/runtime.ts, src/parser.ts, src/commands/, src/sdk/, src/workflows/, src/state/, src/token.ts, package.json
3. `openclaw/clawhub` — README.md, convex/schema.ts, docs/skill-format.md, packages/schema/, packages/clawdhub/, VISION.md
4. `openclaw/skills` — README.md, skills/ 目录结构, 多个 SKILL.md + _meta.json 样本

## 研究局限

1. **未读取完整源码**：Lobster ~30 个源文件仅深读了核心 10 个，ClawhHub 仅读了 schema 和关键文档
2. **未实际运行**：未在本地安装和测试 Lobster CLI 或 ClawhHub CLI
3. **社区活跃度未验**：213K 星数未独立验证（GitHub API 返回，可能准确但异常高）
4. **Nix 集成未深入**：OpenClaw 的 Nix 插件体系未详细分析
5. **LLM 安全分析实现未深入**：ClawhHub 的 `convex/llmEval.ts`（12KB）仅知接口，未读实现
