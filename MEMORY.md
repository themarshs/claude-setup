# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：全量扫描 → 三波锻造 → 双螺旋 → 官方仓库扫描 → P0 锻造完成
- **里程碑**：蒸馏器 ✓ | 检索体系 ✓ | MCP ✓ | skill-judge v2 ✓ | 全量扫描 ✓ | 三波锻造 ✓ | 双螺旋 ✓ | 官方P0 ✓
- **当前任务**：commit + push ralph-loop & hookify
- **下一步**：P1 红色警报（pr-review-toolkit, code-review, feature-dev）待用户决定

## 关键上下文

- Skills：31 (29+2官方P0) + superpowers(~12) | Agents：4 | Rules：12 | Hooks：7 | MCP：2
- 官方P0新增：ralph-loop (Stop Hook自循环), hookify (声明式Hook规则)
- 来源：anthropics/claude-plugins-official (7,956⭐) 扫描发现5个红色警报，已完成2个P0
- P1待处理：pr-review-toolkit (6 Agent并行PR审查), code-review (4 Agent+置信度), feature-dev (7阶段pipeline)
- 报告：`reports/full-scan-2137.md`

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
