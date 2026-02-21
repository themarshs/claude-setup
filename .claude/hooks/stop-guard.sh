#!/bin/bash
# stop-guard.sh — Stop Hook
# Prevents Claude from stopping during autonomous iteration
# Checks MEMORY.md for active tasks; if found, blocks stopping

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
MEMORY_FILE="$PROJECT_DIR/MEMORY.md"
INPUT=$(cat)

# Check if stop_hook_active to prevent infinite loop
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

# Check if MEMORY.md indicates active iteration
if [ -f "$MEMORY_FILE" ]; then
  if grep -q "用户授权.*全自主" "$MEMORY_FILE"; then
    # User authorized autonomous iteration, check if there are pending tasks
    if grep -q "下一步" "$MEMORY_FILE"; then
      echo '{"decision":"block","reason":"Autonomous iteration active. Read MEMORY.md for next task and continue working."}'
      exit 0
    fi
  fi
fi

exit 0
