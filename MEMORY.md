# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：skill-judge v2 + code-review 精装修完成
- **里程碑**：蒸馏器 ✓ | 检索体系 ✓ | MCP Server ✓ | skill-judge v2（双模式）✓ | 首单精装修 ✓
- **当前任务**：commit 全部变更
- **下一步**：用户指定新任务 / 或用 skill-judge Mode 2 吸收更多社区资产

## 关键上下文

- Skills：15 手动 + superpowers（~12）| Agents：2 | Rules：8 | Hooks：4 | MCP：2
- skill-judge v2：双模式（整体评分 + 元素解剖锻造），SKILL.md 82行 + 2 个 references
- 首单精装修：code-reviewer 2 个 D 级 Skill → 17 元素 → 9 精华 → 134 行交钥匙
- MCP 注册：`.mcp.json`（项目根目录），不是 settings.local.json
- 搜索系统：Orama 3.1.18 hybrid + all-MiniLM-L6-v2 | 2,137 条 | vectors: true
- GitHub 仓库：`themarshs/claude-distillery`（3 commits）
- 纪律教训：MCP 配置位置、检索优先、mcp-builder Skill 不适用 stdio

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
