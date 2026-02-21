#!/bin/bash
# pre-compact-save.sh — PreCompact Hook
# Saves current MEMORY.md state before context compaction
# Ensures critical state survives compaction

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
MEMORY_FILE="$PROJECT_DIR/MEMORY.md"

if [ -f "$MEMORY_FILE" ]; then
  cp "$MEMORY_FILE" "$PROJECT_DIR/MEMORY.bak"
fi

# Output timestamp to stderr (visible in verbose mode)
echo "[PreCompact] MEMORY.md backed up at $(date '+%H:%M:%S')" >&2
exit 0
