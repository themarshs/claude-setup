# 检索能力建设

> 创建时间：2026-02-19
> 目的：逐步搭建和武装 Claude Code 的检索能力

---

## 一、当前已装

### 检索类

| Skill | 来源 | 功能 | 状态 |
|-------|------|------|------|
| find-skills | vercel-labs/skills | 搜索 Skills 生态 | 已装，已验证，原理已分析 |
| self-learning | philschmid/self-learning-skill | 自动学习新技术并生成 Skill | 已装，安全评估: Gen:High/Socket:0/Snyk:Med |
| context7 | intellectronica/agent-skills | 查最新技术文档，curl 调 context7.com API，免费无需 Key | 已装，Gen:Safe/Socket:0/Snyk:Med |
| remembering-conversations | obra/episodic-memory | 跨会话记忆（需 episodic-memory MCP 配合） | 已装，Gen:Med/Socket:0/Snyk:Low，⚠️ 待配 MCP |

### 方法论类

| Skill | 来源 | 功能 | 安全评估 | 状态 |
|-------|------|------|----------|------|
| brainstorming | obra/superpowers | 协作式设计，实现前先 brainstorm | Gen:Safe/Socket:0/Snyk:Low | 已装，原理已分析 |

### Skill 生命周期类（找→学→造→写→审→用）

| Skill | 来源 | 功能 | 安全评估 | 状态 |
|-------|------|------|----------|------|
| skill-creator | anthropics/skills | 官方 Skill 创建指南，渐进式加载设计 | Gen:Safe/Socket:0/Snyk:Low | 已装，原理已分析 |
| writing-skills | obra/superpowers | TDD 写 Skill：无失败测试不写 Skill | Gen:Safe/Socket:0/Snyk:Low | 已装，原理已分析 |
| skill-judge | softaworks/agent-toolkit | 120 分制 8 维评估 Skill 质量 | Gen:Safe/Socket:0/Snyk:Low | 已装，原理已分析 |
| verification-before-completion | obra/superpowers | 完成前必须有验证证据 | Gen:Safe/Socket:0/Snyk:Low | 已装，原理已分析 |
| using-superpowers | obra/superpowers | 强制 Skill 调用流程，防止"有武装不触发" | Gen:Safe/Socket:1/Snyk:Low | 已装，原理已分析 |

---

## 二、候选 Skills（按检索层次分类）

### 第一层：发现与探索（找到信息在哪）

| Skill | 来源 | 安装量 | 做什么 | 优先级 |
|-------|------|--------|--------|--------|
| context7 | upstash/context7 | 804 | 查最新技术文档，解决训练截止问题 | P1 |
| docs-seeker | mrgoonie/claudekit-skills | 120 | 搜索文档 | P2 |
| information-architecture | aj-geddes/useful-ai-prompts | 79 | 信息架构设计 | P2 |

### 第二层：获取与抓取（拿到信息）

| Skill | 来源 | 安装量 | 做什么 | 优先级 |
|-------|------|--------|--------|--------|
| agent-browser | vercel-labs/agent-browser | 44.5K | 给 agent 浏览器操作能力 | P1 |
| firecrawl | firecrawl/cli | 4.4K | 网页抓取，结构化提取 | P1 |
| tavily search | tavily-ai/skills | 1.4K | 搜索引擎 API | P2 |
| tavily extract | tavily-ai/skills | 1.9K | 内容提取 | P2 |
| tavily research | tavily-ai/skills | 1.3K | 深度研究 | P2 |
| just-scrape | scrapegraphai | 1.5K | 轻量爬虫 | P3 |

### 第三层：记忆与学习（留住信息）

| Skill | 来源 | 安装量 | 做什么 | 优先级 |
|-------|------|--------|--------|--------|
| remembering-conversations | obra/episodic-memory | 5.1K | 跨会话记忆 | P0 |
| self-learning | philschmid/self-learning-skill | 1.2K | 自学习能力 | P1 |
| knowledge | boshu2/agentops | 89 | 知识管理 | P2 |

### 第四层：研究与分析（用好信息）

| Skill | 来源 | 安装量 | 做什么 | 优先级 |
|-------|------|--------|--------|--------|
| user-research-synthesis | anthropics/knowledge-work-plugins | 122 | 研究综合 | P2 |
| knowledge-distillation | orchestra-research/ai-research-skills | 17 | 知识蒸馏 | P3 |

---

## 三、搜索记录

### 2026-02-19 首次搜索

使用 `npx skills find` 执行的搜索：

| 关键词 | 结果数 | 有价值的发现 |
|--------|--------|-------------|
| "search discover explore" | 6 | information-architecture, skill-discovery |
| "research knowledge" | 6 | knowledge-distillation, user-research-synthesis |
| "context retrieval memory" | 0 | 无结果（关键词组合过长） |
| "browser scrape crawl" | 6 | just-scrape, agentic-browser |
| "self-learning" | 6 | self-learning (philschmid) |
| "tavily firecrawl" | 6 | firecrawl (4.4K installs) |
| "context7 documentation" | 6 | context7 documentation-lookup (804) |
| "remembering episodic" | 6 | remembering-conversations (5.1K) |

**搜索工具局限性：**
- `npx skills find` 只支持关键词匹配，不支持分类/标签过滤
- 多词搜索匹配逻辑不明确，太多词会返回 0 结果
- 泛化浏览需要配合 skills.sh 网页端或 WebFetch 全量抓取

---

## 四、待办

- [ ] 逐个深入调研每个候选 Skill 的 SKILL.md 原理（先搞懂再装）
- [ ] 确认哪些需要外部 API Key（如 tavily、firecrawl）
- [ ] 确认哪些与已有 MCP 服务器功能重叠
- [ ] 按优先级逐步安装和验证
- [ ] 每装一个，记录：原理、效果、与其他工具的配合关系
