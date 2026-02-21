# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：全量扫描 → 三波锻造 → 双螺旋 → 官方仓库扫描 → P0+P1 锻造完成
- **里程碑**：蒸馏器 ✓ | 检索体系 ✓ | MCP ✓ | skill-judge v2 ✓ | 全量扫描 ✓ | 三波锻造 ✓ | 双螺旋 ✓ | 官方P0 ✓ | 官方P1 ✓
- **当前任务**：commit + push P1 三个 Skills
- **下一步**：官方仓库红色警报全部清零，可进入下一迭代

## 关键上下文

- Skills：34 (31+3官方P1) + superpowers(~12) | Agents：4 | Rules：12 | Hooks：7 | MCP：2
- 官方P1新增：pr-review-toolkit (6视角PR审查), code-review (5-Agent合规审查), feature-dev (7阶段pipeline)
- 来源：anthropics/claude-plugins-official (7,956⭐) 5个红色警报全部完成
- 审查三件套：requesting-code-review(WHEN调度) → pr-review-toolkit/code-review(HOW执行) → code-review-standards(WHAT格式)
- 报告：`reports/full-scan-2137.md`

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
