#!/bin/bash
# post-compact-restore.sh — SessionStart Hook (matcher=compact)
# Injects MEMORY.md content into Claude's context after compaction
# This is the "awakening sequence" - ensures state recovery

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
MEMORY_FILE="$PROJECT_DIR/MEMORY.md"

if [ -f "$MEMORY_FILE" ]; then
  echo "=== MEMORY.md STATE RECOVERED ==="
  cat "$MEMORY_FILE"
  echo "=== END MEMORY.md ==="
else
  echo "[WARNING] MEMORY.md not found at $PROJECT_DIR - starting fresh"
fi

exit 0
