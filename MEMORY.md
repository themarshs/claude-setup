# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：Phase 4 锻造完成 → Phase 5 织网 → Phase 2 发散搜索
- **里程碑**：蒸馏器 ✓ | 检索体系 ✓ | MCP ✓ | skill-judge v2 ✓ | 全量扫描 ✓ | 三波锻造 ✓ | 双螺旋 ✓ | 官方P0 ✓ | 官方P1 ✓ | 已知目标扫描 ✓ | Raptor锻造 ✓
- **当前任务**：更新 ARMORY + git commit
- **下一步**：Phase 2 发散搜索新目标

## 关键上下文

- Skills：38 (34+4新锻造) | Agents：4 | Rules：12 | Hooks：7 | MCP：2
- 本轮新锻造：security-research, exploit-feasibility, fuzzing-automation, binary-analysis
- Raptor 扫描：92% Expert，7 个 P0 红色警报
- claude-code-security-review：50-60% Expert，5 个 P1 红色警报

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
