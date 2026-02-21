# Claude Code 基础配置工作记录

> 创建时间：2026-02-19
> 工作目录：D:/ai/setup/
> 目的：打好地基，完成 Claude Code CLI 的初始配置

---

## 一、本次已完成的工作

### 1. GitHub + SSH 配置
- Git 2.52.0 + gh CLI 2.85.0 已就绪
- GitHub 账号：`themarshs`，协议：SSH
- SSH Key（ed25519）已生成并上传，名称 `PC-19132`

### 2. Dotfiles 备份仓库
- 仓库地址：https://github.com/themarshs/dotfiles（私有）
- 已备份：Claude Code 配置模板、OpenCode Agent 定义（归档）、VS Code 设置、Git/Shell/Terminal 配置
- 所有 API Key 已脱敏，附带 setup.sh 一键恢复脚本

### 3. D 盘目录整理
迁移前后对照：

| 旧路径 | 新路径 |
|--------|--------|
| D:/mcp-servers/ | D:/ai/mcp-servers/ |
| D:/claudecode/ | D:/ai/claude-workspace/ |
| D:/训练台/ + D:/xunliantai/ | D:/ai/lab/（合并） |
| D:/OpenCode/ | 已删除 |
| D:/LOG_202602/ | D:/logs/2026-02/ |
| D:/量化/ | D:/work/quant/ |

6 处路径指针已同步更新，govops-mcp-server 已重编译。

### 4. OpenCode 清理
- ~/.config/opencode/ 已删除
- ~/AppData/Roaming/OpenCode/ 已删除
- OpenCode Agent 定义已保留在 dotfiles 仓库中备查

### 5. Claude Code Skills 清理
- 22 个断裂的符号链接已全部删除
- ~/.agents/ 目录已删除
- ~/.claude/skills/ 目录已清空

### 6. Claude Code 升级
- 2.1.44 → 2.1.47（最新版）

### 7. Git 用户名修正
- `19132` → `themarshs`（与 GitHub 账号一致）

### 8. 权限配置
- settings.local.json 已配置全部放行（Bash/Read/Write/Edit/Glob/Grep/WebFetch/WebSearch/NotebookEdit）
- 不再需要逐个点 OK 确认

---

## 二、当前 Claude Code 配置状态

### 版本
- 当前：2.1.47（最新）

### C 盘配置文件（不可移动，体积极小）
| 文件 | 作用 |
|------|------|
| ~/.claude/settings.json | 核心运行配置（模型、API 地址、环境变量） |
| ~/.claude/settings.local.json | 权限配置（全部放行） |
| ~/.claude/config.json | API Key 存储 |
| ~/.claude.json | 运行时状态（账号、会话缓存等） |

### D 盘布局（实际内容）
```
D:/ai/
├── setup/              ← 基础配置工作目录
├── mcp-servers/        ← MCP 服务器
│   ├── .irongate/
│   ├── governance-mcp-server/
│   └── govops-mcp-server/
├── claude-workspace/   ← Claude Code 项目工作区
└── lab/                ← 实验/训练台
```

---

## 三、待完成的基础配置工作

### 优先级 P0：必须先做
- [x] ~~升级 Claude Code 到最新版（2.1.44 → 2.1.47）~~ ✓
- [x] ~~重新整理 permissions（全部放行）~~ ✓
- [x] ~~Git 用户名修正（19132 → themarshs）~~ ✓
- [ ] 在常用工作目录写 CLAUDE.md（代码风格、协作偏好）

### 优先级 P1：地基加固
- [ ] MCP Server 配置梳理（全局 vs 项目级，按需启用）
- [ ] Hooks 配置（生命周期钩子：危险命令拦截、提交前校验等）

### 优先级 P2：能力扩展
- [ ] Skills 按需重建（D:/ai/skills/ 存实际文件 → ~/.claude/skills/ 放符号链接）
- [ ] 自定义 Agents 配置
- [ ] Plugins 探索

---

## 四、Claude Code 可配置接口全景

### 配置文件层级（优先级从高到低）
1. managed-settings.json（组织级强制）
2. CLI 启动参数（单次会话）
3. .claude/settings.local.json（项目级个人）
4. .claude/settings.json（项目级共享）
5. ~/.claude/settings.json（全局个人）

### 扩展点
- **CLAUDE.md** — 项目级知识注入
- **.claude/rules/*.md** — 模块化规则（按 glob 匹配）
- **MCP Servers** — 外接工具服务器
- **Hooks** — 生命周期钩子（PreToolUse/PostToolUse 等）
- **Skills** — 自定义斜杠命令
- **Agents** — 自定义子 agent
- **Plugins** — 打包 skills + hooks + MCP 的完整插件

### 关键环境变量
- ANTHROPIC_BASE_URL / ANTHROPIC_API_KEY — API 连接
- ANTHROPIC_MODEL / ANTHROPIC_DEFAULT_*_MODEL — 模型选择
- API_TIMEOUT_MS / MAX_THINKING_TOKENS — 性能调优
- CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC — 禁用遥测
- MAX_MCP_OUTPUT_TOKENS — MCP 输出截断
- CLAUDE_CODE_TASK_LIST_ID — 跨会话任务列表共享

### 交互式命令
/config, /permissions, /model, /mcp, /memory, /compact, /rewind, /cost, /statusline, /theme, /debug
