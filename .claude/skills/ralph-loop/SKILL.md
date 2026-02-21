---
name: ralph-loop
description: |
  WHAT: Stop Hook 自循环机制 — 拦截 Claude 退出，注入相同 prompt，实现无人值守迭代开发
  WHEN: 明确完成标准的迭代任务（TDD 红绿循环、greenfield 构建、批量重构）需要无人值守运行时
  KEYWORDS: ralph, loop, autonomous, iterate, overnight, unattended, while-true, self-loop
---

# Ralph Loop — Stop Hook 自循环机制

## 核心架构（3 个组件）

```
/ralph-loop command          Stop Hook (stop-hook.sh)         状态文件
       |                           |                             |
  解析参数 →                   stdin 接收                  .claude/ralph-loop.local.md
  写状态文件 →                transcript_path →              YAML frontmatter:
  输出初始 prompt             读最后 assistant 消息 →          iteration / max / promise
                              检查 <promise> 标签 →          --- 分隔 ---
                              未完成 → 输出 block JSON        prompt 原文
                              已完成 → 删状态文件 exit 0
```

## Stop Hook block 协议（Expert-only）

Hook 通过 stdout 返回 JSON 控制退出行为：

```json
{
  "decision": "block",
  "reason": "此处放下一轮要执行的 prompt 文本",
  "systemMessage": "iteration 2 | To stop: output <promise>DONE</promise>"
}
```

- `decision: "block"` — 阻止退出，继续会话
- `reason` — 注入为下一轮用户消息（ralph 用它反复喂相同 prompt）
- `systemMessage` — 显示在会话中的系统提示
- Hook 返回空/exit 0 无 JSON = 允许退出

## 状态文件格式

路径：`.claude/ralph-loop.local.md`（存在即激活，删除即停止）

```markdown
---
active: true
iteration: 1
max_iterations: 20
completion_promise: "ALL TESTS PASS"
started_at: "2026-02-21T10:00:00Z"
---

Build a REST API for todos.
When complete, output <promise>ALL TESTS PASS</promise>
```

关键设计：prompt 在文件中，不在上下文里。每轮 Hook 从文件读 prompt，不依赖会话记忆。

## 完成信号检测机制

1. Hook 通过 stdin 获得 `transcript_path`（JSONL 格式转录文件）
2. grep `"role":"assistant"` + `tail -1` 取最后一条 assistant 消息
3. jq 提取 `.message.content[].text`
4. Perl 正则提取 `<promise>TEXT</promise>` 标签内容
5. 精确字符串比较（`=` 非 `==`，避免 glob 匹配陷阱）
6. 匹配成功 → 删状态文件 → exit 0（允许退出）

```bash
# 关键提取逻辑（Git Bash 兼容）
PROMISE_TEXT=$(echo "$LAST_OUTPUT" | \
  perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' \
  2>/dev/null || echo "")
if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
  rm "$RALPH_STATE_FILE" && exit 0
fi
```

## 安全阀双保险

| 机制 | 作用 | 默认值 |
|------|------|--------|
| `max_iterations` | 硬性迭代上限 | 0（无限） |
| `completion_promise` | 语义退出信号 | null（不检测） |

**必须至少设一个**，否则无限循环。推荐同时设两个。

## 与现有 stop-guard.sh 共存方案

### 执行顺序
settings.json 的 `Stop` 数组中注册多个 Hook 时**全部执行**，任一返回 `block` 则阻止退出。

### 共存策略
```
stop-guard.sh:  检查 MEMORY.md 中的 "全自主" 标记 → block（继续工作）
ralph-loop:     检查 .claude/ralph-loop.local.md → block + 注入 prompt
```

两者互不冲突：
- stop-guard 基于 MEMORY.md 语义（"还有下一步"）
- ralph-loop 基于状态文件存在性 + prompt 重放
- 同时激活时，ralph-loop 的 `reason` 字段会覆盖下一轮输入

### settings.json 注册（追加到现有 Stop 数组）
```json
"Stop": [
  {
    "hooks": [
      { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/stop-guard.sh\"", "timeout": 10 }
    ]
  },
  {
    "hooks": [
      { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/ralph-stop-hook.sh\"", "timeout": 15 }
    ]
  }
]
```

## 决策树

```
需要无人值守迭代？
├─ 否 → 普通执行或 stop-guard 自主模式
└─ 是 → 有明确完成标准？
    ├─ 否 → 不要用 ralph（会无限循环）
    └─ 是 → 完成标准可自动验证？
        ├─ 是（测试通过/lint 清零）→ ralph-loop + completion-promise
        └─ 否（需人类判断）→ ralph-loop + max-iterations
```

## Windows (Git Bash) 适配要点

| 依赖 | Git Bash 自带 | 需额外安装 |
|------|:---:|:---:|
| bash/sed/awk/grep | Y | - |
| perl | Y | - |
| jq | - | Y（`winget install jqlang.jq`）|

路径注意：状态文件用相对路径 `.claude/ralph-loop.local.md`，Hook 内用 `$CLAUDE_PROJECT_DIR` 拼绝对路径。

## Prompt 编写模板

```markdown
[任务描述]

每轮迭代步骤：
1. 读取当前代码/测试状态
2. 实施下一个改进
3. 运行测试验证
4. git commit 成果
5. 如果所有要求满足 → 输出 <promise>DONE</promise>

要求：
- [ ] 要求 A
- [ ] 要求 B
- [ ] 要求 C（全部完成才能输出 promise）
```

## NEVER

1. **NEVER** 不设安全阀就启动 ralph-loop（必须 max-iterations 或 completion-promise 至少一个）
2. **NEVER** 用 `==` 比较 promise 文本（bash `[[ ]]` 中 `==` 做 glob 匹配，用 `=`）
3. **NEVER** 在 completion-promise 中使用 `*`、`?`、`[` 等 glob 字符
4. **NEVER** 手动编辑运行中的状态文件 iteration 字段为非数字（Hook 会检测并终止）
5. **NEVER** 对需要人类判断的任务使用 ralph-loop（UI 设计、产品决策等）
6. **NEVER** 在 prompt 中省略文件读取步骤（每轮必须重新读文件，不依赖上下文记忆）
7. **NEVER** 输出虚假的 `<promise>` 来逃离循环（即使认为任务不可能完成）
