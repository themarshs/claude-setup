---
name: knowledge-evolution
description: 元回顾阶段的知识进化框架。将螺旋迭代中的经验转化为原子本能，聚类升级为 Skill/Agent/Rule。
version: 1.0.0
---

# 知识进化框架（Knowledge Evolution Framework）

> 在螺旋 SOP 元回顾阶段使用。将每轮迭代经验沉淀为可复用知识。

## 激活条件

- 螺旋 SOP 进入元回顾阶段时
- 发现反复出现的模式需要固化时
- 需要评估已有知识是否过时时

## 原子本能模型（Instinct Model）

最小知识单元。一个触发条件，一个动作。

```yaml
id: <kebab-case 唯一标识>
trigger: "当 [具体场景] 时"
action: "执行 [具体动作]"
confidence: <0.3 - 0.9>
domain: <生态位标签>  # code-style | testing | search | architecture | workflow
source: <来源>        # spiral-observation | user-correction | audit-result
evidence:
  - <观察记录 1>
  - <观察记录 2>
created: <ISO 8601>
last_validated: <ISO 8601>
```

## 置信度体系

| 分值 | 含义 | 行为 |
|------|------|------|
| 0.3 | 试探 | 仅记录，不自动应用 |
| 0.5 | 中等 | 相关时建议，不强制 |
| 0.7 | 强确信 | 自动应用，无需确认 |
| 0.9 | 核心行为 | 写入 rules，成为纪律 |

### 置信度变化规则

**增长**（每次 +0.1，上限 0.9）：
- 同一模式在不同迭代轮次中重复出现
- 用户未纠正该行为
- 多个独立来源交叉验证

**衰减**（decay_rate: 0.05 / 轮）：
- 连续 N 轮未被触发，每轮 -0.05
- 用户显式纠正 → 直接降至 0.3
- 出现矛盾证据 → 降 0.2

**淘汰**：置信度 < 0.3 → 移入 `archive/deprecated-instincts/`

## 进化路径

```
单个本能 (instinct)
    │
    │ 同 domain 下积累 ≥3 个相关本能
    ▼
本能聚类 (cluster)
    │
    │ 聚类置信度均值 ≥0.7
    ▼
升级判定：
├─ 操作规程类 → 写入 .claude/rules/ (Rule)
├─ 知识密集类 → 写入 .claude/skills/ (Skill)
└─ 编排流程类 → 写入 .claude/agents/ (Agent)
```

### 升级条件

| 目标 | 条件 | 示例 |
|------|------|------|
| Rule | ≥3 本能，均值 ≥0.7，全部为约束/纪律类 | "提交前必须 npm audit" |
| Skill | ≥3 本能，均值 ≥0.7，含领域知识 | "TypeScript 项目测试策略" |
| Agent | ≥5 本能，均值 ≥0.7，含多步编排 | "安全审查 Agent" |

## 元回顾操作规程

每轮螺旋结束时执行以下步骤：

### Step 1: 提取本能
回顾本轮所有阶段，提取新发现的模式：
- 哪些搜索策略有效/无效？
- 哪些审判标准需要调整？
- 哪些操作步骤可以固化？

### Step 2: 更新置信度
- 已有本能被本轮验证 → confidence +0.1
- 已有本能被本轮反驳 → confidence -0.2
- 未被触发的本能 → confidence -0.05

### Step 3: 聚类检查
- 扫描同 domain 本能，检查是否满足升级条件
- 满足则执行升级，产出新 Rule/Skill/Agent 文件
- 升级后原始本能标记 `evolved_into: <目标路径>`

### Step 4: 产出 Diff
必须满足 Mutation Checkpoint（CLAUDE.md 棘轮 4）：
- 修改了 CLAUDE.md / settings.json / ARMORY.md，**或**
- 在 ARMORY.md 标注"已封顶 + 理由"

## 与现有体系的关系

- **ARMORY.md**：本能升级为 Skill 后，必须通过 Delta Gate 才能入列 ARMORY
- **Highlander 法则**：升级产物同样受同生态位唯一约束
- **基因熔炉**：本能来自观察而非黑盒安装，天然满足白盒要求
