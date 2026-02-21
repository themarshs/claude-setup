---
name: hunt
description: 螺旋 SOP 发散阶段的多渠道搜索策略。4 步渐进式搜索 + 反偏见检查 + 结构化评估，确保不遗漏高价值候选。
---

# Hunt — 发散阶段搜索策略

> 螺旋 SOP 第 2 步。目标：最大化召回率，零遗漏高星仓库。

## 激活条件

- 螺旋 SOP 进入发散阶段时
- 需要为某个生态位搜索工具/Skill/仓库时
- Lead 派发搜索任务时

## 输入

```yaml
topic: <搜索主题，如 "MCP server" "code review tool">
niche: <生态位标签，对应 ARMORY.md 中的分类>
context: <可选，额外约束或偏好>
```

## 搜索策略（4 步，严禁跳步）

### Step 1: 基线搜索（全景扫描）

无限定词，纯星数排序，Top 50。目的：建立该领域的全景视图，防止限定词偏见。

```
mcp__github__search_repositories:
  query: "<topic>"
  sort: "stars"
  order: "desc"
  perPage: 50
```

记录：Top 50 名称 + 星数 + 描述。这是基线参照表。

### Step 2: 限定词搜索（多维探测）

设计 3-5 条不同维度的查询，每条 Top 30。维度示例：

| 维度 | 查询模式 | 示例 |
|------|----------|------|
| 功能词 | `<topic> + 功能关键词` | `"mcp server typescript"` |
| 场景词 | `<topic> + 使用场景` | `"mcp server cli automation"` |
| 同义词 | 换一种叫法 | `"model context protocol"` |
| 技术栈 | 限定语言/框架 | `"mcp server language:typescript"` |
| 非英文 | 中文/日文关键词 | `"MCP 服务器"` |

```
mcp__github__search_repositories:
  query: "<限定词组合>"
  sort: "stars"
  order: "desc"
  perPage: 30
```

每条查询独立记录结果。标记哪些是 Step 1 已出现的，哪些是新发现的。

### Step 3: Skills 生态搜索

用 3-5 条不同关键词搜索 skills.sh：

```bash
npx skills find "<keyword1>"
npx skills find "<keyword2>"
npx skills find "<keyword3>"
```

关键词策略：主题词、同义词、上位词、下位词各至少一条。

### Step 4: 交叉验证

对比 Step 1/2/3 的结果：

1. **遗漏检测**：Step 2/3 发现但 Step 1 未出现的 → 标记为"基线外发现"，重点关注
2. **共现确认**：多个 Step 都出现的 → 标记为"高置信候选"
3. **孤立项审视**：只在单一查询出现的 → 不排除，但标记为"需额外验证"

## 结果评估模板

每个候选填写以下卡片：

```yaml
- name: <仓库/Skill 名>
  url: <链接>
  stars: <星数或安装量>
  description: <一句话描述>
  niche_match: <0-10>  # 与目标生态位的匹配度
  appeared_in: [step1, step2-query3]  # 出现在哪些搜索中
  verdict: <enter_trial | low_priority | exclude>
  reason: <判定理由，排除时必填>
```

**verdict 判定标准**：

| 判定 | 条件 |
|------|------|
| enter_trial | niche_match ≥ 7，或星数 Top 10 且 match ≥ 5 |
| low_priority | niche_match 4-6，备用 |
| exclude | niche_match ≤ 3，或明确不相关，或已废弃 |

## 反偏见检查清单

搜索完成后逐项自查，全部通过才算完成：

- [ ] 是否执行了无限定词基线搜索（Step 1）？
- [ ] 基线搜索是否取了 Top 50（不是 20）？
- [ ] 限定词搜索是否覆盖了 ≥3 个不同维度？
- [ ] 是否搜索了同义词/非英文关键词？
- [ ] 是否做了 skills.sh 搜索？
- [ ] 是否完成了交叉验证（Step 4）？
- [ ] 是否有"基线外发现"被标记？

任何一项未通过 → 补做，不得跳过。

## 输出：Handoff 文档

搜索完成后，产出以下结构化文档交接给审判阶段：

```markdown
# Hunt Report: <topic>

## 搜索统计
- 基线搜索：<N> 个结果
- 限定词搜索：<M> 条查询，<K> 个去重结果
- Skills 搜索：<L> 个结果
- 基线外发现：<X> 个

## 反偏见检查：全部通过 ✓ / 未通过项：...

## P0 候选（enter_trial）
<评估卡片列表，按 niche_match 降序>

## P1 候选（low_priority）
<评估卡片列表>

## 排除项
<名称 + 排除理由，简要>
```

## 计次熔断

6 轮搜索（Step 1 算 1 轮，Step 2 每条查询算 1 轮）后仍无 niche_match ≥ 8 的候选 → 停止搜索，在 Handoff 文档中标注"建议转 skill-creator 自造"，交由 Lead 决策。
