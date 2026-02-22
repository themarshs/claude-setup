#!/bin/bash
# skill-activation.sh — UserPromptSubmit Hook
# Matches user prompt against skill-rules.json, outputs Skill activation suggestions.
# Adapted from parcadei/Continuous-Claude-v3 skill-activation-prompt (TS → Bash+jq).
# Improvements over CC-v3: excludeKeywords (negative signals), pure Bash (no Python hang on Windows).

set -e

# Fail open if jq not available
command -v jq >/dev/null 2>&1 || exit 0

# Read stdin (Claude Code sends JSON: {"prompt":"...", "session_id":"..."})
INPUT=$(cat)

# Locate rules file relative to this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES="$SCRIPT_DIR/../skills/skill-rules.json"
[ -f "$RULES" ] || exit 0

# Phase 1: Match skills and agents against prompt (single jq invocation)
MATCHES=$(echo "$INPUT" | jq --slurpfile rules "$RULES" '
  (.prompt // "" | ascii_downcase) as $p |
  if ($p | length) == 0 then [] else

  def check(entries; is_agent):
    [entries | to_entries[] |
     select(.value.promptTriggers != null) |
     .key as $n | .value as $c | .value.promptTriggers as $t |
     (($t.keywords // []) | any(ascii_downcase as $k | $p | contains($k))) as $kw |
     (($t.intentPatterns // []) | any(. as $pat | try ($p | test($pat; "i")) catch false)) as $it |
     (($t.excludeKeywords // []) | any(ascii_downcase as $e | $p | contains($e))) as $ex |
     select(($kw or $it) and ($ex | not)) |
     {name: $n, pri: $c.priority, enf: ($c.enforcement // "suggest"), desc: $c.description, agent: is_agent}];

  check($rules[0].skills // {}; false) + check($rules[0].agents // {}; true) |
  sort_by(if .pri == "critical" then 0 elif .pri == "high" then 1 elif .pri == "medium" then 2 else 3 end)

  end
' 2>/dev/null)

# Exit if no matches or jq failed
[ -z "$MATCHES" ] && exit 0
COUNT=$(echo "$MATCHES" | jq 'length' 2>/dev/null)
[ "$COUNT" = "0" ] || [ -z "$COUNT" ] && exit 0

# Phase 2: Check for blocking enforcement
BLOCK=$(echo "$MATCHES" | jq -r '[.[] | select(.enf == "block")] | map(.name) | join(", ")' 2>/dev/null)
if [ -n "$BLOCK" ]; then
  printf '{"result":"block","reason":"BLOCKING: Invoke Skill tool for: %s before ANY response."}\n' "$BLOCK"
  exit 0
fi

# Phase 3: Format suggestions by priority
printf '━━━ SKILL ACTIVATION ━━━\n'

CRIT=$(echo "$MATCHES" | jq -r '[.[] | select(.pri == "critical")] | .[] | "  -> \(.name): \(.desc)"' 2>/dev/null)
[ -n "$CRIT" ] && printf 'CRITICAL:\n%s\n' "$CRIT"

HIGH=$(echo "$MATCHES" | jq -r '[.[] | select(.pri == "high")] | .[] | "  -> \(.name): \(.desc)"' 2>/dev/null)
[ -n "$HIGH" ] && printf 'RECOMMENDED:\n%s\n' "$HIGH"

OTHER=$(echo "$MATCHES" | jq -r '[.[] | select(.pri == "medium" or .pri == "low")] | .[] | "  -> \(.name)\(if .agent then " [Agent]" else "" end): \(.desc)"' 2>/dev/null)
[ -n "$OTHER" ] && printf 'SUGGESTED:\n%s\n' "$OTHER"

printf 'ACTION: Use Skill tool to invoke matched skills BEFORE responding.\n'
printf '━━━━━━━━━━━━━━━━━━━━━━━━\n'
exit 0
