# 真·螺旋迭代执行框架 V2.0（Windows 实战版）

> 版本：V2.0（终版锁定）
> 创建时间：2026-02-20
> 演进路径：用户拟合 V1.0 → 头脑风暴 18 轮补丁 → V2.0
> 状态：已锁定，准备执行

---

## 一、最高宪法：6 个边界法则

### 1. 螺旋终止条件

- **量化拐点**：连续两圈元回顾发现，新搜到的工具 skill-judge 评分均低于现有武库平均分
- **实战拐点**：面对真实复杂业务需求时，一次都没有因"缺能力"而卡住
- **逢 3 大考**（#15）：每完成 3 个 Loop，强制挂起搜索，AI 主动生成虚拟业务需求做纯逻辑推演自测

### 2. 回顾环节结构化

- 禁止漫谈。每圈结束强制生成 `Loop_X_MetaReview.md`
- 强制回答 5 个灵魂拷问：搜的够广吗？评的够准吗？装的够稳吗？协作够顺吗？计划本身对吗？
- 必须产出至少 1 条针对下一圈 SOP 的修改补丁

### 3. 多 Agent 启用时机

- **Loop 1**：绝对不用。单机跑通 SOP
- **Loop 2**：局部引入。仅搜索阶段 2 个 Teammate 并发
- **Loop 3+**：全面流水线。搜/评/装/审角色分离

### 4. 自造 Skill 优先级（计次熔断 #2）

- Buy first, Build later
- 熔断条件：各渠道累计 6 次搜索/读取动作后仍未找到 >80 分工具，立刻转入 skill-creator 自造

### 5. MCP vs Skill 选择标准

- **MCP（感官与通道）**：读取外部状态、持久化数据源、外网 API
- **Skill（大脑与肌肉）**：无状态逻辑、本地工作流、Prompt 范式

### 6. 夜间自主运行边界（细化版 #3）

- 🟢 **绿灯（静默狂奔）**：沙箱下载、本地运算、创建文件夹/symlink（可逆）、向 .md 日志追加文本、Skill 安装（可回滚）
- 🔴 **红灯（强制卡点）**：修改 CLAUDE.md、修改 settings.json、执行 sudo 或写入系统级目录、修改全局环境

---

## 二、三体（Trinity）文件架构（#10 #11 #13）

全系统只允许 3 个核心活文件 + 1 个归档区：

### 1. `CLAUDE.md`（系统 BIOS / Bootloader）

- 严格控制 50 行以内
- 顶部硬编码唤醒序列："新会话或 compact 后第一个动作必须读 MEMORY.md"
- 只放：唤醒纪律、红线、三体文件索引、archive/ 路径索引（#17）
- 不放：具体 Skill 列表、流水账、详细规则

### 2. `MEMORY.md`（状态机 / 断点续传 RAM）

- 覆写制，只记录当前快照："Loop X / 上一步结果 / 当前卡点 / 下一步动作"
- 写前备份：`cp MEMORY.md MEMORY.bak`，写完删 bak（#16）
- 严格字数上限：不超过 30 行

### 3. `ARMORY.md`（武器库 / 注册表 ROM）

- retrieval-capabilities/README.md 的终极形态
- 只记录经过实战验证的工具：名称、类型（Skill/MCP/Plugin）、用途、触发条件
- 包含淘汰名单（评分 + 淘汰原因，防重复搜索）

### 4. `archive/`（冷存储）

- 归档历史文件：DISCUSSION_LOG.md、SESSION_LOG.md、overnight-plan.md、spiral-iteration-design.md、spiral-framework-v1.md 等
- CLAUDE.md 保留一行路径索引指向此目录（#17）

---

## 三、单圈标准作业流 SOP（6 步）

### Step 1. 锚定 (Scope)
- 明确本圈唯一主题，写入 MEMORY.md

### Step 2. 发散 (Hunt)
- 禁用单渠道，强制组合：`npx skills find` + context7 MCP + GitHub 检索
- 后续圈可加 agent-browser 爬取

### Step 3. 审判 (Judge) — 双重安检（#1 #6 #7 #14）

**物理隔离**：
- 沙箱路径：`D:/ai/lab/skill-sandbox/`
- 强制用 `git clone --depth 1` 或 `curl` 拉取，绝对不用 `npx skills install` 盲装
- Windows 环境，不用 /tmp/（#6）

**安全关**：
- 人工检查 package.json（特别是 postinstall 脚本）
- 必要时跑 npm audit

**质量关**：
- 读取沙箱内 SKILL.md 内容
- 调用 Skill tool 执行 skill-judge 评分（#7：它是 Prompt 模板不是 CLI）
- <80 分淘汰，记录淘汰原因到 ARMORY.md 淘汰名单

**裁决**：两关皆过放行，任一不过 `rm -r` 销毁

### Step 4. 试装 (Equip)
- 从沙箱移入正式目录 `.agents/skills/`，创建 symlink
- 触发 verification-before-completion，写冒烟测试跑通
- 去重检查（#9 #18）：确认不与 superpowers 插件重复

### Step 5. 织网 (Weave)
- 更新 ARMORY.md 添加新工具条目
- 通过 CLAUDE.md 或 Hooks（原生机制 #5 #12）写入触发规则
- 更新 MEMORY.md 记录进度

### Step 6. 元回顾 (Meta)
- 生成 `archive/Loop_X_MetaReview.md`
- 强制回答 5 个灵魂拷问
- 产出至少 1 条 SOP 补丁
- 逢 3 大考：触发虚拟业务需求自测（#15）

---

## 四、螺旋演进路线图

### Loop 0：场地平整（起飞前检查）
- 去重：删除与 superpowers 插件重复的手动 Skills
- 文件重构：初始化三体架构，归档历史文件
- 冒烟测试：验证 context7 MCP 在 Windows 可用
- 学法：研究 Hooks 能力边界

### Loop 1：基建与扫盲（Bootstrap）
- 目标：治好"健忘"和"无纪律"
- 动作：建立文件级记忆（MEMORY.md）；配置 Hooks 触发机制；单 Agent 跑通完整 6 步 SOP
- 记忆目标降维（#4）：不搞 embedding + 向量库，只做文件级断点续传

### Loop 2：感官扩张
- 目标：引爆信息获取能力
- 动作：引入高级浏览器/爬取工具；搜索阶段启用多 Agent 并发

### Loop 3：生态缝合 + 逢 3 大考
- 目标：填补高阶空白 + 首次实战拐点自测
- 动作：大规模接入 MCP Registry；启动 skill-creator 批量自造；虚拟业务推演

---

## 五、头脑风暴全记录（18 轮补丁索引）

| # | 问题 | 补丁 | 来源 |
|---|------|------|------|
| 1 | 审判死锁：先装再评 | 沙箱检疫区 | Round 1 |
| 2 | 15 分钟无法计量 | 6 次计次熔断 | Round 1 |
| 3 | 红绿灯灰色地带 | 按可逆性划线 | Round 1 |
| 4 | 记忆目标过高 | 降维为文件级 MVP | Round 1 |
| 5 | .clinerules 幻觉 | 回归原生 Hooks/Rules | Round 1 |
| 6 | Windows 无 /tmp/ | D:/ai/lab/skill-sandbox/ | Round 2 |
| 7 | skill-judge 非 CLI | Skill tool 调用 Prompt | Round 2 |
| 8 | context7 MCP 未测 | Loop 0 冒烟测试 | Round 2 |
| 9 | Skill 重复冲突 | 去重统一用插件版 | Round 2 |
| 10 | 文件太多职责不清 | 三体架构 | Round 2 |
| 11 | CLAUDE.md 膨胀 | 50 行上限 | Round 2 |
| 12 | Hooks 未研究 | Loop 0 学法 | Round 2 |
| 13 | compact 恢复链路 | CLAUDE.md 硬编码唤醒序列 | Round 2 |
| 14 | 安全评估未固化 | 双重安检（安全关 + 质量关） | Round 2 |
| 15 | 实战拐点无触发者 | 逢 3 大考自测 | Round 2 |
| 16 | MEMORY.md 覆写防崩溃 | 写前 cp bak | Round 3 |
| 17 | 归档需保留索引 | archive/ 路径写入 CLAUDE.md | Round 3 |
| 18 | 去重前需 diff | 先对比再删 | Round 3 |
