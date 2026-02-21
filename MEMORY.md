# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：全量扫描 2,137 条 → 第一波 18 武器锻造完成 → 第二波红色警报进行中
- **里程碑**：蒸馏器 ✓ | 检索体系 ✓ | MCP ✓ | skill-judge v2 ✓ | 精装修 ✓ | 全量扫描 ✓ | 第一波锻造 ✓
- **当前任务**：第二波红色警报竞品升级（4 个），然后二轮检索验证
- **下一步**：红色警报升级 → 二轮检索 → commit

## 关键上下文

- Skills：26 (15原+11新) + superpowers(~12) | Agents：3 | Rules：12 | Hooks：6 | MCP：2
- 第一波新增：tdd-workflow, context-engineering, prompt-engineering, tool-design, parallel-debugging, api-design, docker-patterns, database-expertise, multi-agent-team, code-refactoring, office-documents (Skills) + architect (Agent) + git-workflow, dependency-management, naming, documentation (Rules) + pre-tool-guard, prompt-submit (Hooks)
- 红色警报待处理：continuous-learning-v2 > self-learning, testing-skills-with-subagents > writing-skills, code-review-ai > code-review, security-reviewer > security-gate
- 报告：`reports/full-scan-2137.md`

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
