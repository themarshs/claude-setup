# MEMORY.md — 状态机 / 断点续传

> 覆写制：每次更新前 cp MEMORY.bak，写完删 bak
> 上限：不超过 30 行

## 当前状态

- **阶段**：工作流纪律固化完成 → 实战验证阶段
- **里程碑**：P0-P2 ✓ | 瓶颈调研 ✓ | 工作流纪律 Rule ✓ | CLAUDE.md 引用 ✓
- **当前任务**：用实际任务验证 workflow-discipline 流程
- **待办**：Task#3 评分函数升级 | 三层防线实现 | /doctor settings issue

## 三层防线方案（调研结论）

- **L1 软引导**：UserPromptSubmit → additionalContext 注入"编辑前必须搜索"
- **L2 硬拦截**：PostToolUse 记录搜索状态 → PreToolUse(Edit|Write) 检查，无搜索则 deny
- **L3 事后补救**：Stop Hook 检查本轮是否有"未搜索就编辑"，有则 block 强制补做
- **备选**：`type: "agent"` Hook（子 Agent 语义验证），成本高但可做相关性校验
- 社区无成熟解法，GitHub #24252/#20526/#26004 均 Open

## 关键上下文

- Skills：38 | Agents：4 | Rules：3+10 | **Hooks：11** | MCP：3
- CC-v3 教训：Hook ≤10（我们 11）| suggest 不 deny | 30 hooks 致性能崩溃
- 合规闭环：compliance-check ↔ doc-lookup-tracker（5min TTL）

## compact 后恢复指令

1. 读此文件 → 2. 读 CLAUDE.md → 3. 读 ARMORY.md → 4. 继续当前任务
