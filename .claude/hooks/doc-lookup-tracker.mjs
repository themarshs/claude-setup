#!/usr/bin/env node
/**
 * doc-lookup-tracker.mjs — PostToolUse Hook (WebSearch|WebFetch|mcp__context7__*)
 * Records that documentation was consulted, unlocking config file edits
 * for the next 5 minutes (pairs with compliance-check.mjs).
 */

import { writeFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const STATE_FILE = join(tmpdir(), 'claude-compliance-state.json');

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => resolve(data));
    setTimeout(() => resolve(data), 3000);
  });
}

async function main() {
  try {
    await readStdin(); // consume stdin
    writeFileSync(STATE_FILE, JSON.stringify({ docChecked: true, timestamp: Date.now() }));
  } catch { /* best effort */ }
  process.exit(0);
}

main().catch(() => process.exit(0));
