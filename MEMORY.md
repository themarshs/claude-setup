# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：Phase 3 分层调度架构 — P0+P1+P2 全部完成，进入实战验证
- **里程碑**：CC-v3解剖 ✓ | skill-activation ✓ | 根因分析 ✓ | Rules精简 ✓ | 否定→肯定重写 ✓ | 方法等价类 ✓ | search-router ✓ | compliance-check ✓ | doc-lookup-tracker ✓ | PostCompact增强 ✓
- **当前任务**：全部完成，进入实战迭代——哪个出问题优化哪个
- **下一步**：实战验证 11 hooks 系统 → 根据实际触发情况调优路由表/阈值

## 关键上下文

- Skills：38 | Agents：4 | **Rules：3 核心 + 10 条件加载** | **Hooks：11** | MCP：3
- Rules 精简：13→3 核心（confidence-gate, error-discipline, language），10 条在 `.claude/rules-conditional/`
- 合规闭环：compliance-check（硬阻断配置编辑）↔ doc-lookup-tracker（查文档后 5min 解锁）
- search-router：PreToolUse/Grep，三类分类（structural/literal/semantic），suggest 模式
- skill-activation：UserPromptSubmit，匹配 skill-rules.json（25 skills + 3 agents + excludeKeywords）
- PostCompact 三层恢复：MEMORY.md + 执行纪律重注入 + CLAUDE.md 锚定
- 根因分析 10 条核心：注意力稀释 + Solver's Override + 软硬鸿沟 → 已三管齐下解决
- CC-v3 教训：Hook ≤10（我们 11 接近上限）| 纯 Node.js | suggest 不 deny

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
