---
name: feature-dev
description: "7-phase feature development pipeline with hard gates: Discovery→Explore→Questions→Design→Implement→Review→Summary. Multi-agent codebase exploration, tri-philosophy architecture comparison, confidence-scored review. WHAT: end-to-end feature lifecycle orchestration. WHEN: new features touching multiple files, unclear requirements, architectural decisions needed. KEYWORDS: feature development, architecture design, codebase exploration, code review, implementation workflow, multi-phase pipeline"
---

# Feature Development Pipeline

> 来源：anthropics/claude-plugins-official feature-dev 插件精华提取
> 与 multi-agent-team 互补：本 Skill 定义功能生命周期（WHAT phases），multi-agent-team 提供派发机制（HOW to dispatch）

## 7 阶段 Pipeline + 硬门控

```
Phase 1: Discovery ──gate──> Phase 2: Explore ──gate──> Phase 3: Questions
    |                            |                           |
    v                            v                           v
  需求确认                    并行探索 Agent               硬门控：必须等用户回答
  (用户确认理解正确)           (2-3 explorer)              才能进入设计阶段
                              产出：关键文件列表
                              Lead 必须读完才进下阶段

Phase 3 ──gate──> Phase 4: Design ──gate──> Phase 5: Implement ──gate──> Phase 6: Review ──> Phase 7: Summary
                      |                        |                            |
                      v                        v                            v
                  三哲学对比                  显式审批门                   3 reviewer 并行
                  (2-3 architect)            用户说 GO 才动手              置信度 >=80 过滤
                  用户选方案                  不可自行决定
```

### 阶段门控条件（不可跳过）

| 过渡 | 门控条件 | 违反后果 |
|------|---------|---------|
| 1→2 | 用户确认需求理解正确 | 探索方向错误，浪费 agent 算力 |
| 2→3 | Lead 已读完 agent 返回的所有关键文件 | 问不出有深度的问题 |
| 3→4 | 用户回答了所有澄清问题 | 架构设计基于假设，后续返工 |
| 4→5 | 用户选定了具体方案 | 实现无锚点，随意漂移 |
| 5→6 | 实现完成 + 基础验证通过 | 审查半成品无意义 |
| 6→7 | 用户对审查发现做出决策（修/不修/延后） | 悬而未决的 issue 被遗忘 |

**CRITICAL: Phase 3 是最重要的阶段。不可跳过。在理解了代码库之后、设计架构之前，必须识别所有模糊点并等用户回答。**

## Agent 派发配方

### Phase 2: Codebase Exploration（2-3 explorer agents 并行）

每个 agent 探索不同维度，必须返回 5-10 个关键文件路径：

```
Explorer-A: "找到与 [feature] 类似的已有功能，追踪其完整实现路径"
Explorer-B: "映射 [feature area] 的架构层和抽象模式，追踪控制流"
Explorer-C: "分析 [related existing feature] 的当前实现，追踪关键路径"
```

**回读规则**：agent 完成后，Lead 必须用 Read 工具读完所有 agent 标记的关键文件，构建深层理解后才能进入 Phase 3。不读 = 不进。

### Phase 4: Architecture Design（2-3 architect agents 并行，各执一词）

三种哲学，各自独立设计，产出比较矩阵：

| 哲学 | Agent 指令 | 适用场景 |
|------|-----------|---------|
| **Minimal** | 最小变更，最大复用已有代码 | 紧急修复、低风险增量 |
| **Clean** | 可维护性优先，优雅抽象 | 核心模块、长期维护的功能 |
| **Pragmatic** | 速度 + 质量平衡 | 大多数日常功能开发 |

Lead 审查后必须形成推荐意见（附理由），但最终由用户选择。

### Phase 6: Quality Review（3 reviewer agents 并行，不同聚焦）

```
Reviewer-A: 简洁性 / DRY / 可读性
Reviewer-B: Bug / 逻辑错误 / 功能正确性
Reviewer-C: 项目规范 / 抽象模式 / 一致性
```

### Reviewer 置信度刻度（校准标准）

| 分数 | 含义 | 是否报告 |
|------|------|---------|
| 0 | 误报 / 已有问题不是本次引入 | 不报 |
| 25 | 可能是问题，也可能是误报 | 不报 |
| 50 | 真问题但不重要 / nitpick | 不报 |
| 75 | 已验证的真问题，会影响功能 | 不报 |
| 80+ | 高确信 + 高影响 | **报告** |
| 100 | 绝对确定，证据确凿 | 报告 |

**阈值 >=80**：只报告高确信问题，质量优于数量。

## Phase 3 澄清问题清单模板

每次进入 Phase 3 时，扫描以下维度寻找模糊点：

```
1. 边界条件：输入范围限制？空值/零值/最大值行为？
2. 错误处理：失败时的用户体验？重试策略？降级方案？
3. 集成点：与哪些现有模块交互？API 契约？
4. 向后兼容：是否影响现有用户？迁移策略？
5. 性能需求：响应时间目标？数据量级？
6. 作用域边界：明确不做什么？排除哪些场景？
7. 设计偏好：用户对实现方式有偏好吗？
```

用户说"你决定就好"时：给出推荐 + 理由，获得明确确认后才继续。

## 与现有 Skill 的协作关系

```
feature-dev（本 Skill）= 功能生命周期编排器（7 阶段 WHAT）
    |
    |-- Phase 2/4/6 的 agent 派发 → 使用 multi-agent-team 的派发机制（HOW）
    |-- Phase 5 的实现 → 使用 tdd-workflow 的红绿循环（测试策略）
    |-- Phase 4 的多方案 → 使用 superpowers:brainstorming 的发散思维
    |-- Phase 5 的计划 → 使用 superpowers:writing-plans 的计划编写
    |-- Phase 2 的子 agent → 使用 superpowers:subagent-driven-development
```

### 职责边界

| Skill | 管什么 | 不管什么 |
|-------|--------|---------|
| **feature-dev** | 功能从需求到交付的 7 阶段流转 | 不管 agent 如何派发、测试如何写 |
| **multi-agent-team** | agent 如何并行、文件所有权、消息通信 | 不管功能开发的阶段逻辑 |
| **tdd-workflow** | 测试如何写、红绿循环、flaky 隔离 | 不管功能设计和架构决策 |

### 7 阶段 vs 5 阶段的区别

```
feature-dev 7 阶段 = 产品生命周期
  Discovery → Explore → Questions → Design → Implement → Review → Summary
  （从"要做什么"到"做完了"）

multi-agent-team 5 阶段 = 执行机制
  plan → prd → exec → verify → fix
  （单个实现任务的执行循环）

关系：feature-dev 的 Phase 5（Implement）内部可以使用 multi-agent-team 的 5 阶段
```

## 适用性决策

```
新功能，触及多个文件，需求有模糊点？
  → feature-dev（完整 7 阶段）

需求明确，纯执行，多 agent 协作？
  → multi-agent-team（直接进入 5 阶段执行）

单文件 bug 修复 / trivial 变更？
  → 都不用，直接改

写测试 / 调试 flaky / 设置 eval？
  → tdd-workflow
```

## NEVER

1. NEVER 跳过 Phase 3 -- 澄清问题是防止返工的最廉价手段
2. NEVER 在 Phase 5 未获用户审批就开始实现 -- 这是硬门控
3. NEVER 让 architect agent 看到彼此的方案 -- 各自独立设计才有对比价值
4. NEVER 报告置信度 <80 的审查发现 -- 噪声比信号有害
5. NEVER 跳过 Phase 2 的回读 -- agent 的关键文件列表必须被 Lead 读完
6. NEVER 在 Phase 4 不给推荐就让用户选 -- Lead 必须有观点
7. NEVER 把 7 阶段当 checklist 走形式 -- 每个阶段的门控条件必须实质性满足
8. NEVER 在用户说"你决定"时直接做 -- 给推荐，等确认
