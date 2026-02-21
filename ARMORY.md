# ARMORY.md — 武器库注册表

> 最后更新：2026-02-21 全量扫描 2,137 条 → 三波锻造 + 双螺旋进化机制
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
| 知识进化 | knowledge-evolution | Skill | v2.0 | Hooks观测管道+4类模式检测+置信度衰减+来源分层+导入导出 | 螺旋 SOP 元回顾阶段 |
| 发散搜索 | hunt | Skill | 基准 | 4 步渐进搜索 + 反偏见检查 + 结构化评估 | 螺旋 SOP 发散阶段 |
| 语义检索 | rag | Skill | 8.0 | Orama 混合搜索 + Vectra TextSplitter 19 语言分块 | 代码/文档语义搜索时 |
| 深度研究 | deep-research | Skill | 7.2 | 5 阶段 Pipeline + 并行搜索 + 交叉验证 + Anti-Hallucination | 技术比较/行业分析/竞品调研时 |
| 检索方法论 | retrieval-methodology | Skill | 基准 | 意图分类 + 通道选择 + 搜索策略 + 交叉验证协议 | 任何搜索动作前加载 |
| TDD 工作流 | tdd-workflow | Skill | 基准 | 红绿循环决策树 + Playwright flaky 隔离 + EDD 评估框架 | 写功能代码前/测试策略决策时 |
| 上下文工程 | context-engineering | Skill | 基准 | 5 种退化模式 + 压缩策略决策树 + tokens-per-task 优化 | compact/长会话/上下文管理时 |
| Prompt 工程 | prompt-engineering | Skill | 基准 | 7 框架选择矩阵 + Claude XML 优化 + Description Engineering | 设计 prompt/Skill 描述时 |
| Tool 设计 | tool-design | Skill | 基准 | 合并原则 + 架构精简 + Description Engineering + MCP 命名 | 设计 Skill/Tool/Agent 时 |
| 并行调试 | parallel-debugging | Skill | 基准 | ACH 多假设竞争 + 证据强度分级 + 3-Strike 集成 | 复杂 bug 多假设时 |
| API 设计 | api-design | Skill | 基准 | URL 决策表 + HTTP 方法矩阵 + 分页决策树 + 限流分级 | 设计 REST API 时 |
| Docker 模式 | docker-patterns | Skill | 基准 | 多阶段 Dockerfile + 安全加固 + 网络隔离 + 部署策略 | 容器化/部署时 |
| 数据库专精 | database-expertise | Skill | 基准 | 索引选择矩阵 + Schema 反模式 + RLS 优化 + 并发模式 | PostgreSQL/数据库设计时 |
| 多 Agent 团队 | multi-agent-team | Skill | 基准 | 并行派发 + 文件所有权 + 5 阶段 pipeline + 消息通信 | 2+ Agent 协作任务时 |
| 代码重构 | code-refactoring | Skill | 基准 | knip/depcheck 工具链 + SAFE/CAREFUL/RISKY 分级 + 债务预算 | 重构/技术债清理时 |
| Office 文档 | office-documents | Skill | 基准 | docx/xlsx/pdf/pptx 生成 + OOXML 结构 + 模板模式 | 生成 Office 文档时 |
| Skill 测试 | skill-testing | Skill | 基准 | TDD for Skills：7种压力类型+合理化捕获+防弹判定 | 写/编辑 Skill 后验证时 |
| MCP 开发 | mcp-development | Skill | 基准 | @modelcontextprotocol/sdk stdio 开发：Transport决策+4 Primitive+Tool设计+调试+注册 | 构建 MCP Server 时 |
| 螺旋自举 | spiral-bootstrap | Skill | 基准 | 双螺旋进化编排器：L1-L4分级响应+痛觉信号表+STALE缓存失效+方法论绑定 | 检索摩擦/重复查询/空结果时 |
| 进化会话 | evolution-session | Skill | 基准 | 独立进化夜班执行器：读工单+锻造工具+绑定路由，纯L3上下文 | `/evolve` 或处理 overnight-plan 工单时 |
| 自循环迭代 | ralph-loop | Skill | 基准 | Stop Hook自循环+完成信号匹配+迭代安全阀，无人值守执行 | TDD循环/greenfield构建/批量重构需无人值守时 |
| 声明式Hook | hookify | Skill | 基准 | Markdown+YAML声明式Hook规则+6种operator+block/warn双模式 | 新增模式匹配Hook规则时 |

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
| 架构设计 | architect | Agent (read-only) | 基准 | 4 阶段工作流 + ADR 模板 + 8 反模式检测 | 架构决策/系统设计时 |
| 安全深审 | security-reviewer | Agent (read-only) | 基准 | OWASP深度审查+语言特定模式(JS/Py/Go)+严重性SLA+紧急响应 | 高风险变更/安全审计时 |

### Rules（模块化规则）

| 文件 | glob 匹配 | 内容 | 来源 |
|------|-----------|------|------|
| `.claude/rules/coding.md` | `**/*.{ts,tsx,js,jsx,py,go,rs,java,sh}` | 5 条黄金法则 + TDD + 上下文效率 + 三层架构 | 16 个高星仓库（67k+ stars）|
| `.claude/rules/lead-discipline.md` | `**/*` | Lead 角色约束：不亲自干活、先搜再建、防偏离 | 用户纠正后内化 |
| `.claude/rules/handoff-protocol.md` | — | Agent 交接协议：Handoff 文档格式 + Verdict 三档判定 | everything-claude-code 精华提取 |
| `.claude/rules/error-discipline.md` | `**/*` | 3-Strike 升级 + 错误持久化 + 2-Action 写入 + 防重复失败 | SuperClaude+GSD+planning-with-files 精华提取 |
| `.claude/rules/confidence-gate.md` | `**/*` | 置信度三档门控 + 灰色地带探测 + Read/Write 决策矩阵 | SuperClaude+GSD+planning-with-files 精华提取 |
| `.claude/rules/code-review-standards.md` | `**/*` | 四级 Severity + 结构化输出模板 + Summary 表格 + 审批标准 | code-reviewer 元素解剖精华提取 |
| `.claude/rules/security-gate.md` | `**/*` | 预提交安全清单 + 密钥管理 + 漏洞响应 | 社区 3 仓库共识（48.6K+13.2K+6.8K）|
| `.claude/rules/git-workflow.md` | `**/*` | Conventional Commits + 原子分割 + PR 工作流 + 分支保护 | everything-claude-code + oh-my-claudecode 精华 |
| `.claude/rules/dependency-management.md` | `**/*` | Pre-add 清单 + 版本锁定 + License Compliance + 审计 | awesome-claude-code-toolkit 精华 |
| `.claude/rules/naming.md` | `**/*` | JS/TS/Python/DB 多语言命名规范 | awesome-claude-code-toolkit 精华 |
| `.claude/rules/documentation.md` | `**/*` | What to/NOT to document + 注释原则 | awesome-claude-code-toolkit 精华 |

### Hooks（自造）

| 生态位 | 工具名 | 类型 | 综合分 | 用途 | 触发条件 |
|--------|--------|------|--------|------|----------|
| compact 前状态保存 | pre-compact-save.sh | Hook (PreCompact) | 基准 | 备份 MEMORY.md | 自动：context compact 前触发 |
| compact 后状态恢复 | post-compact-restore.sh | Hook (SessionStart/compact) | 基准 | 注入 MEMORY.md 到上下文 | 自动：compact 后新会话启动 |
| 自主迭代守卫 | stop-guard.sh | Hook (Stop) | 基准 | 阻止自主迭代中意外停止 | 自动：Stop 事件触发 |
| 文件修改追踪 | post-tool-dirty-tracker.sh | Hook (PostToolUse) | 基准 | 记录 Edit/Write/Bash 修改的文件 | 自动：PostToolUse 事件触发 |
| 红线硬阻断 | pre-tool-guard.sh | Hook (PreToolUse) | 基准 | 阻止写 mcp-servers/ + 警告写 main 分支 | 自动：Edit/Write 前触发 |
| 自动唤醒 | prompt-submit.sh | Hook (UserPromptSubmit) | 基准 | 会话首 prompt 自动读 MEMORY.md 前 30 行 | 自动：用户提交 prompt 时 |
| 痛觉检测 | pain-tracker.sh | Hook (PostToolUse) | 基准 | 滑动窗口检测重复搜索+写入痛觉账本 | 自动：搜索类工具调用后触发 |

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
| TDD/测试工作流 | **已填充** | tdd-workflow Skill，红绿循环+Playwright+EDD |
| 上下文工程 | **已填充** | context-engineering Skill，5种退化模式+压缩策略 |
| Prompt 工程 | **已填充** | prompt-engineering Skill，7框架+Description Engineering |
| Tool 设计方法论 | **已填充** | tool-design Skill，合并原则+架构精简 |
| 并行调试 | **已填充** | parallel-debugging Skill，ACH多假设+证据分级 |
| 架构设计 | **已填充** | architect Agent，4阶段+ADR+8反模式 |
| Git 工作流 | **已填充** | git-workflow Rule，Conventional Commits+原子分割 |
| API 设计 | **已填充** | api-design Skill，URL决策表+HTTP矩阵+分页+限流 |
| Docker/容器化 | **已填充** | docker-patterns Skill，多阶段+安全加固+网络隔离 |
| 数据库专精 | **已填充** | database-expertise Skill，索引矩阵+RLS+并发 |
| 依赖管理 | **已填充** | dependency-management Rule，License Compliance+审计 |
| 命名规范 | **已填充** | naming Rule，多语言命名规范 |
| 文档规范 | **已填充** | documentation Rule，What NOT to Document |
| 多Agent团队 | **已填充** | multi-agent-team Skill，并行派发+文件所有权 |
| 代码重构 | **已填充** | code-refactoring Skill，knip/depcheck+债务预算 |
| Office文档 | **已填充** | office-documents Skill，docx/xlsx/pdf/pptx |
| 红线硬阻断 | **已填充** | pre-tool-guard Hook，PreToolUse阻断 |
| 自动唤醒 | **已填充** | prompt-submit Hook，UserPromptSubmit |
| 螺旋自举 | **已填充** | spiral-bootstrap Skill，L1-L4分级+痛觉信号+STALE缓存 |
| 进化执行 | **已填充** | evolution-session Skill，独立夜班+工单+路由绑定 |
| 痛觉检测 | **已填充** | pain-tracker Hook，滑动窗口重复搜索检测 |
| 自循环迭代 | **已填充** | ralph-loop Skill，Stop Hook自循环+完成信号+安全阀 |
| 声明式Hook | **已填充** | hookify Skill，Markdown声明式规则+条件引擎 |
