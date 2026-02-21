#!/bin/bash
# prompt-submit.sh — UserPromptSubmit Hook
# Auto-wake: remind Claude to read MEMORY.md at session start
# Outputs additionalContext so Claude sees the reminder

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
MEMORY_FILE="$PROJECT_DIR/MEMORY.md"
MARKER_FILE="/tmp/claude-memory-loaded-$$"

# Check if MEMORY.md exists
if [ ! -f "$MEMORY_FILE" ]; then
  exit 0
fi

# Use session_id based marker to avoid repeated reminders within same session
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
SESSION_MARKER="/tmp/claude-memory-${SESSION_ID}"

if [ -f "$SESSION_MARKER" ]; then
  # Already reminded this session
  exit 0
fi

# First prompt of session: create marker and inject MEMORY.md content
touch "$SESSION_MARKER"
MEMORY_CONTENT=$(cat "$MEMORY_FILE" 2>/dev/null | head -30)

jq -n --arg ctx "[AUTO-WAKE] MEMORY.md loaded:
$MEMORY_CONTENT" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: $ctx
  }
}'
exit 0
