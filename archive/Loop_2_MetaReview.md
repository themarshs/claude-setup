# Loop 2 MetaReview — 感官扩张

> 日期：2026-02-20
> 主题：深度爬取/研究能力扩展

## 5 个灵魂拷问

### 1. 搜的够广吗？

6/6 搜索配额全部用完，覆盖 firecrawl、deep research、web crawl、github search、information retrieval、documentation fetcher 六个维度。发现 firecrawl（4.6K）和 web-reader（1.3K）两个高安装量候选。还额外发现了 deepagents/web-research（261）和 rag-architect（385）作为后续 Loop 候选。

**不足**：仍然只用了 skills.sh 单渠道。context7 MCP 不可用限制了第二搜索渠道。GitHub CLI 搜索可作为补充但本圈未使用。

### 2. 评的够准吗？

对两个高安装量候选进行了完整白盒解剖：
- firecrawl：准确识别出 API Key 依赖（红线），同时提取了工作流决策模式（精华）
- web-reader：准确识别出智谱 GLM 绑定（与 Claude 无关），避免了被虚假安装量误导

**改进空间**：未对 deepagents/web-research 进行解剖（安装量较低，留给 Loop 3）。

### 3. 装的够稳吗？

本圈未安装新工具。验证了 agent-browser CLI 可用（v0.12.0）。沙箱使用后已完全清理。

### 4. 协作够顺吗？

单 Agent 执行，但按框架 Loop 2 可引入多 Agent。本圈未使用多 Agent，因为搜索任务不够重（6 次搜索单机几分钟完成）。多 Agent 的引入时机应该是任务复杂度真正需要时，而非框架规定的圈数。

**SOP 补丁建议**：多 Agent 启用条件从"圈数"改为"任务复杂度"——当单圈搜索目标 ≥3 个独立生态位时才引入并发。

### 5. 计划本身对吗？

本圈的核心发现是：**深度爬取生态位已封顶**。firecrawl 是该领域最佳工具（4.6K 安装），但需要 API Key + 付费 credits，不符合当前零成本约束。agent-browser + WebFetch 组合已覆盖基本需求。

这是一个有价值的"封顶"判定——证明不是所有生态位都能在免费生态中找到更好的工具，认清现实比盲目搜索更重要。

## SOP 补丁

**补丁 L2-P1**：多 Agent 启用条件从固定圈数改为任务复杂度驱动。当单圈有 ≥3 个独立生态位需要并发搜索时才启用，避免为了用而用。

## 真实 Diff 产出

- `ARMORY.md` — 新增 2 条淘汰记录（firecrawl、web-reader），深度爬取生态位标注"已封顶"
- 沙箱验证了 agent-browser 可用性（v0.12.0）

## 本圈成果

| 维度 | Loop 1 结束时 | Loop 2 结束时 |
|------|--------------|--------------|
| 搜索渠道 | skills.sh 单渠道 | 同（context7 仍不可用） |
| 知识积累 | 3 条精华提取 | +firecrawl 工作流决策模式 |
| 淘汰名单 | 5 条 | 7 条 |
| 封顶生态位 | 0 | 1（深度爬取） |
| agent-browser | 已装未验证 | 已验证可用 v0.12.0 |
