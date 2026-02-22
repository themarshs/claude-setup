#!/bin/bash
# post-compact-restore.sh — SessionStart Hook (matcher=compact)
# Full state + execution memory recovery after compaction.
# Addresses root cause #1: compact loses "how to do" not just "what to do".

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
MEMORY_FILE="$PROJECT_DIR/MEMORY.md"
CLAUDE_FILE="$PROJECT_DIR/CLAUDE.md"
ARMORY_FILE="$PROJECT_DIR/ARMORY.md"

echo "=== POST-COMPACT RECOVERY ==="

# 1. State recovery
if [ -f "$MEMORY_FILE" ]; then
  echo "--- MEMORY.md ---"
  cat "$MEMORY_FILE"
  echo ""
fi

# 2. Execution discipline reminder (compact loses these)
echo "--- EXECUTION DISCIPLINE (re-injected after compact) ---"
echo "1. 配置文件编辑前必须先查文档（WebSearch/context7），compliance-check Hook 会硬阻断"
echo "2. Grep 搜索前注意 search-router 的分类建议（structural→Glob, semantic→Task/WebSearch）"
echo "3. 3-Strike 方法等价类：改不同配置文件 = 同一类方法，不算换方法"
echo "4. Rules 只有 3 条核心（confidence-gate, error-discipline, language），其余按需从 rules-conditional/ 加载"
echo "5. 置信度 <70% 时停下来问，不猜"

# 3. CLAUDE.md core directives (abbreviated — full file in system prompt)
if [ -f "$CLAUDE_FILE" ]; then
  echo ""
  echo "--- CLAUDE.md CORE ---"
  head -20 "$CLAUDE_FILE"
fi

echo "=== END POST-COMPACT RECOVERY ==="
exit 0
