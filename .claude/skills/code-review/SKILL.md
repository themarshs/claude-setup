---
name: code-review
description: "Multi-agent parallel code review execution engine with confidence-based false positive filtering. WHAT: 5-agent architecture for PR review (CLAUDE.md compliance x1, shallow bug scan x1, git blame context x1, historical PR comments x1, code comments compliance x1) + per-issue independent confidence scoring + threshold filtering. WHEN: After requesting-code-review decides review is needed, this skill defines HOW to execute it. KEYWORDS: code review, PR review, multi-agent, confidence scoring, false positive, parallel review, bug detection, CLAUDE.md compliance"
---

# Code Review Execution Engine

> 来源：anthropics/claude-plugins-official `code-review` 插件（Boris Cherny @ Anthropic）
> 定位：审查的"执行引擎"——与 `requesting-code-review`（何时审查）和 `code-review-standards`（输出格式）互补

## 与现有工具的关系

```
requesting-code-review  →  code-review  →  code-review-standards
   (WHEN 调度器)          (HOW 执行引擎)     (WHAT 输出合约)
```

- `requesting-code-review`：决策树判断何时审查、审查深度、内容路由
- `code-review`（本 Skill）：多 Agent 并行执行审查 + 置信度过滤
- `code-review-standards`：四级 Severity + Summary 表格 + Verdict 判定

## 双重资格检查（执行前+执行后）

审查开始前和 Agent 审查完成后各做一次资格检查。目的：防止审查期间 PR 状态变化（被关闭/合并）导致无效评论。

```
资格检查清单（Haiku agent 执行）：
├─ PR 已关闭？ → 中止
├─ PR 是 draft？ → 中止
├─ PR 是自动化/trivial PR？ → 中止
├─ 已有本轮审查评论？ → 中止
└─ 全部通过 → 继续
```

关键：步骤 1 检查一次，全部 Agent 审查完成后再检查一次（步骤 7）。

## 5-Agent 并行审查架构

### 模型分层路由

| 任务类型 | 模型层级 | 理由 |
|----------|---------|------|
| 资格检查 | Haiku | 简单判断，节省 tokens |
| CLAUDE.md 收集 | Haiku | 文件路径列举，低复杂度 |
| PR 摘要 | Haiku | 变更概述，无需深度推理 |
| 深度审查（5 Agent） | Sonnet | 需要代码理解和推理 |
| 逐 issue 置信度评分 | Haiku | 二元判断（真/假阳性），结构化评分 |

### 5 个审查 Agent 的职责定义

每个 Agent 独立执行，返回 issue 列表 + 每个 issue 的触发原因标签。

**Agent #1 — CLAUDE.md 合规审计**
- 输入：PR diff + 所有相关 CLAUDE.md 文件（根目录 + 变更目录下的）
- 行为：逐条对照 CLAUDE.md 指导原则，检查变更是否违规
- 关键约束：CLAUDE.md 是写给 Claude 的指导，并非所有条目都适用于审查场景——Agent 必须做适用性判断
- 标签：`CLAUDE.md adherence`

**Agent #2 — 浅层 Bug 扫描**
- 输入：PR diff（仅变更部分）
- 行为：只看变更本身，不读额外上下文，聚焦大 bug
- 关键约束：只报大问题，忽略 nitpick 和小问题；忽略可能的假阳性
- 标签：`bug`

**Agent #3 — 历史上下文分析**
- 输入：变更文件的 git blame + git log
- 行为：结合代码历史判断变更是否引入了与历史模式冲突的问题
- 标签：`historical git context`

**Agent #4 — 前序 PR 评论挖掘**（高价值独特视角）
- 输入：触碰相同文件的历史 PR 及其评论
- 行为：检查历史 PR 评论中是否有同样适用于当前 PR 的建议
- 标签：`previous PR feedback`
- 实现：`gh pr list --search "involves:FILE_PATH" --state merged` → 读取评论

**Agent #5 — 代码注释合规**（高价值独特视角）
- 输入：变更文件中的代码注释
- 行为：检查 PR 变更是否违反了代码注释中的指导（如 `// NOTE:`, `// IMPORTANT:`, `// WARNING:`, `// TODO:`）
- 标签：`code comment guidance`

### 前置准备（Agent 审查前）

1. Haiku agent 收集 CLAUDE.md 文件路径清单（根目录 + 变更涉及的目录）
2. Haiku agent 生成 PR 变更摘要，供所有审查 Agent 共享上下文

## 置信度评分机制（核心过滤器）

### 独立评分架构

每个 issue 单独派一个 Haiku agent 评分——不是批量评分。原因：批量评分会产生锚定效应，前面的 issue 影响后面的评分。

### 评分量表（原样传递给评分 Agent）

| 分数 | 含义 | 判定标准 |
|------|------|----------|
| 0 | 假阳性 | 经不起轻微审视，或是已存在的问题（非 PR 引入） |
| 25 | 低置信 | 可能是真问题但也可能是假阳性；若为风格问题，CLAUDE.md 未明确提及 |
| 50 | 中等置信 | 确认是真问题，但可能是 nitpick 或实践中不常触发；相对 PR 整体不重要 |
| 75 | 高置信 | 双重验证确认很可能是真问题且实践中会命中；现有 PR 方案不足；直接影响功能，或 CLAUDE.md 明确提及 |
| 100 | 确定 | 双重验证确认必然是真问题，实践中频繁发生，证据直接证实 |

### CLAUDE.md 交叉验证规则

对标记为 `CLAUDE.md adherence` 的 issue，评分 Agent 必须：
1. 重新读取相关 CLAUDE.md 文件
2. 确认 CLAUDE.md **明确提到**该具体问题
3. 如果 CLAUDE.md 未明确提及 → 最高 25 分

### 过滤阈值

**默认阈值：80 分。低于 80 的 issue 全部丢弃。**

如果过滤后无任何 issue 达标 → 不发布评论（沉默优于噪音）。

## 假阳性分类学（评分 Agent 的参考清单）

以下情况应判为假阳性或低置信度：

| 类别 | 说明 | 典型分数 |
|------|------|----------|
| 已存在问题 | 问题在 PR 之前就存在，非本次引入 | 0 |
| 看似 bug 实则不是 | 代码看起来有问题但实际正确 | 0-25 |
| 迂腐 nitpick | 资深工程师不会提出的问题 | 0-25 |
| 工具可捕获 | linter/typechecker/compiler 能抓到的（import 错误、类型错误、格式问题） | 0 |
| 通用质量 issue | 缺测试、安全泛论、文档不足——除非 CLAUDE.md 明确要求 | 0-25 |
| lint-ignore 沉默 | 代码显式用 `// eslint-disable` 等注释沉默的规则 | 0 |
| 有意的功能变更 | 与 PR 整体目标直接相关的行为变更 | 0-25 |
| 未修改行的问题 | 问题出现在用户未修改的行上 | 0 |

## 输出格式（GitHub 评论）

```markdown
### Code review

Found N issues:

1. <简要描述> (CLAUDE.md says "<引用原文>")

https://github.com/OWNER/REPO/blob/FULL_SHA/path/file.ext#L起始-L结束

2. <简要描述> (bug due to <文件和代码片段>)

https://github.com/OWNER/REPO/blob/FULL_SHA/path/file.ext#L起始-L结束
```

### 链接格式硬要求

- **必须用完整 SHA**（40 字符），不能用缩写或 `$(git rev-parse HEAD)` 动态命令
- 格式：`https://github.com/owner/repo/blob/FULL_SHA/path/file.ext#L起始-L结束`
- 行号前后至少各 1 行上下文（如评论 L5-6，链接 L4-L7）
- 仓库名必须匹配当前审查的仓库

### 无 issue 时

```markdown
### Code review

No issues found. Checked for bugs and CLAUDE.md compliance.
```

## 完整执行流程

```
1. [Haiku] 资格检查（closed/draft/trivial/already-reviewed）
       ↓ PASS
2. [Haiku] 收集 CLAUDE.md 文件路径清单
       ↓
3. [Haiku] 生成 PR 变更摘要
       ↓
4. [Sonnet x5 并行] 独立审查
   ├─ Agent #1: CLAUDE.md 合规
   ├─ Agent #2: 浅层 Bug 扫描
   ├─ Agent #3: Git 历史上下文
   ├─ Agent #4: 前序 PR 评论挖掘
   └─ Agent #5: 代码注释合规
       ↓ 合并所有 issue
5. [Haiku x N 并行] 每个 issue 独立评分（0-100）
       ↓
6. 过滤：丢弃 < 80 分的 issue
       ↓ 如果全部丢弃 → 静默退出
7. [Haiku] 二次资格检查（PR 可能在审查期间被关闭）
       ↓ PASS
8. [gh pr comment] 发布结构化评论
```

## NEVER

- NEVER 批量评分多个 issue——每个 issue 必须独立评分，防止锚定效应
- NEVER 跳过二次资格检查——审查耗时数分钟，PR 状态可能已变
- NEVER 报未修改行的问题——除非是 CRITICAL 安全漏洞
- NEVER 报 linter/typechecker 能抓的问题——假设 CI 会跑这些
- NEVER 用缩写 SHA 或动态命令生成链接——GitHub Markdown 不渲染动态命令
- NEVER 在过滤后无高置信 issue 时发布评论——沉默优于噪音
- NEVER 让审查 Agent 读超出变更范围的代码（Agent #2）——聚焦变更本身
- NEVER 对 CLAUDE.md compliance issue 跳过交叉验证——必须确认原文明确提及
