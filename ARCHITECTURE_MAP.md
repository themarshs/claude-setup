# OpenCode → Claude Code 架构映射

> 创建时间：2026-02-19
> 目的：记录 OpenCode 现有架构，以及到 Claude Code 的对应关系，供后续迁移参考

---

## 一、OpenCode 现有架构总览 [STALE]
<!-- sources: CLAUDE.md, ARMORY.md, .claude/settings.json -->

### 核心设计：治理闭环 [STALE]
<!-- sources: .claude/hooks/pre-tool-guard.sh, .claude/hooks/post-tool-dirty-tracker.sh -->

```
Governance → Audit → Learning

         ┌─────────────┐
         │  IronGate    │  ← 物理门禁：写操作前必须拿 Visa (S/M/L)
         │  pre-execution│
         └──────┬───────┘
                │
         ┌──────▼───────┐
         │   GovOps     │  ← 审计日志：所有写操作记录到 govops.jsonl
         └──────┬───────┘
                │
         ┌──────▼───────┐
         │  Guardrails   │  ← 拦截非法操作（.env、非 ASCII 路径等）
         └──────────────┘
```

### Agent 定义（14 个，按职能分类）
<!-- sources: .claude/agents/architect.md, .claude/agents/retrieval-orchestrator.md, .claude/agents/memory-updater.md, .claude/agents/security-reviewer.md -->

**开发类：**
- `architect` — 架构师
- `coder` — 编码
- `code-reviewer` — 代码审查
- `debugger` — 调试
- `researcher` — 研究
- `tech-jury` — 技术评审

**内容类：**
- `content-writer` — 内容撰写
- `content-researcher` — 内容调研
- `content-compliance` — 内容合规
- `content-seo` — SEO 优化
- `writing-pm` — 写作项目管理

**会议类：**
- `meeting-readonly` — 会议只读
- `meeting-sandbox` — 会议沙盒

### Commands / 任务流（7 个） [STALE]
<!-- sources: .claude/skills/hunt/SKILL.md, .claude/skills/deep-research/SKILL.md -->

| 命令 | 绑定 Agent | 用途 |
|------|-----------|------|
| `/governance-change` | architect | 治理架构变更（影响评估→兼容性检查→方案设计→实施→验证） |
| `/build` | — | 项目构建，含预执行分诊 |
| `/iterate` | — | 迭代开发循环 |
| `/compact-save` | — | 战略性上下文压缩，防止"遗忘"规则 |
| `/error-handling` | — | 标准化错误恢复 |
| 其余 2 个 | — | 待确认 |

### MCP Server（3 个） [STALE]
<!-- sources: .claude/settings.json -->

| 服务 | 位置 | 功能 |
|------|------|------|
| IronGate | `D:/ai/mcp-servers/.irongate/` | 写操作门禁，Visa 签发 |
| governance-mcp-server | `D:/ai/mcp-servers/governance-mcp-server/` | 治理层 MCP |
| govops-mcp-server | `D:/ai/mcp-servers/govops-mcp-server/` | 审计日志记录 |

### 关键配置位置 [STALE]
<!-- sources: .claude/settings.json, CLAUDE.md -->

| 路径 | 内容 |
|------|------|
| `~/.config/opencode/opencode.json` | 主配置 |
| `~/.config/opencode/agents/` | Agent 定义（.md 文件） |
| `~/.config/opencode/commands/` | Command 定义（.md 文件） |
| `~/.config/opencode/skills/` | Skills |
| `~/.config/opencode/AGENTS.md` | 治理主文档（路由表、红线规则等） |
| `D:/ai/lab/AGENTS.md` | 训练台治理文档（Session State、Routing Tables、Red Lines） |
| `D:/ai/lab/opencode_architecture.md` | 完整架构文档（14 agents, 7 commands, 43 skills） |
| `D:/ai/mcp-servers/.irongate/govops.jsonl` | 审计日志 |

---

## 二、Claude Code 原生机制对照 [STALE]
<!-- sources: CLAUDE.md, ARMORY.md -->

| OpenCode 组件 | Claude Code 对应 | 载体 |
|--------------|-----------------|------|
| Agent 定义（architect, coder...） | **Custom Agents** | `.claude/agents/*.md` |
| Commands（/build, /iterate...） | **Skills** | `.claude/skills/*/SKILL.md` |
| IronGate（写操作门禁） | **Hooks — PreToolUse** | `settings.json` → hooks |
| GovOps（审计日志） | **Hooks — PostToolUse** | 异步写日志脚本 |
| Guardrails（拦截非法操作） | **Hooks — PreToolUse** | exit code 2 阻断 |
| AGENTS.md（治理文档） | **CLAUDE.md + .claude/rules/** | 分层知识注入 |
| Visa 分级（S/M/L） | **Hook 脚本判断变更级别** | 自定义逻辑 |
| opencode.json 配置 | **settings.json 层级体系** | 5 级优先级 |

---

## 三、Claude Code 可用的原生扩展点 [STALE]
<!-- sources: CLAUDE.md, docs/hooks.md, docs/skills.md, docs/settings.md -->

### 配置层级（优先级高→低） [STALE]
<!-- sources: .claude/settings.json, .claude/settings.local.json -->
1. `managed-settings.json` — 组织强制
2. CLI 启动参数 — 单次会话
3. `.claude/settings.local.json` — 项目私有
4. `.claude/settings.json` — 项目共享
5. `~/.claude/settings.json` — 全局

### 知识注入 [STALE]
<!-- sources: CLAUDE.md, .claude/rules/coding.md, .claude/rules/confidence-gate.md, .claude/rules/error-discipline.md, .claude/rules/security-gate.md -->
- `CLAUDE.md` — 多级：组织 / 全局 / 项目 / 子目录
- `.claude/rules/*.md` — 模块化规则（支持 glob 路径匹配）

### 生命周期 Hooks [STALE]
<!-- sources: .claude/hooks/pre-tool-guard.sh, .claude/hooks/post-tool-dirty-tracker.sh, .claude/hooks/stop-guard.sh, .claude/hooks/pre-compact-save.sh, .claude/hooks/post-compact-restore.sh, .claude/hooks/prompt-submit.sh -->
```
SessionStart → UserPromptSubmit → PreToolUse → PermissionRequest
→ PostToolUse → Notification → Stop → SubagentStart/Stop
→ PreCompact → SessionEnd
```
- 同步阻断：exit code 2
- JSON 输出：`{ "decision": "block", "reason": "..." }`
- Matcher：正则过滤（如 `"matcher": "Write|Edit"`）
- 异步模式：`"async": true`

### 多智能体
<!-- sources: .claude/agents/architect.md, .claude/agents/retrieval-orchestrator.md, .claude/agents/memory-updater.md, .claude/agents/security-reviewer.md -->
- 内建 Subagent：Explore / Plan / Bash / General-purpose
- 自定义 Agent：`.claude/agents/*.md`
- Agent Teams（实验性）：`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

### Skills（自定义斜杠命令） [STALE]
<!-- sources: .claude/skills/retrieval-methodology/SKILL.md, .claude/skills/hunt/SKILL.md, .claude/skills/deep-research/SKILL.md -->
- 格式：目录 + `SKILL.md`（YAML frontmatter）
- 位置：`.claude/skills/`（项目）/ `~/.claude/skills/`（全局）
- 动态注入：`` !`command` `` 语法
- 参数：`$ARGUMENTS`、`$0`、`$1`

### Plugins（打包体）
<!-- sources: docs/plugins.md -->
- `plugin.json` 定义元数据
- 打包 Skills + Hooks + MCP + Agents

### 编程式接口
<!-- sources: docs/cli-reference.md -->
- `claude -p "Prompt"` — 单轮执行
- `--output-format text|json|stream-json`
- `--json-schema` — 结构化输出
- `--allowedTools` — 脚本中自动放行

---

## 四、待决策事项 [STALE]
<!-- sources: CLAUDE.md, ARMORY.md -->

- [ ] 迁移策略：全量 / 精简 / 最小可用？
- [ ] 14 个 Agent 中哪些高频、哪些可砍？
- [ ] 7 个 Command 中哪些需要重建为 Skill？
- [ ] IronGate 门禁是否需要在 Claude Code 中重建？还是用更轻量的 Hook 替代？
- [ ] 审计日志格式是否沿用 govops.jsonl？
