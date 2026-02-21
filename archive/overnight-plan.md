# 通宵迭代计划

> 创建时间：2026-02-19 23:00
> 状态：执行中
> 主线：螺旋上升（检索 → Skills → MCP → 记忆），逐圈推进
> 原则：先搞懂再装 → 装完验证 → 更新文档 → 需 API Key 或重大决策的记录不做

---

## 第一圈：P0 检索 + 记忆（补核心短板）

- [x] 1.1 读取 `remembering-conversations` SKILL.md，分析原理和依赖
- [x] 1.2 安装 `remembering-conversations`，验证 symlink
  - ⚠️ 发现：依赖 episodic-memory MCP 插件（search/show 工具），Skill 本身已装但功能需 MCP 配合才能生效，待用户确认是否配置 MCP
- [x] 1.3 读取 `intellectronica/agent-skills@context7` SKILL.md，分析原理
  - ✅ 纯 curl 调 context7.com API，免费无需 API Key，无需 MCP
- [x] 1.4 安装 `context7`（Skill 版），验证 symlink
  - ✅ Gen:Safe / Socket:0 / Snyk:Med
- [x] 1.5 更新 `retrieval-capabilities/README.md` 记录安装结果
  - ✅ context7 和 remembering-conversations 已记录，brainstorming 已记录

## 第二圈：P1 获取能力

- [ ] 2.1 读取 `agent-browser` 和 `browser-use` SKILL.md，对比选型
- [ ] 2.2 安装选中的浏览器 Skill，验证
- [ ] 2.3 读取 `firecrawl` SKILL.md，检查是否需要 API Key
- [ ] 2.4 如不需 Key 则安装；需要则记录到"待用户确认"
- [ ] 2.5 读取 `deep-research` SKILL.md，分析原理
- [ ] 2.6 安装 `deep-research`，验证
- [ ] 2.7 更新 `retrieval-capabilities/README.md`

## 第三圈：P2 分析能力

- [ ] 3.1 批量读取 SKILL.md：`rag-implementation`、`super-search`、`agent-memory`
- [ ] 3.2 有价值的安装，边缘的记录到候选列表
- [ ] 3.3 更新 `retrieval-capabilities/README.md`

## 第四圈：固化成果

- [ ] 4.1 更新 CLAUDE.md — 新装 Skills 加入知识地图
- [ ] 4.2 更新 SESSION_LOG.md — 标记完成状态
- [ ] 4.3 更新 DISCUSSION_LOG.md — 记录螺旋迭代成果

---

## 续航机制

### 进度持久化
- 每完成一步立即在本文件打 ✅ 并追加时间戳到执行记录
- 关键发现写到 `retrieval-capabilities/README.md`

### compact 恢复
如果上下文被 compact，立即执行：
1. 读取本文件（`retrieval-architecture/overnight-plan.md`）恢复进度
2. 读取 `retrieval-capabilities/README.md` 恢复已装列表
3. 从最后一个未打勾的步骤继续

### 会话断线
- 进度全在文件里，用户醒了读文件即可了解全部成果
- 新会话读本文件 + README.md 接上

## 红线（不做）

- 需要 API Key 的 Skill → 记录，等用户确认
- 修改 D:/ai/mcp-servers/ 下任何文件 → 不碰
- 安装安全评估不通过的 Skill → 不装
- Hooks / Rules / 架构优化 → 不碰，只做武器库建设

## Token 节省

- Teammate 用 sonnet 或 haiku
- 搜索类任务用 haiku，分析类用 sonnet
- Lead 判断/评审才用 opus

---

## 执行记录

（每完成一步追加时间戳和结果）

