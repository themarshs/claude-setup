#!/bin/bash
# post-tool-dirty-tracker.sh — PostToolUse Hook
# Tracks files modified by Edit/Write/Bash operations into a dirty-files list
# Used by the memory-updater agent at session end to update MEMORY.md

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
DIRTY_FILE="$PROJECT_DIR/.claude/.dirty-files"
INPUT=$(cat)

# Extract tool name and file path from hook input
TOOL_NAME=$(echo "$INPUT" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{console.log(JSON.parse(d).tool_name||'')}catch(e){console.log('')}})" 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{const j=JSON.parse(d);console.log(j.tool_input?.file_path||j.tool_input?.command||'')}catch(e){console.log('')}})" 2>/dev/null)

# Only track file-modifying operations
case "$TOOL_NAME" in
  Edit|Write|NotebookEdit)
    if [ -n "$FILE_PATH" ]; then
      echo "$FILE_PATH" >> "$DIRTY_FILE"
      # Deduplicate
      if [ -f "$DIRTY_FILE" ]; then
        sort -u "$DIRTY_FILE" -o "$DIRTY_FILE"
      fi
    fi
    ;;
  Bash)
    # Track bash commands that modify files (git mv, rm, mv, cp)
    if echo "$FILE_PATH" | grep -qE '(git (mv|rm)|^mv |^rm |^cp |> )'; then
      echo "BASH: $FILE_PATH" >> "$DIRTY_FILE"
    fi
    ;;
esac

exit 0
