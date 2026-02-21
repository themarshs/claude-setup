# 全量资产扫描报告 — 2,137 条全覆盖

> 扫描时间：2026-02-21 | 23 个来源仓库 | 8 个并行 Agent | 全量无遗漏

## 一、总体统计

| 类型 | 总量 | 去重后 | EXISTING | NEW-NICHE | 可忽略 |
|------|------|--------|----------|-----------|--------|
| Skill | 1,350 | 1,221 | ~135 (11%) | ~720 (59%) | ~366 (30%) |
| Agent | 435 | 329 | ~38 (12%) | ~175 (53%) | ~116 (35%) |
| Rule | 294 | 219 | ~16 (7%) | ~16 (7%) | ~187 (86%) |
| Hook | 7 | 1 | 0 | 2 新触发类型 | 5 |
| Claude-md | 51 | 1 | 1 | 4 有参考价值 | 46 |
| **合计** | **2,137** | **1,771** | **~190** | **~910+** | **~670+** |

## 二、我们武器库完全空白的新生态位（按价值排序）

### Tier-S: 必须补齐（核心能力空白）

| # | 生态位 | 最佳资产 | bodyLen | Stars | 为什么必须有 |
|---|--------|---------|---------|-------|-------------|
| 1 | **TDD/测试工作流** | tdd-workflow + e2e-runner + eval-harness | 9.8K+23K+5.2K | 48610 | coding.md 只一句 TDD，缺完整流程。7步红绿循环+Playwright E2E+EDD评估框架 |
| 2 | **上下文工程** | context-compression + context-degradation | 12K+15K | 13249 | MEMORY.md 只做存/读，完全缺失压缩策略和退化检测。5种退化模式+锚定式迭代摘要 |
| 3 | **架构设计** | architect + planner (Agent) | - | 48610 | 我们有"怎么做"但没有"做什么/为什么"。4阶段+ADR模板+8反模式检测 |
| 4 | **Prompt 工程** | prompt-engineer + prompt-factory | 10K+37K | 28955/518 | 作为"AI编码系统"最不应该缺的能力。11种框架+69预设角色 |
| 5 | **并行调试** | parallel-debugging | 4.5K | 28955 | 与 error-discipline(线性3-Strike) 完全不同范式。ACH多假设竞争+证据强度分级 |
| 6 | **Git 工作流** | common-git-workflow (Rule) + git-master (Agent) | - | 48610/6795 | 日常最高频操作，完全空白。conventional commits+原子分割+风格检测 |
| 7 | **Tool/Agent 设计方法论** | tool-design | 15.7K | 13249 | 元能力——提升所有Skill/Tool设计质量。合并原则+架构精简+Description Engineering |

### Tier-A: 强烈推荐补齐

| # | 生态位 | 最佳资产 | bodyLen | Stars | 说明 |
|---|--------|---------|---------|-------|------|
| 8 | **API 设计规范** | api-design | 13.4K | 48610 | REST设计+状态码+分页+限流，三语言模板。通用性极高 |
| 9 | **Docker/容器化** | docker-patterns + deployment-patterns | 8.4K+11K | 48610 | 开发基础设施标配，多阶段Dockerfile+安全加固+网络隔离 |
| 10 | **数据库专精** | database-reviewer (Agent) | 18.5K | 48610 | PostgreSQL百科：索引选择矩阵+RLS优化+并发模式 |
| 11 | **依赖管理** | dependency-management (Rule) | - | 506 | License Compliance是盲区，security-gate的天然延伸 |
| 12 | **多Agent团队协作** | team (Skill) | 41.8K | 6795 | 完整N-Agent编排：worktree隔离+5阶段pipeline+消息通信 |
| 13 | **Office文档生成** | docx/pdf/pptx/xlsx | 16K/7.8K/8.5K/10.7K | Anthropic官方 | 官方出品，文档输出能力完全空白 |
| 14 | **代码重构/技术债** | refactor-cleaner + code-refactoring-tech-debt | 8K+10K | 48610 | knip/depcheck工具链+ROI量化+债务预算 |
| 15 | **并行Agent调度** | dispatching-parallel-agents | 6.1K | 28955 | 与handoff-protocol(串行)形成互补 |
| 16 | **命名规范** | naming (Rule) | 3.1K | 506 | 多语言命名规范，减少AI代码风格不一致 |
| 17 | **文档规范** | documentation (Rule) | - | 506 | "What NOT to Document"防止AI过度文档化 |

### Tier-B: 按需引入

| # | 生态位 | 最佳资产 | Stars | 说明 |
|---|--------|---------|-------|------|
| 18 | ADR架构决策记录 | architecture-decision-records | 13249 | 5套模板+生命周期管理 |
| 19 | LLM成本控制 | cost-aware-llm-pipeline | 48610 | 模型路由+预算追踪+Prompt缓存 |
| 20 | 安全渗透测试 | top-web-vulnerabilities + Trail of Bits 15个 | 13249/0 | 从防御扩展到攻击闭环 |
| 21 | DevOps/SRE | devops-troubleshooter + incident-responder | 28955 | 10大能力域+P0-P3分级+事故响应 |
| 22 | C4架构文档 | c4-architecture (5件套) | 28955 | 自下而上架构图自动生成 |
| 23 | 产品管理 | product-manager ("Athena") | 6795 | WHY/WHAT层，PRD生成+KPI树 |
| 24 | DDD领域驱动 | ddd-strategic/tactical/context-mapping | 28955 | 中大型项目架构方法论 |
| 25 | 项目编排(Conductor) | conductor-* (7件套) | 13249 | 完整项目管理框架 |
| 26 | 可观测性 | observability-engineer + prometheus + grafana | 28955/13249 | OpenTelemetry全栈 |
| 27 | CI/CD自动化 | github-workflow-automation | 13249 | 完整管线生成 |
| 28 | Diagramming | excalidraw + mermaid-diagrams | 624/13249 | subagent隔离节省97%context |
| 29 | LLM应用模式 | llm-app-patterns | 13249 | RAG/Agent/Prompt IDE/LLMOps |
| 30 | Kaizen持续改进 | kaizen | 13249 | 防错+标准化+JIT方法论 |
| 31 | Fuzzing安全测试 | harness-writing + 14个Trail of Bits | 0(官方) | 完整fuzzing生命周期 |
| 32 | 生产代码审计 | production-code-audit | 13249 | 5维度全码库扫描+自动修复 |
| 33 | 事件溯源/CQRS | event-sourcing-architect + event-store-design | 28955 | 特定架构模式 |
| 34 | GitHub取证 | github-archive | 1129 | BigQuery取证+已删除内容恢复 |

### Tier-C: 利基/领域特化（需要时再取）

| 领域 | 资产数 | 说明 |
|------|--------|------|
| SaaS自动化集成 | 50+ | Gmail/Jira/Slack/Shopify/Stripe等平台API |
| 语言/框架专精 | 60+ | Python/Go/Rust/Java/Swift/React/Next.js/NestJS |
| 前端UI/设计系统 | 20+ | Tailwind/Radix/响应式/无障碍 |
| ML/MLOps | 10+ | 模型训练/部署/向量数据库 |
| 游戏开发 | 8 | Unity/Unreal/Three.js/Godot |
| 商业/营销 | 15+ | 创业分析/广告/邮件序列/KPI |
| 区块链安全 | 8 | 6条链漏洞扫描器 |
| n8n工作流 | 3 | 低代码自动化平台 |
| 移动端 | 5 | Android/iOS/React Native |
| 网络工程 | 5 | mTLS/网络基础 |

## 三、已有生态位中发现的强竞品

### 红色警报（可能超越我们现有工具）

| 我们的工具 | 竞品 | bodyLen | Stars | 威胁分析 |
|-----------|------|---------|-------|---------|
| self-learning | continuous-learning-v2 | 8.1K | 48610 | 原子本能+Hooks观测+置信度衰减，架构领先一代 |
| writing-skills | testing-skills-with-subagents | 12.9K | 13249 | "TDD for Skills"方法论，我们完全缺失 |
| code-review | code-review-ai-ai-review | 15.7K | 13249 | 多工具静态分析+AI路由+CI/CD集成，远超现有 |
| security-gate | security-reviewer (Agent) | 14.8K | 48610 | 14K字符安全审查Agent，比我们1.5K Rule深10倍 |

### 黄色关注（值得元素解剖提取精华）

| 我们的工具 | 竞品 | bodyLen | Stars | 可提取精华 |
|-----------|------|---------|-------|-----------|
| MEMORY.md | context-compression | 12.3K | 13249 | 锚定式迭代摘要+probe-based评估 |
| MEMORY.md | context-degradation | 15.6K | 13249 | 5种退化模式+模型阈值表 |
| MEMORY.md | memory-systems | 13K | 13249 | 5层记忆架构+DMR基准数据 |
| agent-browser | playwright-skill | 13.9K | 13249 | 自动dev server检测+多视口+HTTP Headers |
| agent-browser | computer-use-agents | 9.2K | 13249 | 全桌面控制+Docker沙箱 |
| rag | embedding-strategies | 15.2K | 13249 | 嵌入模型选型+5种chunking策略 |
| rag | vector-index-tuning | 15.6K | 28955 | 向量索引调优 |
| skill-judge | skill-judge (softaworks) | 30.3K | 624 | E:A:R分类+Freedom Calibration+9失败模式 |
| deep-research | wiki-researcher | - | 13249 | 证据标准表+多轮视角切换 |
| handoff-protocol | dispatching-parallel-agents | 6.1K | 28955 | 并行分发模式 |
| error-discipline | build-error-resolver | 12.6K | 48610 | 构建错误专项 |

## 四、Hook 新发现

| 触发类型 | 我们有否 | 社区模式 | 价值 |
|----------|---------|---------|------|
| PreToolUse:Edit/Write | 无 | branch guard (阻止写main分支) | **P0** — 红线从纪律升级为硬阻断 |
| UserPromptSubmit | 无 | 自动读MEMORY.md/prompt路由 | **P1** — 替代靠纪律的唤醒流程 |
| PostToolUse:Edit | 有(dirty-tracker) | auto-format/auto-test/auto-typecheck | **P2** — 代码质量自动化 |

## 五、Claude-md 新发现

| 社区模式 | 来源 | 我们有否 | 价值 |
|---------|------|---------|------|
| Intent Gate（每条消息分类） | jarrodwatts | 缺 | 高 |
| BANNED tools 清单 | centminmod | 缺 | 中 |
| Anti-Patterns (BLOCKING) 标签 | jarrodwatts | 缺 | 中 |
| Hard Blocks vs Soft Guidelines 分级 | jarrodwatts | 缺 | 中 |
| Evidence Requirements（完成证据） | jarrodwatts | 缺 | 中 |

## 六、我们的独有资产（社区无对标）

| 资产 | 为什么独有 |
|------|-----------|
| error-discipline.md | Agent行为纪律(3-Strike升级)，社区全是代码级错误处理 |
| confidence-gate.md | 执行前置信度门控，社区无同类 |
| distillery-mcp-server | 社区资产程序化检索MCP，独家 |
| 三体文件架构 (CLAUDE+MEMORY+ARMORY) | 社区有Memory Bank但没有三体分工 |
| 4道棘轮 (Delta Gate/Highlander等) | 社区无类似的自进化约束机制 |
| 螺旋SOP 6步 | 社区有Phase系统但不是工具评估螺旋 |
| compact前后Hook对 | 社区无状态保存/恢复Hook |

## 七、行动建议优先级总排序

### P0: 立即行动（核心能力空白）

1. TDD工作流 — tdd-workflow + eval-harness
2. 上下文工程 — context-compression + context-degradation
3. Git工作流 — common-git-workflow (Rule) + git-master
4. PreToolUse Hook — 红线硬阻断
5. Prompt工程 — prompt-engineer
6. 并行调试 — parallel-debugging
7. 架构设计 — architect + planner (Agent)
8. Tool设计方法论 — tool-design

### P1: 近期补齐

9. API设计规范 — api-design
10. Docker/容器化 — docker-patterns
11. 数据库专精 — database-reviewer
12. 依赖管理 — dependency-management (Rule)
13. 命名规范 — naming (Rule)
14. 文档规范 — documentation (Rule)
15. 多Agent团队 — team
16. 代码重构 — refactor-cleaner
17. 并行Agent调度 — dispatching-parallel-agents
18. Office文档 — docx/pdf/pptx/xlsx (Anthropic官方)

### P2: 按需引入

19-34: ADR/LLM成本/安全攻防/DevOps/C4架构/产品管理/DDD/Conductor/可观测性/CI-CD/Diagramming/LLM应用/Kaizen/Fuzzing/生产审计/事件溯源

### P3: 需要时再取（60+ 个利基生态位）

SaaS集成/语言框架/前端设计/ML-MLOps/游戏/商业营销/区块链/移动端等
