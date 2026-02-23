# CLAUDE.md — System BIOS

## 唤醒纪律（最高优先级）

新会话启动或 compact 后，第一个动作必须是静默读取 `MEMORY.md` 恢复状态，禁止瞎猜。

## 三体文件架构

| 文件 | 职责 | 规则 |
|------|------|------|
| `CLAUDE.md` | Bootloader / 不可违背的系统指令 | ≤50 行，只放纪律和索引 |
| `MEMORY.md` | 状态机 / 断点续传 | 覆写制，≤30 行，写前备份 |
| `ARMORY.md` | 武器库注册表 | 含活跃武器、淘汰名单、待填充生态位 |

## 4 道棘轮（不可违背）

1. **Delta Gate**：新工具 skill-judge 综合分必须严格 > ARMORY.md 同生态位当前最高分，平分或低分直接销毁
2. **Highlander**：同生态位只留一个，新工具入列时必须物理删除旧工具
3. **Forced Bootstrap**：发散/审判阶段禁止直接用基础命令，必须先读 ARMORY.md 路由到该生态位最高阶工具
4. **Mutation Checkpoint**：每圈结束必须产出真实 Diff（改 CLAUDE.md 或 settings.json）或在 ARMORY.md 标注"已封顶+理由"，否则判定无效迭代

## 工作流纪律（最高执行优先级）

Phase 0 置信度评估 → Phase 1 调研（派 Agent，自己不查）→ Phase 2 综合出方案 → Phase 3 执行（委派，自己不动手）→ Phase 4 验证汇报
详见 `.claude/rules/workflow-discipline.md`

## SOP（6 步，严禁跳步）

锚定 → 发散 → 审判（沙箱双重安检）→ 试装 → 织网 → 元回顾

- 沙箱路径：`D:/ai/lab/skill-sandbox/`，用 git clone 不用 npx 盲装
- 审判 = 安全关（package.json + npm audit）+ 质量关（skill-judge）+ 白盒解剖（提取精华/糟粕报告）
- 基因熔炉：禁止直接安装黑盒，精华必须通过 skill-creator 内化为自造 Skill，糟粕剥离后原包销毁
- 计次熔断：6 次搜索后仍无 >80 分工具，转 skill-creator 自造

## 红线（肯定框架）

- MCP servers 目录由用户管理，需变更时请示用户
- 密钥/凭证通过环境变量管理，提交前确认 `.gitignore` 覆盖
- 所有工具先在 `D:/ai/lab/skill-sandbox/` 验证，通过后安装
- 方案输出前先用 context7 / WebSearch 验证时效性

## 索引

| 路径 | 内容 |
|------|------|
| `retrieval-architecture/spiral-framework-v2.md` | 完整框架文档 |
| `archive/` | 历史文件（DISCUSSION_LOG、SESSION_LOG 等） |
| `docs/` | Claude Code 官方文档（57 文件） |
| `.agents/skills/` → `.claude/skills/` | Skills 源文件与 symlinks |

## 约定

- 中文讨论，英文代码配置
- GitHub: `themarshs`，SSH，key `PC-19132`
- Token 是架构约束：CLAUDE.md 精简，Skills 按需加载
