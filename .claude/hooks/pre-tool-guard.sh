#!/bin/bash
# pre-tool-guard.sh — PreToolUse Hook
# Red line guard: block writes to protected directories, warn on main branch
# Triggers on: Edit, Write, MultiEdit

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Guard 1: Block writes to D:/ai/mcp-servers/ (red line)
if [ -n "$FILE_PATH" ]; then
  # Normalize path separators for Windows compatibility
  NORMALIZED=$(echo "$FILE_PATH" | sed 's|\\|/|g')
  if echo "$NORMALIZED" | grep -qi '^D:/ai/mcp-servers/\|^d:/ai/mcp-servers/'; then
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "RED LINE: D:/ai/mcp-servers/ is protected. Explicit user authorization required."
      }
    }'
    exit 0
  fi
fi

# Guard 2: Warn (but allow) when on main branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  jq -n --arg branch "$CURRENT_BRANCH" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ("WARNING: You are on the " + $branch + " branch. Consider creating a feature branch first.")
    }
  }'
  exit 0
fi

# All clear
exit 0
