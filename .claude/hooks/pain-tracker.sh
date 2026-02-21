#!/bin/bash
# pain-tracker.sh — PostToolUse Hook (L1 Pain Ledger)
# Tracks search tool invocations, detects repetition patterns
# Zero-cost bookkeeping for the dual-helix evolution framework
#
# Triggers on: Grep, Glob, WebSearch, mcp__distillery__search,
#              mcp__github__search_code, mcp__github__search_repositories

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
HISTORY_FILE="$PROJECT_DIR/.claude/.search_history"
LEDGER_FILE="$PROJECT_DIR/.claude/.pain_ledger.json"
MAX_HISTORY=20
REPEAT_THRESHOLD=3

INPUT=$(cat)

# --- Extract tool_name via bash string ops (no jq dependency) ---
extract_json_string() {
  local key="$1" json="$2"
  # Match "key":"value" or "key": "value", handle escapes minimally
  echo "$json" | sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
}

TOOL_NAME=$(extract_json_string "tool_name" "$INPUT")

# Only process search tools
case "$TOOL_NAME" in
  Grep|Glob|WebSearch|mcp__distillery__search|mcp__github__search_code|mcp__github__search_repositories)
    ;;
  *)
    exit 0
    ;;
esac

# --- Extract query/pattern parameter ---
QUERY=""
case "$TOOL_NAME" in
  Grep)
    QUERY=$(extract_json_string "pattern" "$INPUT")
    ;;
  Glob)
    QUERY=$(extract_json_string "pattern" "$INPUT")
    ;;
  WebSearch)
    QUERY=$(extract_json_string "query" "$INPUT")
    ;;
  mcp__distillery__search)
    QUERY=$(extract_json_string "query" "$INPUT")
    ;;
  mcp__github__search_code|mcp__github__search_repositories)
    QUERY=$(extract_json_string "query" "$INPUT")
    ;;
esac

[ -z "$QUERY" ] && exit 0

# --- Append to search history (sliding window) ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")
echo "${TIMESTAMP}|${TOOL_NAME}|${QUERY}" >> "$HISTORY_FILE"

# Trim to last MAX_HISTORY lines
if [ -f "$HISTORY_FILE" ]; then
  TOTAL=$(wc -l < "$HISTORY_FILE")
  if [ "$TOTAL" -gt "$MAX_HISTORY" ]; then
    tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
    mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
  fi
fi

# --- Detect repetition within the window ---
# Count occurrences of same tool + similar query (exact match for speed)
COUNT=0
while IFS='|' read -r _ts _tool _query; do
  if [ "$_tool" = "$TOOL_NAME" ] && [ "$_query" = "$QUERY" ]; then
    COUNT=$((COUNT + 1))
  fi
done < "$HISTORY_FILE"

if [ "$COUNT" -ge "$REPEAT_THRESHOLD" ]; then
  # --- Emit pain warning to stderr ---
  echo "[PAIN] Search repeat detected: '$TOOL_NAME' with query '$QUERY' appeared $COUNT times in last $MAX_HISTORY searches. Consider changing strategy or using skill-creator." >&2

  # --- Append to pain ledger ---
  # Initialize ledger if missing
  if [ ! -f "$LEDGER_FILE" ]; then
    echo "[]" > "$LEDGER_FILE"
  fi

  # Build new entry and append (pure bash, no jq)
  # Escape quotes in query for JSON safety
  SAFE_QUERY=$(echo "$QUERY" | sed 's/\\/\\\\/g; s/"/\\"/g')
  NEW_ENTRY="{\"category\":\"search_repeat\",\"query\":\"${SAFE_QUERY}\",\"tool\":\"${TOOL_NAME}\",\"count\":${COUNT},\"last_seen\":\"${TIMESTAMP}\"}"

  # Read existing ledger, strip trailing ], append new entry, close ]
  CONTENT=$(cat "$LEDGER_FILE")
  if [ "$CONTENT" = "[]" ]; then
    echo "[${NEW_ENTRY}]" > "$LEDGER_FILE"
  else
    # Remove trailing ] and whitespace, append comma + new entry + ]
    echo "$CONTENT" | sed '$ s/][[:space:]]*$//' > "${LEDGER_FILE}.tmp"
    echo ",${NEW_ENTRY}]" >> "${LEDGER_FILE}.tmp"
    mv "${LEDGER_FILE}.tmp" "$LEDGER_FILE"
  fi
fi

exit 0
