# Claude Code 官方文档路由索引

> 来源：https://code.claude.com/docs
> 同步日期：2026-02-19
> 文档总数：57 篇
> 本地路径：D:/ai/setup/docs/

---

## 使用说明

后续对话中需要查阅某个主题时，直接引用本索引定位到本地文件路径，避免重复抓取。
格式：`Read D:/ai/setup/docs/<filename>.md`

---

## 一、入门（Getting Started）

| 文件 | 主题 | 概要 |
|------|------|------|
| `overview.md` | 产品总览 | Claude Code 是什么、能做什么、各平台入口（CLI/Desktop/Web/IDE/CI） |
| `quickstart.md` | 快速上手 | 8 步走通：安装→登录→首次会话→提问→改代码→用 Git→修 Bug→常见工作流 |
| `changelog.md` | 更新日志 | 版本变更记录 |

## 二、核心概念（Core Concepts）

| 文件 | 主题 | 概要 |
|------|------|------|
| `how-claude-code-works.md` | 工作原理 | **必读**。智能体循环（agentic loop）、模型与工具、上下文窗口管理、会话分支/恢复、检查点与权限、有效协作方式 |
| `features-overview.md` | 功能全景 | 所有扩展点对比（Skills vs Agents vs Hooks vs MCP vs Plugins），功能分层关系，上下文开销对比 |
| `common-workflows.md` | 常见工作流 | **必读**。代码理解、Bug 修复、重构、子智能体使用、Plan Mode、测试、PR、文档、图片、扩展思考、并行会话（worktree）、Unix 管道用法 |
| `best-practices.md` | 最佳实践 | **必读**。验证优先、先探索再规划再编码、CLAUDE.md 写法、权限配置、CLI 工具、MCP、Hooks、Skills、子智能体、上下文管理、并行扩展、常见失败模式 |

## 三、平台与集成（Platforms & Integrations）

| 文件 | 主题 | 概要 |
|------|------|------|
| `desktop-quickstart.md` | Desktop 快速上手 | 桌面端安装与首次使用 |
| `desktop.md` | Desktop 完整指南 | 会话管理、权限模式、Diff 视图、远程会话、企业配置（SSO/MDM） |
| `claude-code-on-the-web.md` | Web 版 | 云端异步执行、环境配置、网络策略、安全隔离 |
| `chrome.md` | Chrome 集成 | 浏览器自动化：测试本地应用、抓取数据、填表、录制 GIF |
| `vs-code.md` | VS Code 扩展 | 安装、提示框、文件引用、多会话、插件管理、与 CLI 的区别 |
| `jetbrains.md` | JetBrains 集成 | IntelliJ/PyCharm/WebStorm 插件安装与配置，WSL/远程开发 |
| `github-actions.md` | GitHub Actions | CI/CD 集成：自动 PR 审查、实现、Skills 使用、Bedrock/Vertex 配置 |
| `gitlab-ci-cd.md` | GitLab CI/CD | MR 自动创建、Bug 修复、OIDC 认证、安全治理 |
| `slack.md` | Slack 集成 | 在 Slack 中委派编码任务、仓库选择、权限控制 |

## 四、构建扩展（Build with Claude Code）⭐ 重点

### 4.1 多智能体

| 文件 | 主题 | 概要 |
|------|------|------|
| `sub-agents.md` | 子智能体 | **核心**。内建智能体（Explore/Plan/Bash/General）、自定义智能体创建（`.claude/agents/*.md`）、frontmatter 字段、模型选择、工具限制、持久记忆、前台/后台运行、链式调用、上下文管理 |
| `agent-teams.md` | 智能体团队 | **核心**。多会话协作：Lead 分配→Teammate 认领、共享任务列表、显示模式、委派模式、质量门控 Hook、架构与权限、并行代码审查、竞争假设调查 |

### 4.2 扩展机制

| 文件 | 主题 | 概要 |
|------|------|------|
| `skills.md` | Skills（自定义命令） | **核心**。创建 `/command`、SKILL.md 格式与 frontmatter、自动发现、动态上下文注入（`!command`）、参数传递、子智能体中运行、工具限制 |
| `hooks-guide.md` | Hooks 实战指南 | **核心**。首个 Hook 搭建、通知、自动格式化、文件保护、压缩后重注入、输入输出、Matcher、Prompt-based/Agent-based Hook |
| `hooks.md` | Hooks 技术参考 | **核心**。完整生命周期（15 个事件）、每个事件的输入 schema 与决策控制、JSON 输出格式、异步 Hook、安全考量、调试方法 |
| `plugins.md` | 插件开发 | 插件 = Skills + Hooks + MCP + Agents + LSP 打包。创建流程、目录结构、本地测试、发布分享、从现有配置迁移 |
| `plugins-reference.md` | 插件技术参考 | manifest schema（plugin.json）、组件路径规则、安装作用域、CLI 命令、调试排错 |
| `discover-plugins.md` | 插件市场 | 官方市场（代码智能/外部集成/开发工作流/输出样式）、添加市场源、安装管理、团队市场配置 |
| `plugin-marketplaces.md` | 市场创建与分发 | 市场文件 schema、插件条目格式、GitHub/Git 托管、版本解析、发布渠道、团队强制市场 |
| `output-styles.md` | 输出样式 | 内建样式、自定义样式创建、与 CLAUDE.md/Agents/Skills 的区别 |
| `headless.md` | 编程式调用 | `claude -p` 无头模式、结构化输出（JSON schema）、流式响应、自动批准、系统提示定制、会话续接 |
| `mcp.md` | MCP 服务器 | **核心**。安装方式（HTTP/SSE/stdio）、作用域（Local/Project/User）、环境变量展开、实战示例（Sentry/GitHub/PostgreSQL）、OAuth 认证、Tool Search 机制、MCP Prompts、管理员管控 |

## 五、部署（Deployment）

| 文件 | 主题 | 概要 |
|------|------|------|
| `third-party-integrations.md` | 部署总览 | Bedrock/Vertex/Foundry 对比、代理网关配置、组织最佳实践 |
| `amazon-bedrock.md` | AWS Bedrock | 凭证配置、IAM、Guardrails |
| `google-vertex-ai.md` | Google Vertex AI | GCP 凭证、区域配置、1M 上下文窗口 |
| `microsoft-foundry.md` | Microsoft Foundry | Azure 凭证、RBAC |
| `network-config.md` | 网络配置 | 代理（HTTP_PROXY）、自定义 CA、mTLS |
| `llm-gateway.md` | LLM 网关 | LiteLLM 配置、统一端点、Provider 透传 |
| `devcontainer.md` | 开发容器 | devcontainer 安全隔离、团队 onboarding、CI/CD 一致性 |

## 六、管理（Administration）

| 文件 | 主题 | 概要 |
|------|------|------|
| `setup.md` | 安装配置 | 系统要求、平台安装、认证方式、版本管理、自动更新、卸载 |
| `authentication.md` | 认证 | Teams/Enterprise、Console、云厂商认证方式 |
| `security.md` | 安全 | 权限架构、Prompt 注入防护、MCP/IDE/Cloud 安全、最佳实践 |
| `server-managed-settings.md` | 服务端管理设置 | 中心化组织配置下发、优先级、缓存、审计日志 |
| `data-usage.md` | 数据使用 | 训练策略、数据保留、遥测服务、API 提供商行为 |
| `monitoring-usage.md` | 监控 | OpenTelemetry 配置、指标（会话/代码行/PR/成本/Token）、事件（Prompt/工具/API） |
| `costs.md` | 成本管理 | `/cost` 命令、团队限速、Token 节省技巧（上下文管理、模型选择、MCP 开销、子智能体委派） |
| `analytics.md` | 分析仪表盘 | 团队采用率、PR 归因、ROI 度量、API 数据访问 |

## 七、配置（Configuration）

| 文件 | 主题 | 概要 |
|------|------|------|
| `settings.md` | 设置体系 | **核心**。5 级作用域、settings.json 字段全列表、权限规则语法、沙盒设置、Hook 配置、环境变量、系统提示、文件排除 |
| `permissions.md` | 权限配置 | **核心**。权限模式、规则语法（工具+specifier+通配符）、各工具专属规则（Bash/Read/Edit/WebFetch/MCP/Task）、Hook 扩展权限、工作目录、管理员设置 |
| `sandboxing.md` | 沙盒 | 文件系统隔离、网络隔离、OS 级强制、模式配置、与权限的关系 |
| `terminal-config.md` | 终端配置 | 主题、换行、通知（iTerm2/自定义 Hook）、大输入处理、Vim 模式 |
| `model-config.md` | 模型配置 | 可用模型、别名、模型限制、default/opusplan 行为、effort level、扩展上下文、环境变量 |
| `fast-mode.md` | 快速模式 | Opus 4.6 fast mode、成本权衡、与 effort level 区别、组织启用 |
| `memory.md` | 记忆系统 | **核心**。Auto Memory、CLAUDE.md imports、记忆查找机制、`/memory` 命令、项目记忆、`.claude/rules/*.md` 模块化规则（glob 路径匹配）、组织级记忆管理 |
| `statusline.md` | 状态栏 | `/statusline` 配置、可用数据字段、示例（上下文用量/Git 状态/成本追踪/可点击链接） |
| `keybindings.md` | 快捷键 | 配置文件格式、所有可用 Action、按键语法、Chord、Vim 模式交互 |

## 八、参考（Reference）

| 文件 | 主题 | 概要 |
|------|------|------|
| `cli-reference.md` | CLI 参考 | 所有命令与 Flag 完整列表 |
| `interactive-mode.md` | 交互模式 | 快捷键、内建命令、Vim 模式、命令历史、后台 Bash、提示建议、任务列表 |
| `checkpointing.md` | 检查点 | 自动追踪、回退与摘要、常见用例、限制 |
| `legal-and-compliance.md` | 法律合规 | 许可证、商业协议、BAA、使用政策 |

---

## 快速查找指南

### 按场景定位

| 我想要... | 读这个 |
|-----------|--------|
| 理解 Claude Code 整体架构 | `how-claude-code-works.md` |
| 创建自定义智能体 | `sub-agents.md` |
| 多智能体协作 | `agent-teams.md` |
| 写 CLAUDE.md | `memory.md` + `best-practices.md` |
| 配置 MCP 工具 | `mcp.md` |
| 搭建生命周期钩子 | `hooks-guide.md`（实战）+ `hooks.md`（参考） |
| 创建自定义 /command | `skills.md` |
| 开发插件 | `plugins.md` + `plugins-reference.md` |
| 找现成插件 | `discover-plugins.md` |
| 脚本/CI 中调用 Claude | `headless.md` + `github-actions.md` |
| 理解权限与安全 | `permissions.md` + `sandboxing.md` + `security.md` |
| 配置全局设置 | `settings.md` |
| 省钱 | `costs.md` + `fast-mode.md` + `model-config.md` |
| 理解所有功能的区别 | `features-overview.md` |

### 按优先级（搭架构推荐阅读顺序）

1. `how-claude-code-works.md` — 先理解底层
2. `features-overview.md` — 理解各扩展点的定位与区别
3. `best-practices.md` — 官方推荐的用法
4. `memory.md` — CLAUDE.md 与记忆体系
5. `settings.md` — 配置层级
6. `permissions.md` — 权限体系
7. `sub-agents.md` — 自定义智能体
8. `agent-teams.md` — 多智能体协作
9. `hooks.md` + `hooks-guide.md` — 生命周期钩子
10. `skills.md` — 自定义命令
11. `mcp.md` — MCP 工具连接
12. `plugins.md` — 插件打包
