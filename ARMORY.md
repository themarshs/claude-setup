# ARMORY.md — 武器库注册表

> 最后更新：2026-02-21 skill-judge v2 + code-review 精装修
> 规则：同生态位只留一个（Highlander），新工具必须 > 当前最高分才能替换

## 活跃武器

### Skills（手动安装）

| 生态位 | 工具名 | 类型 | 综合分 | 用途 | 触发条件 |
|--------|--------|------|--------|------|----------|
| 技能搜索 | find-skills | Skill | 基准 | `npx skills find` 搜 skills.sh | 需要寻找新 Skill 时 |
| 自主学习 | self-learning | Skill | 基准 | 学新技术并生成 Skill | `/learn <topic>` |
| 技能创建 | skill-creator | Skill | 基准 | 创建新 Skill 向导 | 需要自造 Skill 时 |
| 技能编写 | writing-skills | Skill | 基准 | TDD 方式写 Skill | 写 SKILL.md 时 |
| 技能评估+锻造 | skill-judge | Skill | 基准 | 双模式：整体评分(Mode1) + 元素解剖锻造(Mode2) | 审判阶段/吸收社区资产时 |
| 审查调度 | requesting-code-review | Skill | 基准 | 审查触发决策树 + 工作流节奏映射 + 反馈响应规则 | 完成 task/feature 后 |
| 浏览器自动化 | agent-browser | Skill | 基准 | 浏览器操控 CLI | 需要操作网页时 |
| 技术文档检索 | context7 | Skill | 基准 | curl 调 context7.com API 查最新文档 | 查库/框架文档时 |
| 知识进化 | knowledge-evolution | Skill | 基准 | 元回顾阶段本能提取→聚类→升级 | 螺旋 SOP 元回顾阶段 |
| 发散搜索 | hunt | Skill | 基准 | 4 步渐进搜索 + 反偏见检查 + 结构化评估 | 螺旋 SOP 发散阶段 |
| 语义检索 | rag | Skill | 8.0 | Orama 混合搜索 + Vectra TextSplitter 19 语言分块 | 代码/文档语义搜索时 |
| 深度研究 | deep-research | Skill | 7.2 | 5 阶段 Pipeline + 并行搜索 + 交叉验证 + Anti-Hallucination | 技术比较/行业分析/竞品调研时 |
| 检索方法论 | retrieval-methodology | Skill | 基准 | 意图分类 + 通道选择 + 搜索策略 + 交叉验证协议 | 任何搜索动作前加载 |

### Skills（superpowers 插件提供）

| 生态位 | 工具名 | 综合分 | 触发条件 |
|--------|--------|--------|----------|
| 设计前置 | superpowers:brainstorming | 基准 | 任何创建/修改功能前 |
| 流程纪律 | superpowers:using-superpowers | 基准 | 每次会话启动 |
| 完成验证 | superpowers:verification-before-completion | 基准 | 宣称完成前 |
| 调试流程 | superpowers:systematic-debugging | 基准 | 遇到 bug 时 |
| TDD | superpowers:test-driven-development | 基准 | 写功能代码前 |
| 计划编写 | superpowers:writing-plans | 基准 | 多步任务前 |
| 代码审查 | superpowers:requesting-code-review | 基准 | 完成主要功能后 |
| 并行派发 | superpowers:dispatching-parallel-agents | 基准 | 2+ 独立任务时 |

### Agents（自造）

| 生态位 | 工具名 | 类型 | 综合分 | 用途 | 触发条件 |
|--------|--------|------|--------|------|----------|
| 记忆维护 | memory-updater | Agent (haiku) | 基准 | 分析 dirty files 更新 MEMORY.md | Stop Hook 或手动调用 |
| 检索调度 | retrieval-orchestrator | Agent | 基准 | 意图分解 + 多通道调度 + 合并交叉验证 | 多维综合检索需求时 |

### Rules（模块化规则）

| 文件 | glob 匹配 | 内容 | 来源 |
|------|-----------|------|------|
| `.claude/rules/coding.md` | `**/*.{ts,tsx,js,jsx,py,go,rs,java,sh}` | 5 条黄金法则 + TDD + 上下文效率 + 三层架构 | 16 个高星仓库（67k+ stars）|
| `.claude/rules/lead-discipline.md` | `**/*` | Lead 角色约束：不亲自干活、先搜再建、防偏离 | 用户纠正后内化 |
| `.claude/rules/handoff-protocol.md` | — | Agent 交接协议：Handoff 文档格式 + Verdict 三档判定 | everything-claude-code 精华提取 |
| `.claude/rules/error-discipline.md` | `**/*` | 3-Strike 升级 + 错误持久化 + 2-Action 写入 + 防重复失败 | SuperClaude+GSD+planning-with-files 精华提取 |
| `.claude/rules/confidence-gate.md` | `**/*` | 置信度三档门控 + 灰色地带探测 + Read/Write 决策矩阵 | SuperClaude+GSD+planning-with-files 精华提取 |
| `.claude/rules/code-review-standards.md` | `**/*` | 四级 Severity + 结构化输出模板 + Summary 表格 + 审批标准 | code-reviewer 元素解剖精华提取 |

### Hooks（自造）

| 生态位 | 工具名 | 类型 | 综合分 | 用途 | 触发条件 |
|--------|--------|------|--------|------|----------|
| compact 前状态保存 | pre-compact-save.sh | Hook (PreCompact) | 基准 | 备份 MEMORY.md | 自动：context compact 前触发 |
| compact 后状态恢复 | post-compact-restore.sh | Hook (SessionStart/compact) | 基准 | 注入 MEMORY.md 到上下文 | 自动：compact 后新会话启动 |
| 自主迭代守卫 | stop-guard.sh | Hook (Stop) | 基准 | 阻止自主迭代中意外停止 | 自动：Stop 事件触发 |
| 文件修改追踪 | post-tool-dirty-tracker.sh | Hook (PostToolUse) | 基准 | 记录 Edit/Write/Bash 修改的文件 | 自动：PostToolUse 事件触发 |

### MCP

| 生态位 | 工具名 | 版本 | 综合分 | 用途 | 触发条件 |
|--------|--------|------|--------|------|----------|
| GitHub API | github-mcp-server | v0.31.0 | 基准 | 搜索仓库/代码、读文件、管理 Issues/PRs | 需要 GitHub API 操作时 |
| 社区资产检索 | distillery-mcp-server | v1.0.0 | 基准 | 4 工具（search/get_asset/similar/list_types）MCP 协议访问 distillery | Agent 程序化搜索社区资产时 |

### Plugin

| 名称 | 版本 | 用途 |
|------|------|------|
| superpowers | 4.3.0 | 方法论 Skills 集 |

## 淘汰名单（防重复搜索）

| 工具名 | 生态位 | 淘汰原因 | 日期 |
|--------|--------|----------|------|
| browser-use | 浏览器自动化 | Critical Risk (Gen + Snyk) | 2026-02-19 |
| remembering-conversations | 跨会话记忆 | 依赖 episodic-memory MCP，marketplace 不存在 | 2026-02-20 |
| strategic-compact | compact 策略 | 精华已提取（决策表），脚本 Windows 不兼容，只是计数器 | 2026-02-20 |
| continuous-learning | 会话学习 | 空壳（脚本不存在），精华已提取（Hooks>Skills 观测） | 2026-02-20 |
| iterative-retrieval | 渐进检索 | 纯概念模板无可执行代码，思想已融入 SOP 发散阶段 | 2026-02-20 |
| firecrawl | 深度爬取 | 需 API Key + 付费 credits，工作流决策模式已提取 | 2026-02-20 |
| web-reader (answerzhao) | 网页读取 | 绑定智谱 GLM SDK，与 Claude Code 无关，虚假描述 | 2026-02-20 |
| workflow-orchestration-patterns (wshobson) | 工作流编排 | 5.8/10 未达标，与 superpowers 重叠，插件框架不兼容 | 2026-02-20 |
| github-search (parcadei) | GitHub 搜索 | 27/100，GitHub MCP 已完全覆盖，有功能 bug，依赖私有 runtime | 2026-02-20 |
| rag-implementation (sickn33) | RAG 检索 | 目标分支不存在，无法审判 | 2026-02-20 |
| SuperClaude_Framework | 方法论框架 | 6.5/10，与 superpowers 高度重叠，精华已提取（ConfidenceChecker、ReflexionPattern） | 2026-02-20 |
| get-shit-done | 项目执行框架 | 7.5/10 未过 Delta Gate，与 coding.md+lead-discipline 重叠，精华已提取（Wave Execution、XML Task、Gray Area Probe） | 2026-02-20 |
| claude-flow | Swarm/RAG | 4.5/10，alpha 阶段，@ruvector 供应商锁定，Windows 不兼容 | 2026-02-20 |
| pinecone-claude-code-plugin | RAG/向量检索 | 4.8/10，100% 依赖 Pinecone 付费云服务，无离线模式，架构模式已提取 | 2026-02-20 |
| planning-with-files | 持久化规划 | 6.5/10，3-File Pattern 与三体架构冲突，精华已提取（3-Strike Protocol、2-Action Rule） | 2026-02-20 |
| claude-context (zilliztech) | RAG/向量检索 | 6.2/10，双重外部依赖（Zilliz Cloud + OpenAI），独立性 3/10，架构模式已提取 | 2026-02-20 |
| autodev-codebase | RAG/代码搜索 | 5.6/10，Qdrant Docker 硬依赖，三层服务架构过重，仅限代码搜索 | 2026-02-20 |
| 199-bio/claude-deep-research-skill | 深度研究 | 7.2/10 未过 Delta Gate，精华已提取（5 阶段 Pipeline、Anti-Hallucination、并行搜索编排） | 2026-02-20 |
| willccbb/claude-deep-research | 深度研究 | INCONCLUSIVE，GitHub API EOF 错误无法评估 | 2026-02-20 |
| standardhuman/deep-research-skill | 深度研究 | INCONCLUSIVE，GitHub API EOF 错误无法评估 | 2026-02-20 |

## 待填充生态位

| 生态位 | 状态 | 备注 |
|--------|------|------|
| 跨会话记忆 | MVP 已建 | 文件级 MEMORY.md + Hooks 自动备份/恢复，非向量检索 |
| 深度爬取 | 已封顶 | firecrawl 需 API Key，agent-browser + WebFetch 覆盖当前需求 |
| 深度研究 | **已填充** | 199-bio 精华内化为 `deep-research` Skill，5 阶段 Pipeline，零外部依赖 |
| RAG/向量检索 | **已填充** | Orama 8.0/10 + Vectra TextSplitter 内化为 `rag` Skill，零外部服务依赖 |
| 技术文档检索 | Skill 版已就绪 | context7 Skill（curl），MCP 版因 Node.js v24 fetch 问题淘汰 |
