---
name: distillery-search
description: BM25 full-text search over 2,130+ community Claude Code assets (skills, rules, agents, CLAUDE.md, hooks). Use when looking for community patterns, best practices, or existing solutions before building from scratch.
---

# Distillery Search

Search 2,130+ community assets extracted from 26 high-star Claude Code repositories.

## When to Use

- Before creating a new Skill/Rule/Agent — check if the community already has one
- During the "发散" (divergence) phase of the spiral SOP
- When looking for best practices on a specific topic (security, testing, Docker, etc.)
- When the user asks "is there a community skill for X?"

## MCP Usage (Preferred)

Use the distillery MCP Server tools directly — no Bash needed:

```
# Search (hybrid BM25 + vector by default)
mcp__distillery__search  query="security review"  type="skill"  top=5

# Get full asset content
mcp__distillery__get_asset  type="skill"  name="security-review"

# Find similar assets (semantic vector search)
mcp__distillery__similar  type="skill"  name="security-review"  top=5

# List all types and counts
mcp__distillery__list_types
```

### MCP Tool Reference

| Tool | Parameters | Returns |
|------|-----------|---------|
| `search` | `query`, `type?`, `top?`, `mode?`, `tag?`, `minStars?` | Ranked results with name, type, score, source, description, bodyPreview |
| `get_asset` | `type`, `name` | Full asset body + all metadata |
| `similar` | `type`, `name`, `top?` | Semantically similar assets via vector search |
| `list_types` | (none) | Asset counts by type |

### Search Modes

| Mode | Method | Best For |
|------|--------|----------|
| `hybrid` (default) | BM25 + vector cosine | Best overall quality |
| `fulltext` | BM25 only | Fast keyword matching |
| `vector` | Embedding cosine only | Semantic / concept search |

## CLI Fallback

If MCP is unavailable, use the CLI:

```bash
# Basic search
node D:/ai/distillery/search.mjs "query"

# Filter by type: skill, rule, agent, claude-md, hook
node D:/ai/distillery/search.mjs "testing" --type skill --top 5

# Filter by minimum stars
node D:/ai/distillery/search.mjs "docker" --min-stars 1000

# Filter by source repository
node D:/ai/distillery/search.mjs "security" --source "affaan-m/everything-claude-code"

# JSON output for programmatic use
node D:/ai/distillery/search.mjs "error handling" --json --top 10

# Combine filters
node D:/ai/distillery/search.mjs "api" --type skill --min-stars 500 --top 5
```

## Available Types

| Type | Count | Description |
|------|-------|-------------|
| skill | 1,350 | SKILL.md workflow definitions |
| rule | 294 | .claude/rules/*.md behavioral rules |
| agent | 435 | Agent definitions (.claude/agents/) |
| claude-md | 51 | CLAUDE.md project instructions |
| hook | 7 | Event hooks (settings.json) |

## Ranking

Results are ranked by: `finalScore = searchScore * 0.85 + log10(stars) * 0.15`

- Search relevance is dominant (85%)
- GitHub stars provide quality tiebreaker (15%, log-scaled)
- Field boosts: name (3x) > description (2x) > headings (1.5x) > tags (1.5x) > body (1x)

## Rebuild Index

After running `node D:/ai/distillery/distill.mjs`, rebuild the search index:

```bash
node D:/ai/distillery/build-index.mjs
```
