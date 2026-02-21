---
name: security-research
description: |
  自主渗透测试工作流，7 阶段端到端安全研究：扫描 → 验证 → 分析 → 数据流 → 利用 → 补丁 → 报告。
  基于 gadievron/raptor 框架，专为安全研究、漏洞验证、PoC 生成设计。
  关键词：penetration-testing, vulnerability-validation, exploit-development, security-assessment, red-team
---

# Security Research — 7 阶段渗透测试工作流

> 来源：gadievron/raptor (1.1k stars) 自主安全测试框架
> 核心公式：Good Skill = Expert-only Knowledge - What Claude Already Knows

## 激活条件

- 需要进行端到端渗透测试时
- 漏洞发现后需要验证可利用性时
- 需要生成工作漏洞利用 PoC 时
- 安全研究、教育、授权渗透测试场景

## 核心架构

### 7 阶段工作流

```
Phase 0: Pre-exploit Mitigation Analysis (前期缓解分析)
    ↓
Phase 1: Code Scanning (代码扫描) - Semgrep + CodeQL 并行
    ↓
Phase 2: Exploitability Validation (可利用性验证) - 过滤误报
    ↓
Phase 3: Autonomous Analysis (LLM 自主分析)
    ↓
Phase 4: Agentic Orchestration (智能编排)
    ↓
Phase 5-6: Exploit & Patch Generation (漏洞利用与补丁生成)
    ↓
Phase 7: Reporting (报告生成)
```

### 分层加载策略 (Progressive Loading)

| 触发事件 | 加载内容 |
|---------|----------|
| 扫描完成 | `tiers/analysis-guidance.md` |
| 验证阶段 | `exploitability-validation SKILL` |
| 验证错误 | `tiers/validation-recovery.md` |
| 开发利用 | `tiers/exploit-guidance.md` |
| 错误发生 | `tiers/recovery.md` |
| 按需 | `tiers/personas/[role].md` |

## 执行流程

### Phase 0: Pre-exploit Mitigation Analysis

分析目标二进制的安全缓解措施：

```python
# 必需：发现漏洞后先检查缓解措施
from packages.exploit_feasibility import analyze_binary, format_analysis_summary

result = analyze_binary('/path/to/binary', output_dir='./out')
print(format_analysis_summary(result, verbose=True))
```

**关键约束**：
- ASLR、DEP、Stack Canary、NX、Full RELRO 等
- 避免浪费精力于不可能的漏洞利用
- 输出：`unlikely` / `difficult` / `feasible` 裁决

**NEVER 依赖 checksec 或 readelf** — 它们会遗漏关键约束：
- Empirical %n verification
- Null byte constraints from strcpy
- ROP gadget quality
- Input handler bad bytes
- Full RELRO blocks .fini_array

### Phase 1: Code Scanning

并行执行 Semgrep + CodeQL：

```bash
# Semgrep 扫描
semgrep --config=auto --json --output=semgrep.json /path/to/code

# CodeQL 扫描
codeql database create /tmp/codeql-db --language=<lang>
codeql database analyze /tmp/codeql-db --format=sarif-latest --output=codeql.sarif
```

**关键参数**：
- `--languages`: 指定语言 (python, javascript, go, etc.)
- `--build-command`: 自定义构建命令
- `--codeql-only`: 仅运行 CodeQL
- `--no-codeql`: 禁用 CodeQL

### Phase 2: Exploitability Validation

6 阶段可利用性验证管道：

```
Stage 0: Inventory (清单) → 枚举所有文件和函数
    ↓
Stage A: One-Shot (一击) → 尝试 PoC 验证
    ↓
Stage B: Process (系统分析) → 构建攻击树，测试假设
    ↓
Stage C: Sanity Check (合理性) → 验证代码真实存在
    ↓
Stage D: Ruling (裁决) → 过滤测试代码/不现实前提
    ↓
Stage E: Feasibility (可行性) → 内存损坏专用，缓解措施分析
```

**验证决策表**：

| 判定 | 条件 |
|------|------|
| EXPLOITABLE | Source attacker-controlled + bypassable sanitizers + reachable + significant impact |
| FALSE POSITIVE | Source not attacker-controlled OR effective sanitizer OR unreachable |
| NEEDS TESTING | Requires some access, sanitizer unclear, complex conditions |

### Phase 3: Autonomous Analysis

LLM 驱动深度分析：

- 自动理解漏洞根因
- 生成漏洞利用代码
- 创建安全补丁
- 支持多 LLM 提供商：Anthropic、OpenAI、Ollama

### Phase 4: Agentic Orchestration

调用 Claude Code 代理进行深入分析：

- 读取相关代码文件
- 深入理解漏洞上下文
- 编写工作 PoC 代码
- 测试并验证利用

### Phase 5-6: Exploit & Patch Generation

从 Phase 3 分析结果同步完成：

```json
{
  "exploits_generated": 3,
  "patches_generated": 2,
  "findings": [...]
}
```

### Phase 7: Reporting

生成 JSON 格式最终报告：

```json
{
  "timestamp": "2026-02-21T...",
  "repository": "/path/to/code",
  "duration_seconds": 3600,
  "tools_used": {"semgrep": true, "codeql": true},
  "phases": {...},
  "outputs": {...}
}
```

## 四步漏洞验证框架 (Security Researcher Persona)

### Step 1: Source Control Analysis

判断数据来源控制权：

| 类型 | 例子 |
|------|------|
| Attacker Controlled | HTTP 参数、用户输入、URL 参数、Cookie、外部 API 响应 |
| Conditional Access | 配置文件、环境变量、数据库内容（需先获取权限） |
| Internal Only | 硬编码常量、框架生成值、信任的内部服务 |

### Step 2: Sanitizer Effectiveness Analysis

评估消毒剂有效性：

- 代码级实现分析（ sanitizer 实际做什么）
- 是否适合漏洞类型
- 常见绕过技术：编码、大小写敏感、逻辑错误、操作顺序
- 覆盖所有代码路径（分支、错误处理）

### Step 3: Reachability Analysis

评估攻击者能否触发漏洞代码：

- 认证要求：Public / Authenticated / Admin-only
- 授权检查和潜在 IDOR 漏洞
- 前置条件和生产部署状态

### Step 4: Impact Assessment

评估潜在损害：

- 数据库访问、代码执行、客户端攻击
- 最坏情况攻击链
- CVSS 评分指导

## 漏洞分类与验证要求

### 内存损坏类 (必须做 Stage E)

- buffer_overflow, heap_overflow, format_string
- use_after_free, double_free, integer_overflow
- out_of_bounds_read/write

需要运行 `analyze_binary()` 进行缓解措施分析。

### 非内存损坏类 (跳过 Stage E)

- command_injection, sql_injection, xss
- path_traversal, ssrf, deserialization

## 输出约定

- 使用人类可读状态值：`Exploitable`, `Confirmed`, `Ruled Out`, `Proven`, `Disproven`（无下划线，无全大写）
- 无红/绿指示器（🔴/🟢），其他表情符号可用
- 长报告必须写入文件

## NEVER 清单

- **NEVER** 跳过 Phase 0 的缓解措施分析就尝试开发利用
- **NEVER** 依赖 checksec 或 readsel 进行二进制分析
- **NEVER** 假设漏洞可利用而不验证（默认不可利用，直到证明相反）
- **NEVER** 生成破坏性 payload（仅无害 PoC）
- **NEVER** 在非授权目标上测试
- **NEVER** 跳过可利用性验证直接进入开发阶段
- **NEVER** 将测试/示例代码报告为真实漏洞
- **NEVER** 忽略不确定的声称（必须验证）

## 与现有工具的关系

| 工具 | 关系 | 说明 |
|------|------|------|
| security-reviewer | 互补 | security-reviewer 是 Read-only 代码审计，security-research 是端到端渗透测试工作流 |
| hunt | 互补 | hunt 是通用搜索策略，security-research 是安全领域的专业化工作流 |
| deep-research | 互补 | deep-research 是通用深度调研，security-research 专注于漏洞验证和利用生成 |
| rag / context7 | 正交 | 文档检索增强，不与安全研究工作流冲突 |
| tdd-workflow / code-refactoring | 无关 | 开发工作流，安全研究是独立领域 |

## 使用示例

```bash
# 完整自主工作流
python3 raptor.py agentic --repo /path/to/code

# 仅 Semgrep
python3 raptor.py agentic --repo /path/to/code --no-codeql

# 跳过可利用性验证
python3 raptor.py agentic --repo /path/to/code --skip-validation

# 聚焦特定漏洞类型
python3 raptor.py agentic --repo /path/to/code --vuln-type sql_injection
```
