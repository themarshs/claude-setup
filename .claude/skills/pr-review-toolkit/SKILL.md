---
name: pr-review-toolkit
description: "WHAT: Multi-perspective PR review orchestrator — dispatches 6 specialized review lenses (code/test/error/type/comment/simplify) with intelligent routing, confidence scoring, and aggregation. WHEN: Use when performing comprehensive PR review, when needing deep specialized analysis beyond general code-reviewer, or when orchestrating parallel review agents. KEYWORDS: pr review, multi-agent review, test coverage, silent failure, type design, comment rot, code simplify, review orchestration"
---

# PR Review Toolkit — Multi-Perspective Review Orchestrator

> 来源：anthropics/claude-plugins-official (Daisy@Anthropic)
> 精华提取：6 Agent 架构 + 编排逻辑 + 专家评分体系
> 与 requesting-code-review Skill 互补（见底部关系图）

## 六视角审查矩阵

每个视角是一个独立的审查 Agent，各有专属检测域和评分体系。编排者根据变更内容智能选择启动哪些视角。

| # | 视角 | 检测域 | 何时启动 | 评分 |
|---|------|--------|----------|------|
| 1 | **code-reviewer** | CLAUDE.md 合规、bug、代码质量 | 永远启动 | 0-100 置信度，≥80 才报 |
| 2 | **pr-test-analyzer** | 行为覆盖、关键缺口、测试韧性 | 有测试文件变更 或 新增功能 | 1-10 criticality |
| 3 | **silent-failure-hunter** | 静默失败、catch 块、fallback 行为 | 有 try/catch 或 错误处理变更 | CRITICAL/HIGH/MEDIUM |
| 4 | **type-design-analyzer** | 封装、不变量表达/有用性/强制性 | 新增或修改类型定义 | 4 维各 1-10 |
| 5 | **comment-analyzer** | 注释准确性、腐化、技术债 | 新增或修改文档/注释 | 定性（Critical/Improvement/Removal） |
| 6 | **code-simplifier** | 清晰度、冗余、可维护性 | 其他视角通过后做 polish | 定性 |

## 编排决策树

```
PR 变更进入
    │
    ├─ 1. 计算变更规模
    │   ├─ >1000 行 → 浅审模式，仅启动 #1+#3，建议拆分
    │   ├─ 200-1000 行 → 标准模式，按内容选视角
    │   └─ <200 行 → 深审模式，全部视角可用
    │
    ├─ 2. 内容感知选择（扫描 git diff --stat）
    │   ├─ 检测到 test 文件 → 启动 #2
    │   ├─ 检测到 try/catch/error → 启动 #3
    │   ├─ 检测到 type/interface/class 定义 → 启动 #4
    │   ├─ 检测到注释/文档变更 → 启动 #5
    │   └─ #1 永远启动
    │
    ├─ 3. 并行 vs 顺序决策
    │   ├─ 用户要求快速 → 全部并行（Task tool 同时派发）
    │   └─ 默认 → 顺序派发（#1→#3→#2→#4→#5→#6）
    │
    └─ 4. 聚合结果
        ├─ Critical Issues (must fix) — 来自所有视角的 CRITICAL/90+
        ├─ Important Issues (should fix) — HIGH/80-89
        ├─ Suggestions (nice to have) — MEDIUM 以下
        └─ Positive Observations — 做得好的部分
```

## 视角 1: Code Reviewer — 置信度评分体系

**评分刻度（0-100，仅报 ≥80）**：
- 91-100：CRITICAL — 确定的 bug 或明确违反 CLAUDE.md
- 80-90：IMPORTANT — 需要关注的质量问题
- 51-79：不报 — 降噪，避免低价值 nitpick
- 0-50：不报 — 可能误判或预存问题

**激进过滤规则**：宁可漏报也不误报。质量 > 数量。

## 视角 2: Test Analyzer — 行为覆盖优先

**核心原则**：测试行为和契约，不测实现细节。

**Criticality 分级（1-10）**：
- 9-10：可导致数据丢失、安全漏洞、系统崩溃的未覆盖路径
- 7-8：可导致用户可见错误的业务逻辑未覆盖
- 5-6：边界情况未覆盖，可能导致混淆或小问题
- 3-4：完整性补充，nice-to-have
- 1-2：可选的微小改进

**关键检测项**：
- 未测试的错误处理路径（可致静默失败）
- 缺失的边界条件覆盖
- 未覆盖的关键业务逻辑分支
- 缺失的负面测试（验证逻辑的拒绝路径）
- 异步/并发行为的未覆盖场景

**测试质量评估**：
- DAMP 原则（Descriptive and Meaningful Phrases）> DRY
- 是否能在合理重构后仍然捕获回归？
- 是否测试的是行为而非实现？

## 视角 3: Silent Failure Hunter — 五步猎杀流程

这是最具专家价值的视角。检测那些"代码能跑但吞掉了错误"的情况。

### 猎杀流程

**Step 1 — 定位所有错误处理代码**：
扫描 try-catch / error callback / 条件错误分支 / fallback 逻辑 / optional chaining / null coalescing

**Step 2 — 逐个审问**（每个处理点问 5 个问题）：
1. 日志质量：错误是否用合适严重度记录？包含足够上下文？6 个月后能调试吗？
2. 用户反馈：用户是否收到可操作的反馈？
3. Catch 特异性：是否只捕获预期异常？会意外吞掉哪些非预期异常？
4. Fallback 合理性：fallback 是否隐藏了真正问题？用户是否知道自己看到的是降级结果？
5. 传播正确性：这个错误应该在这里被捕获，还是应该冒泡到上层？

**Step 3 — 审问错误消息**：
是否用非技术语言（when appropriate）？是否提供可操作的下一步？是否足够具体？

**Step 4 — 搜索隐藏失败模式**（必查清单）：
| 模式 | 危害 | 检测方法 |
|------|------|----------|
| 空 catch 块 | 完全吞掉错误 | 搜索 `catch` 后无语句 |
| catch-log-continue | 记录了但继续执行损坏状态 | catch 内只有 console.log |
| 返回 null/undefined/默认值 | 调用者不知道出错了 | 搜索 catch 内 return null |
| optional chaining 掩盖 | `foo?.bar?.baz` 静默跳过 | 审查 `?.` 链是否掩盖应报错的情况 |
| Fallback chain | 逐级降级但不告知 | 搜索多级 try 或 `||` chain |
| Retry 耗尽 | 重试完了但不通知用户 | 搜索 retry 逻辑的最终失败路径 |
| Mock 降级 | 生产环境 fallback 到 mock 数据 | 搜索非 test 文件中的 mock/fake/stub |

**Step 5 — 比对项目标准**：
确认符合项目的错误处理规范（CLAUDE.md / error-discipline.md）。

## 视角 4: Type Design Analyzer — 四维评分

**评估框架**（每维 1-10 分）：

| 维度 | 评估要点 |
|------|----------|
| **封装性** | 内部实现是否隐藏？不变量能否从外部被违反？接口是否最小且完备？ |
| **不变量表达** | 不变量是否通过类型结构本身就能看出？是否在编译期强制（可能的话）？ |
| **不变量有用性** | 是否防止真实 bug？是否与业务需求对齐？太严还是太松？ |
| **不变量强制性** | 构造时是否检查？所有修改点是否都有守卫？是否不可能创建无效实例？ |

**类型反模式清单**（必须标记）：
- **贫血领域模型**：只有数据没有行为的类型
- **暴露可变内部**：返回内部可变引用
- **文档式不变量**：不变量只存在于注释中，代码不强制
- **责任过重**：一个类型做太多事
- **外部依赖维护**：依赖外部代码维持自身不变量
- **不一致的修改守卫**：有些 setter 检查有些不检查

**核心原则**：Make illegal states unrepresentable（让非法状态不可表示）。

## 视角 5: Comment Analyzer — 注释腐化检测

**核心方法**：交叉验证——每条注释声明都必须与实际代码对照验证。

**检查清单**：
1. 函数签名是否与文档的参数/返回类型一致？
2. 描述的行为是否与代码逻辑吻合？
3. 引用的类型/函数/变量是否存在且正确使用？
4. 声称处理的边界情况是否真的在代码中处理了？
5. 性能/复杂度声明是否准确？

**价值判断**：
- 解释 "why" 的注释 >> 解释 "what" 的注释
- 随代码变更可能过时的注释 → 标记风险
- 复述显而易见代码的注释 → 建议删除

## 视角 6: Code Simplifier — 执行约束

**核心约束**：只改 HOW，不改 WHAT。所有原始功能必须保留。

**禁止的"简化"**：
- 嵌套三元运算 → 用 switch/if-else 替代
- 密集单行 → 清晰度优先于行数
- 过度合并 → 不把多个关注点塞进一个函数
- 移除"有帮助的"抽象 → 不以 fewer files 为目标

## 聚合输出模板

```markdown
# PR Review Summary

## Critical Issues (X found) — must fix before merge
- [视角名]: Issue description [file:line]

## Important Issues (X found) — should fix
- [视角名]: Issue description [file:line]

## Suggestions (X found) — nice to have
- [视角名]: Suggestion [file:line]

## Strengths — what's well-done
- [positive findings]

## Recommended Action
1. Fix critical issues first
2. Address important issues
3. Consider suggestions
4. Re-run targeted reviews after fixes
```

## 调度方法

```
# 使用 Task tool 并行派发多视角审查
SCOPE: git diff --name-only
ASPECTS: [code|tests|errors|types|comments|simplify|all]
MODE: [sequential|parallel]

# 每个视角作为独立 subagent 派发
Task: [视角名] agent
  INPUT: git diff 内容
  FOCUS: [该视角的专属检测域]
  DEPTH: [shallow|standard|deep] (来自 requesting-code-review 的分级)
```

## NEVER

- NEVER 跳过 code-reviewer 视角——它是唯一永远启动的基线视角
- NEVER 对 >1000 行 PR 启动全部 6 视角——先要求拆分
- NEVER 在 code-simplifier 之前跳过其他视角——simplify 是最后的 polish 步骤
- NEVER 报告 <80 置信度的 issue——激进过滤，质量 > 数量
- NEVER 让 silent-failure-hunter 忽略 optional chaining——`?.` 是最常见的隐藏失败来源
- NEVER 用空 catch 块——绝对禁止，无例外
- NEVER 对未变更代码报问题——除非是 CRITICAL 安全问题

## 与现有系统的关系

```
┌─────────────────────────────────────────────────┐
│ 审查生命周期                                      │
│                                                   │
│  requesting-code-review (Skill)                   │
│  ├─ 职责：WHEN + HOW OFTEN + 路由调度             │
│  ├─ 决策：什么时候触发审查？用什么深度？            │
│  ├─ 输出：审查请求 + 参数                         │
│  └─ 调度 ──→ pr-review-toolkit                    │
│              ├─ 职责：HOW — 多视角并行执行审查     │
│              ├─ 6 个专家视角各自独立检测            │
│              ├─ 输出：结构化审查结果                │
│              └─ 输出格式遵守 ──→                   │
│                   code-review-standards (Rule)     │
│                   ├─ 职责：WHAT FORMAT             │
│                   ├─ 四级 Severity 标准             │
│                   └─ Verdict 判定规则              │
└─────────────────────────────────────────────────┘

三者关系：互补，非竞争
- requesting-code-review = 交通指挥（何时、多深、路由到哪）
- pr-review-toolkit = 专家团队（6 视角并行执行审查）
- code-review-standards = 输出合规（统一格式和判定标准）
```
