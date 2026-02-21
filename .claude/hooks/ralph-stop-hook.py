#!/usr/bin/env python3
"""ralph-stop-hook.py — Self-loop Stop Hook for unattended iteration.

Reads .claude/ralph-loop.local.md state file. If active:
  1. Check max_iterations safety valve
  2. Check completion_promise in last assistant message
  3. If neither triggered → block stop, re-inject prompt, increment iteration
"""
import sys, json, re, os


def main():
    state_file = sys.argv[1] if len(sys.argv) > 1 else None
    if not state_file or not os.path.exists(state_file):
        return  # No state file = allow stop

    # Read hook input from stdin
    try:
        hook_input = json.load(sys.stdin)
    except Exception:
        hook_input = {}

    # Read state file
    try:
        with open(state_file, "r", encoding="utf-8") as f:
            content = f.read()
    except Exception:
        return

    # Parse YAML frontmatter between --- markers
    fm_match = re.search(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
    if not fm_match:
        return  # Invalid state file

    fm = fm_match.group(1)
    body = content[fm_match.end():]

    # Simple YAML value extractor (key: value, one per line)
    def yv(key, default=None):
        m = re.search(rf"^{key}:\s*(.+)$", fm, re.MULTILINE)
        if m:
            val = m.group(1).strip()
            if len(val) >= 2 and (
                (val[0] == '"' and val[-1] == '"')
                or (val[0] == "'" and val[-1] == "'")
            ):
                val = val[1:-1]
            return val
        return default

    active = yv("active", "false")
    if active.lower() != "true":
        return

    iteration = int(yv("iteration", "1"))
    max_iter = int(yv("max_iterations", "0"))
    promise = yv("completion_promise", "")

    # Safety valve: max iterations reached → delete state, allow stop
    if max_iter > 0 and iteration >= max_iter:
        os.remove(state_file)
        return

    # Check completion promise in last assistant message
    if promise:
        tp = hook_input.get("transcript_path", "")
        if tp and os.path.exists(tp):
            try:
                with open(tp, "r", encoding="utf-8") as tf:
                    lines = tf.readlines()
                for line in reversed(lines):
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        msg = json.loads(line)
                        if msg.get("role") == "assistant":
                            parts = msg.get("message", {}).get("content", [])
                            text = " ".join(
                                p.get("text", "")
                                if isinstance(p, dict)
                                else str(p)
                                for p in parts
                            )
                            pm = re.search(
                                r"<promise>(.*?)</promise>", text, re.DOTALL
                            )
                            if pm and pm.group(1).strip() == promise:
                                os.remove(state_file)
                                return  # Promise fulfilled, allow stop
                            break  # Only check last assistant message
                    except (json.JSONDecodeError, KeyError):
                        continue
            except Exception:
                pass

    # --- Not done yet: block stop, re-inject prompt ---

    # Increment iteration in state file
    new_content = re.sub(
        r"^iteration:\s*\d+",
        f"iteration: {iteration + 1}",
        content,
        flags=re.MULTILINE,
    )
    try:
        with open(state_file, "w", encoding="utf-8") as f:
            f.write(new_content)
    except Exception:
        pass

    # Output block JSON to stdout
    prompt = body.strip()
    cap = str(max_iter) if max_iter > 0 else "unlimited"
    result = {
        "decision": "block",
        "reason": prompt,
        "systemMessage": (
            f"[Ralph Loop] iteration {iteration + 1}/{cap}"
            + (f" | Output <promise>{promise}</promise> when done" if promise else "")
        ),
    }
    print(json.dumps(result))


if __name__ == "__main__":
    main()
