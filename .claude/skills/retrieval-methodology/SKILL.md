---
name: retrieval-methodology
description: 检索方法论 — 意图分类、通道选择、搜索策略、交叉验证。指导"怎么思考检索"而非"怎么敲命令"。在任何搜索动作前加载此 Skill 确定最优路径。
---

# Retrieval Methodology — 检索方法论

## 意图分类（先判断再动手）

| 意图类型 | 信号词 | 推荐通道 | 示例 |
|----------|--------|----------|------|
| 存量匹配 | "有没有" "找一个" "现成的" | distillery MCP (`mcp__distillery__search`) | "有没有 security review 的 Skill？" |
| 生态探索 | "最好的" "Top" "对比" "推荐" | hunt Skill → distillery MCP | "最好的 MCP 代码搜索方案" |
| 深度调研 | "怎么" "为什么" "方案" "原理" | deep-research Skill | "MCP Server 怎么处理认证？" |
| 精确查文档 | "API" "用法" "参数" "文档" | context7 Skill | "Orama search() 的参数" |
| 多维综合 | 以上任意组合 | retrieval-orchestrator Agent 全通道 | "给这个项目设计检索架构" |

## 搜索策略矩阵

| 场景 | 第一步 | 第二步 | 第三步 |
|------|--------|--------|--------|
| 造新 Skill 前 | `mcp__distillery__search` 查社区存量 | hunt 搜 GitHub 最新 | 综合决定 build vs buy |
| 解决技术问题 | context7 查官方文档 | deep-research 搜社区方案 | 交叉验证后选最佳 |
| 螺旋 SOP 发散 | hunt 4 步渐进搜索 | `mcp__distillery__search` 查社区 Skill | 合并去重，提交审判 |
| 学新技术 | deep-research 全景调研 | context7 查最新 API | self-learning 生成 Skill |
| 找相似资产 | `mcp__distillery__similar` 语义查找 | 人工比对 Top 3 | 选最优或合并精华 |

## 通道能力表

| 通道 | 覆盖范围 | 强项 | 弱项 | 调用方式 |
|------|----------|------|------|----------|
| distillery MCP | 2,100+ 社区资产（Skills/Rules/Agents/Hooks/CLAUDE.md） | 存量精确匹配、语义相似、CJK 支持 | 仅社区已收录内容 | `mcp__distillery__search` / `get_asset` / `similar` / `list_types` |
| hunt Skill | GitHub 全网 | 最新仓库、星数排序、反偏见 | 需要多步搜索 | 调用 hunt Skill |
| deep-research Skill | Web 全网 | 多源交叉验证、深度分析 | 较慢 | 调用 deep-research Skill |
| context7 Skill | 库/框架官方文档 | 精确 API 查询、最新版本 | 仅文档型内容 | 调用 context7 Skill |
| GitHub MCP | GitHub API | Issues/PRs/代码搜索 | 仅 GitHub 数据 | `mcp__github__search_*` |

## 交叉验证协议

多通道搜索后，合并结果时执行：

| 验证级别 | 条件 | 可信度 | 行动 |
|----------|------|--------|------|
| VERIFIED | 3+ 独立源确认 | 高 | 直接采用 |
| LIKELY | 2 源确认 | 中 | 采用但标注来源 |
| UNVERIFIED | 仅 1 源 | 低 | 标注"待验证"，谨慎使用 |
| CONFLICTED | 来源冲突 | 不确定 | 列出所有说法，交用户判断 |

## 结果质量信号

| distillery | GitHub | 含义 | 行动 |
|------------|--------|------|------|
| 有 + 高分 | 有 + 高星 | 成熟方案 | 直接走审判流程 |
| 有 | 无 | 社区存量但可能过时 | 检查最后更新时间 |
| 无 | 有 + 高星 | 新兴方案未收录 | 考虑更新 distillery 数据源 |
| 无 | 无 | 真空地带 | 转 skill-creator 自造 |

## 搜索反模式（避免）

- **盲目全搜**：不分类就全通道搜索，浪费 token
- **单通道执念**：只用一个通道，忽略交叉验证
- **关键词陷阱**：只搜精确关键词，不用语义搜索（distillery hybrid/vector 模式）
- **忽略已有**：不查 distillery 就开始造，重复发明轮子
- **过度搜索**：6 次搜索后仍无 >80 分结果，应转 skill-creator 自造

## 方法论自动更新协议（MANDATORY）

任何 L2（数据降维）或 L3（工具造物）执行成功后，必须在本文件追加一条路由规则：

格式：`Rule N: 查 [领域] 请 [动作]，禁止 [旧方式]。来源：L[2/3] [日期]`

未更新路由 = 进化任务未完成。

### 动态路由规则（由进化螺旋自动追加）

（初始为空，随进化积累）
