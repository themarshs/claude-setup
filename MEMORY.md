# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：Phase 2 发散搜索完成
- **里程碑**：蒸馏器 ✓ | 检索体系 ✓ | MCP ✓ | skill-judge v2 ✓ | 全量扫描 ✓ | 三波锻造 ✓ | 双螺旋 ✓ | 官方P0 ✓ | 官方P1 ✓ | 已知目标扫描 ✓ | Raptor锻造 ✓ | 织网 ✓ | Phase2发散 ✓
- **当前任务**：Phase 2 发散搜索完成
- **下一步**：可停止或继续更多搜索

## 关键上下文

- Skills：38 | Agents：4 | Rules：12 | Hooks：7 | MCP：2
- 本轮新锻造：security-research, exploit-feasibility, fuzzing-automation, binary-analysis
- Raptor 扫描：92% Expert，7 个 P0 红色警报
- claude-code-security-review：3038⭐，Prompt Injection 红色警报（安全审计工具本身有漏洞）
- Phase 2 发现高星仓库：
  - oraios/serena (20.4k⭐) - 语义检索 MCP
  - sickn33/antigravity-awesome-skills (13.5k⭐) - 800+ Skills
  - BeehiveInnovations/pal-mcp-server (11.1k⭐) - 多模型编排
  - idosal/git-mcp (7.6k⭐) - GitHub 文档 MCP

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
