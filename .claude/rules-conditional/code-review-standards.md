# Code Review Output Standards

> 所有代码审查（无论由哪个 agent 执行）必须遵守此输出标准。

## 四级 Severity

| 级别 | 含义 | 行动要求 |
|------|------|----------|
| CRITICAL | 安全漏洞、数据丢失、功能完全不工作 | **必须修复**才能 merge |
| HIGH | 逻辑错误、缺失功能、架构问题 | **应该修复**，可附条件 merge |
| MEDIUM | 性能问题、可维护性、缺少测试 | 建议修复，记录为 follow-up |
| LOW | 命名、注释、格式、小优化 | 可选，不阻塞 |

## Issue 输出格式

每个 issue 必须包含四要素：

```
[SEVERITY] 简要标题
File: path/to/file.ts:行号
Issue: 具体问题描述（一句话说清什么错了）
Fix: 具体修复建议（一句话说清怎么改）
```

## Review Summary 表格

每次审查结束必须附 summary：

```
## Review Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 0     | pass   |
| HIGH     | 1     | warn   |
| MEDIUM   | 2     | info   |
| LOW      | 0     | —      |

Verdict: [APPROVE / WARNING / BLOCK]
Reasoning: [一句话技术判断]
```

## 审批标准

| Verdict | 条件 | 含义 |
|---------|------|------|
| **APPROVE** | 0 CRITICAL + 0 HIGH | 可以 merge |
| **WARNING** | 0 CRITICAL + ≥1 HIGH | 可以 merge 但建议先修 |
| **BLOCK** | ≥1 CRITICAL | **禁止 merge**，必须修复 |

## 审查纪律

- 只报 >80% 置信度的 issue（宁缺毋滥）
- 同类问题合并报（"5 处缺少错误处理"而非 5 条重复 issue）
- 不报未变更代码的问题（除非是 CRITICAL 安全问题）
- 先说做得好的，再说问题
