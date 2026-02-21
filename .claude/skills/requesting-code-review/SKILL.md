---
name: requesting-code-review
description: "Dispatch code-reviewer with intelligent routing. Use after completing tasks in subagent-driven development, after major features, before merge to main, when stuck, or when unsure. Covers WHEN to review, HOW OFTEN based on workflow, content-aware routing (security/perf/arch), static analysis pre-check, size-based triage, and WHAT TO DO with feedback."
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

## 大小分级（调度前先判断审查深度）

```
变更规模判断
    │
    ├─ >1000 行 或 >50 文件？
    │   └─ 浅审模式：架构+安全 only，建议拆分 PR
    │
    ├─ 200-1000 行？
    │   └─ 标准模式：全维度审查
    │
    ├─ <200 行？
    │   └─ 深审模式：逐行审查，含边界/并发/错误路径
    │
    └─ 标注 REVIEW_DEPTH: shallow|standard|deep
```

## 内容感知路由（根据变更内容选择审查策略）

| 变更特征 | 审查策略 | 附加检查 |
|----------|----------|----------|
| 触碰 auth/login/token/session | **安全聚焦审查** | OWASP Top 10 + CWE 标注 |
| 测试覆盖率缺口 >20% | **测试聚焦审查** | 要求补测试再审 |
| DB schema/migration/query 变更 | **数据聚焦审查** | N+1 检测 + 索引审查 |
| API 接口变更 | **契约聚焦审查** | 向后兼容 + 版本化检查 |
| 纯重构（无功能变更） | **回归聚焦审查** | 行为等价验证 |
| 通用功能代码 | **标准全维度审查** | — |

## 静态分析预检（调度审查前先跑工具）

调度 reviewer 前，先在本地跑可用的静态分析：

```
静态分析预检清单（按可用性选择）
    │
    ├─ TypeScript/JavaScript → npx tsc --noEmit && npx eslint .
    ├─ Python → ruff check . && mypy .
    ├─ Go → go vet ./... && staticcheck ./...
    ├─ Rust → cargo clippy
    ├─ 通用安全 → semgrep scan --config=auto (如已安装)
    └─ 秘密扫描 → grep -rn "API_KEY\|SECRET\|PASSWORD\|TOKEN" --include="*.{ts,js,py,go}"
```

将静态分析结果附在审查请求中，reviewer 可跳过工具能捕获的低级问题。

## 性能/架构红旗速查

reviewer 和调度者都应关注以下信号：

| 红旗 | 严重度 | 快速检测方法 |
|------|--------|-------------|
| 循环内 DB/API 调用（N+1） | HIGH | 搜索 for/while 循环内的 await/query |
| 无界集合（无分页/无 limit） | HIGH | 搜索 findAll/find() 无 limit 参数 |
| 同步外部调用（阻塞主线程） | MEDIUM | 搜索非 async 的 HTTP/DB 调用 |
| God Object（>500 行 或 >20 方法） | MEDIUM | 文件行数 + 方法/函数计数 |
| 缺少错误处理的外部调用 | HIGH | try/catch 覆盖率 |
| 硬编码配置/魔法数字 | LOW | grep 数字常量和字符串常量 |

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
  DEPTH: [shallow|standard|deep]
  FOCUS: [security|testing|data|contract|regression|standard]
  STATIC_RESULTS: [预检结果摘要，如有]
```

## 反馈响应规则

| 审查结果 | 行动 | 时限 |
|----------|------|------|
| Critical issue | **立即修复**，修完重新提交审查 | 当前 task 内 |
| Important issue | **修完再继续**下一个 task | 当前 task 内 |
| Minor issue | 记录到 TODO，不阻塞 | 下个 task 或专门清理轮 |
| 审查者判断有误 | 用代码/测试证据反驳，不盲从 | — |

## 质量门（CI/CD 集成时使用）

```yaml
# 审查结果自动判定（与 code-review-standards.md Verdict 对齐）
quality_gate:
  BLOCK:   CRITICAL >= 1        # 禁止 merge
  WARNING: CRITICAL == 0, HIGH >= 1  # 可 merge 但建议先修
  APPROVE: CRITICAL == 0, HIGH == 0  # 可以 merge
```

## NEVER

- NEVER 攒超过 3 个 task 才审查——问题复利增长
- NEVER 跳过"只是配置改动"的审查——配置 bug 最难调试
- NEVER 不给上下文就调度审查——reviewer 需要意图才能判断正确性
- NEVER 审查自己刚写的代码就算完——至少间隔一个 commit 或用 subagent
- NEVER 跳过静态分析预检直接提交人工审查——工具能抓的别浪费人力
- NEVER 对 >1000 行 PR 做深审——先要求拆分，再逐个审查

## 审查轮次升级

| 情况 | 行动 |
|------|------|
| 第 1 轮有 issue | 正常修复，重新审查 |
| 第 2 轮仍有 issue | 检查是否方向性问题 |
| 第 3 轮仍无法通过 | **停止**——升级给用户，可能需要重新设计 |
