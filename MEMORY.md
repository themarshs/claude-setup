# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：全量扫描 → 三波锻造完成 → 双螺旋进化机制已部署
- **里程碑**：蒸馏器 ✓ | 检索体系 ✓ | MCP ✓ | skill-judge v2 ✓ | 全量扫描 ✓ | 三波锻造 ✓ | 双螺旋 ✓
- **当前任务**：commit + push 双螺旋进化机制
- **下一步**：提交推送 → 完成

## 关键上下文

- Skills：29 (27+2双螺旋) + superpowers(~12) | Agents：4 | Rules：12 | Hooks：7 | MCP：2
- 双螺旋新增：spiral-bootstrap, evolution-session (Skills) + pain-tracker (Hook)
- 双螺旋配套：overnight-plan.md 工单 + ARCHITECTURE_MAP.md STALE注解 + retrieval-methodology 路由绑定 + dirty-tracker STALE标记
- 报告：`reports/full-scan-2137.md`

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
