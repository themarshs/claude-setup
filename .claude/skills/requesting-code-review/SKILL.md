---
name: requesting-code-review
description: "Dispatch code-reviewer at the right time with the right cadence. Use after completing tasks in subagent-driven development, after major features, before merge to main, when stuck and needing fresh perspective, or when unsure whether to request review. Covers WHEN to review, HOW OFTEN based on dev workflow, and WHAT TO DO with feedback."
---

# Requesting Code Review

## 触发决策树（先判断再调度）

```
我刚完成了一些代码变更
    │
    ├─ subagent-driven 模式？
    │   └─ YES → 每个 task 完成后立即审查
    │
    ├─ plan execution 模式？
    │   └─ YES → 每 3 个 task 批量审查
    │
    ├─ ad-hoc 开发？
    │   └─ YES → merge 前审查
    │
    └─ 不确定？→ 看下面的信号表
```

## 强制 vs 可选

| 审查时机 | 级别 | 原因 |
|----------|------|------|
| 每个 subagent task 完成后 | **强制** | 问题复利——晚一个 task 发现，修复成本翻倍 |
| 主要功能完成后 | **强制** | 集成点是 bug 密度最高的地方 |
| merge 到 main 前 | **强制** | 最后防线 |
| 卡住时 | 可选 | 新视角可能发现盲区 |
| 重构前 | 可选 | 建立基线，重构后对比 |
| 修复复杂 bug 后 | 可选 | 修复本身可能引入新 bug |

## 工作流-审查节奏映射

| 开发模式 | 审查频率 | 理由 |
|----------|----------|------|
| subagent-driven | 每个 task | 最小反馈环，issue 不越 task 边界 |
| plan execution | 每 3 个 task 一批 | 平衡效率和质量 |
| ad-hoc / hotfix | merge 前一次 | 快速交付但不跳过 |
| 多人协作 | 每个 PR | PR 是天然审查边界 |

## 调度方法

Use Task tool 调度 `superpowers:code-reviewer` subagent：

```
BASE_SHA=$(git rev-parse HEAD~N)  # N = 本批变更的 commit 数
HEAD_SHA=$(git rev-parse HEAD)

Task: code-reviewer subagent
  WHAT: [实现了什么]
  PLAN: [对应计划的哪一步]
  BASE: {BASE_SHA}
  HEAD: {HEAD_SHA}
```

## 反馈响应规则

| 审查结果 | 行动 | 时限 |
|----------|------|------|
| Critical issue | **立即修复**，修完重新提交审查 | 当前 task 内 |
| Important issue | **修完再继续**下一个 task | 当前 task 内 |
| Minor issue | 记录到 TODO，不阻塞 | 下个 task 或专门清理轮 |
| 审查者判断有误 | 用代码/测试证据反驳，不盲从 | — |

## NEVER

- NEVER 攒超过 3 个 task 才审查——问题复利增长
- NEVER 跳过"只是配置改动"的审查——配置 bug 最难调试
- NEVER 不给上下文就调度审查——reviewer 需要意图才能判断正确性
- NEVER 审查自己刚写的代码就算完——至少间隔一个 commit 或用 subagent

## 审查轮次升级

| 情况 | 行动 |
|------|------|
| 第 1 轮有 issue | 正常修复，重新审查 |
| 第 2 轮仍有 issue | 检查是否方向性问题 |
| 第 3 轮仍无法通过 | **停止**——升级给用户，可能需要重新设计 |
