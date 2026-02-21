# Agent 交接协议（Handoff Protocol）

> 适用于螺旋 SOP 中 agent 间任务传递，确保零信息丢失。

## Handoff 文档格式

每次 agent 完成阶段工作后，必须产出以下结构化交接文档：

```
## HANDOFF: [当前阶段] → [下一阶段]
### 发起者: [agent-name]
### 时间戳: [ISO 8601]

### Context（上下文）
- 当前处于 SOP 第几步
- 本阶段目标是什么
- 继承了上游哪些约束

### Findings（发现）
- 关键结论（≤5 条，每条一行）
- 数据支撑（星数/分数/审计结果）

### Artifacts（产物）
- 文件变更列表（路径 + 动作：created/modified/deleted）
- 状态文件更新（MEMORY.md / ARMORY.md 是否已写）

### Open Questions（悬而未决）
- 需要下游 agent 判断的问题
- 风险点或不确定项

### Verdict（判定）
- **PASS** — 可进入下一阶段
- **NEEDS WORK** — 需补充 [具体项]，退回当前阶段
- **BLOCKED** — 依赖 [具体阻塞项]，升级给 Lead
```

## 各阶段交接要求

| 阶段过渡 | Handoff 重点 |
|----------|-------------|
| 锚定 → 发散 | 生态位定义、搜索关键词、排除条件 |
| 发散 → 审判 | 候选列表（名称+星数+URL）、初筛理由 |
| 审判 → 试装 | skill-judge 分数、安全审计结果、精华/糟粕报告 |
| 试装 → 织网 | 安装验证结果、配置 diff、回滚方案 |
| 织网 → 元回顾 | ARMORY.md diff、MEMORY.md diff、系统完整性确认 |
| 元回顾 → 下一轮锚定 | 本轮补丁、下轮优先级、封顶声明（如有） |

## 并行执行规则

当多个 agent 可独立工作时：
1. Lead 明确标注 `### Parallel Phase`，列出并行 agent 及各自职责
2. 每个并行 agent 独立产出 Handoff 文档
3. Lead 负责 `### Merge Results`，合并为单一交接文档后传递给下游
4. 并行 agent 之间禁止直接传递信息，必须经 Lead 路由

## 纪律

- Handoff 文档是**必须产物**，不是可选项。没有 Handoff = 阶段未完成
- Verdict 为 NEEDS WORK 时，必须附具体补充项，禁止模糊退回
- Verdict 为 BLOCKED 时，必须在 MEMORY.md 记录阻塞状态
