#!/bin/bash
# post-tool-dirty-tracker.sh — PostToolUse Hook
# Tracks files modified by Edit/Write/Bash operations into a dirty-files list
# Used by the memory-updater agent at session end to update MEMORY.md
# Also marks [STALE] on ARCHITECTURE_MAP.md sections whose sources were modified

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
DIRTY_FILE="$PROJECT_DIR/.claude/.dirty-files"
ARCH_MAP="$PROJECT_DIR/ARCHITECTURE_MAP.md"
INPUT=$(cat)

# Extract tool name and file path from hook input
TOOL_NAME=$(echo "$INPUT" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{console.log(JSON.parse(d).tool_name||'')}catch(e){console.log('')}})" 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{const j=JSON.parse(d);console.log(j.tool_input?.file_path||j.tool_input?.command||'')}catch(e){console.log('')}})" 2>/dev/null)

# --- STALE marker function ---
# Given a modified file path, check if any <!-- sources: ... --> line in
# ARCHITECTURE_MAP.md references it. If so, append [STALE] to the heading
# on the line immediately above (if not already marked).
mark_stale() {
  local modified_file="$1"
  [ -f "$ARCH_MAP" ] || return 0

  # Extract just the filename (basename) for matching
  local base_name
  base_name=$(basename "$modified_file")
  [ -z "$base_name" ] && return 0

  # Check if any sources line references this file
  if ! grep -q "<!-- sources:.*${base_name}" "$ARCH_MAP" 2>/dev/null; then
    return 0
  fi

  # Process: find source comment lines containing this file, mark the heading above
  local line_nums
  line_nums=$(grep -n "<!-- sources:.*${base_name}" "$ARCH_MAP" | cut -d: -f1)
  [ -z "$line_nums" ] && return 0

  local needs_update=false
  for ln in $line_nums; do
    # The heading is on the line above the sources comment
    local heading_ln=$((ln - 1))
    [ "$heading_ln" -lt 1 ] && continue

    # Read the heading line
    local heading
    heading=$(sed -n "${heading_ln}p" "$ARCH_MAP")

    # Only process markdown headings (## or ###)
    if echo "$heading" | grep -qE '^#{1,6} ' && ! echo "$heading" | grep -qF '[STALE]'; then
      needs_update=true
      break
    fi
  done

  if [ "$needs_update" = true ]; then
    # Use sed with .bak suffix for Windows Git Bash compatibility
    for ln in $line_nums; do
      local heading_ln=$((ln - 1))
      [ "$heading_ln" -lt 1 ] && continue

      local heading
      heading=$(sed -n "${heading_ln}p" "$ARCH_MAP")

      if echo "$heading" | grep -qE '^#{1,6} ' && ! echo "$heading" | grep -qF '[STALE]'; then
        # Append [STALE] to the heading
        sed -i.bak "${heading_ln}s/$/ [STALE]/" "$ARCH_MAP"
        rm -f "${ARCH_MAP}.bak"
      fi
    done
  fi
}

# Only track file-modifying operations
case "$TOOL_NAME" in
  Edit|Write|NotebookEdit)
    if [ -n "$FILE_PATH" ]; then
      echo "$FILE_PATH" >> "$DIRTY_FILE"
      # Deduplicate
      if [ -f "$DIRTY_FILE" ]; then
        sort -u "$DIRTY_FILE" -o "$DIRTY_FILE"
      fi
      # Check STALE marking
      mark_stale "$FILE_PATH"
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
