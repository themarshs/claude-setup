---
name: mcp-development
description: |
  WHAT: MCP Server development guide based on @modelcontextprotocol/sdk (TypeScript, stdio mode)
  WHEN: Building new MCP Servers, adding tools/resources/prompts, debugging MCP connectivity, registering servers in Claude Code
  KEYWORDS: mcp, server, tool, resource, prompt, stdio, sdk, zod, json-rpc
---

# MCP Server Development

## Transport Decision Matrix

| Factor | stdio | Streamable HTTP | SSE |
|--------|-------|-----------------|-----|
| Deployment | Local process | Cloud/multi-tenant | Legacy remote |
| Auth | Env vars | OAuth/tokens | OAuth/tokens |
| Concurrency | Single client | Multi-client | Multi-client |
| Complexity | Minimal | Medium | Medium |
| Our standard | YES | No | No |

Decision: Use **stdio** unless the server must serve multiple clients simultaneously over network.

## 4 Primitives — When to Use Which

| Primitive | Purpose | Example |
|-----------|---------|---------|
| **Tool** | Execute actions, return results | `search`, `create_issue`, `run_query` |
| **Resource** | Expose read-only data via URI | `db://schema`, `config://app` |
| **Prompt** | Reusable prompt templates with args | `review-code`, `summarize-pr` |
| **Sampling** | Server requests LLM completion | Agentic loops inside server (rare) |

Rule: 90% of MCP servers only need Tools. Add Resources for static/semi-static data. Prompts for workflow templates. Sampling almost never.

## Server Skeleton (stdio + @modelcontextprotocol/sdk)

```javascript
#!/usr/bin/env node
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';

// 1. Heavy init BEFORE server.connect (load models, indexes, configs)
async function init() {
  // Load resources once — subsequent tool calls are fast
  console.error('[my-server] Initialized');  // stderr only!
}

// 2. Create server
const server = new McpServer({
  name: 'my-server',
  version: '1.0.0',
  capabilities: { tools: {} },
});

// 3. Register tools with Zod schemas
server.tool(
  'tool_name',
  'Clear description: WHAT it does + WHEN to use it',
  {
    param: z.string().describe('What this param controls'),
    limit: z.number().optional().default(10).describe('Max results'),
  },
  async ({ param, limit }) => {
    // Validate, execute, return
    return {
      content: [{ type: 'text', text: JSON.stringify(result, null, 2) }],
    };
  },
);

// 4. Start
await init();
const transport = new StdioServerTransport();
await server.connect(transport);
```

## package.json Template

```json
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "type": "module",
  "main": "index.mjs",
  "scripts": { "start": "node index.mjs" },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.12.0",
    "zod": "^3.24.0"
  }
}
```

## Tool Design Principles

- **Naming**: `snake_case`, action-oriented (`search_files` not `fileSearcher`)
- **Description**: Must answer "what does it do" AND "when should I use it" in one sentence
- **Parameters**: Every param needs `.describe()` — the LLM reads these to decide values
- **Defaults**: Use `.optional().default(x)` for sensible defaults, reduce required params
- **Errors**: Return `{ content: [...], isError: true }` — never throw unstructured exceptions
- **Granularity**: One tool = one logical operation. Compose in the client, not the server
- **Annotations**: Set `readOnlyHint`, `destructiveHint`, `idempotentHint` when supported

## Registration Configuration

### .mcp.json (project root — OUR STANDARD)

```json
{
  "mcpServers": {
    "my-server": {
      "type": "stdio",
      "command": "node",
      "args": ["D:/ai/mcp-servers/my-server/index.mjs"],
      "env": {
        "NODE_PATH": "D:/ai/my-server/node_modules",
        "API_KEY": "from-env-not-hardcoded"
      }
    }
  }
}
```

### Decision: Where to Register

| Location | Scope | Use When |
|----------|-------|----------|
| `.mcp.json` (project root) | Per-project | Standard for all our servers |
| `claude mcp add` | User-global | Shared across all projects |
| `settings.local.json` | IDE-specific | Avoid — harder to track |

## Debugging

### stdio Logging Trap

stdio transport uses stdin/stdout for JSON-RPC. Any `console.log()` corrupts the protocol channel.

```javascript
// WRONG — breaks JSON-RPC
console.log('debug info');

// CORRECT — stderr is safe
console.error('[my-server] debug info');
```

### MCP Inspector

```bash
npx @modelcontextprotocol/inspector node index.mjs
# Opens browser UI to test tools interactively
```

### Claude Code Debug

```bash
claude --debug  # Shows MCP connection logs
# In session: /mcp to list connected servers and tools
```

### Common Failures

| Symptom | Cause | Fix |
|---------|-------|-----|
| Server not connecting | console.log in code | Replace with console.error |
| Tools not appearing | Missing capabilities declaration | Add `capabilities: { tools: {} }` |
| Timeout on start | Slow init after connect | Move heavy init BEFORE `server.connect()` |
| Env vars missing | Not passed in .mcp.json | Add to `"env"` block in config |
| Module not found | Dependencies not resolved | Set `NODE_PATH` in env or install locally |

## Performance Pattern: Front-Load Init

```javascript
// CORRECT: Load heavy resources ONCE at startup
let db, model;
async function init() {
  db = await loadDatabase();        // One-time cost
  model = await loadEmbeddings();   // One-time cost
  console.error('[server] Ready');
}
await init();                        // Before server.connect()
await server.connect(transport);     // Tools now respond instantly

// WRONG: Load inside each tool handler
server.tool('search', '...', {}, async () => {
  const db = await loadDatabase();  // 2s per call!
});
```

## Error Response Pattern

```javascript
// Structured error — LLM can understand and retry
if (!isValid(input)) {
  return {
    content: [{ type: 'text', text: JSON.stringify({
      error: 'Invalid input',
      details: 'Parameter "query" must be non-empty string',
      suggestion: 'Provide a search query with at least 2 characters',
    }) }],
    isError: true,
  };
}
```

## Resource Pattern (read-only data)

```javascript
server.resource(
  'schema',                           // name
  'db://schema',                      // URI
  'Database schema with all tables',  // description
  async () => ({
    contents: [{
      uri: 'db://schema',
      mimeType: 'application/json',
      text: JSON.stringify(schemaData, null, 2),
    }],
  }),
);
```

## NEVER List

1. NEVER use `console.log()` in stdio servers — it corrupts the JSON-RPC channel
2. NEVER put heavy initialization inside tool handlers — front-load in `init()` before `server.connect()`
3. NEVER hardcode API keys/tokens in server code or `.mcp.json` — use env vars
4. NEVER skip `.describe()` on Zod params — the LLM relies on these to understand parameters
5. NEVER return raw stack traces — return structured `{ error, details, suggestion }` with `isError: true`
6. NEVER register in `settings.local.json` — use `.mcp.json` at project root
7. NEVER use `mcp-use` or other wrapper frameworks — use `@modelcontextprotocol/sdk` directly
8. NEVER create tools with vague descriptions like "do stuff" — describe WHAT + WHEN
9. NEVER forget `"type": "module"` in package.json when using ESM imports
10. NEVER mix sync blocking code with async transport — all tool handlers must be async
