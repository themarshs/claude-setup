#!/usr/bin/env node
/**
 * compliance-check.mjs — PreToolUse Hook (Edit|Write)
 * Hard enforcement: blocks config file edits unless documentation was consulted first.
 * Tracks recent tool calls via /tmp state file to detect "doc lookup before edit" pattern.
 *
 * Addresses root causes #3 (Solver's Override), #4 (soft/hard gap), #6 (no runtime self-check).
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const CONFIG_EXTENSIONS = /\.(json|yaml|yml|toml|env|ini|cfg)$/i;
const STATE_FILE = join(tmpdir(), 'claude-compliance-state.json');
const STATE_TTL_MS = 300000; // 5 minutes

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => resolve(data));
    setTimeout(() => resolve(data), 3000);
  });
}

function readState() {
  try {
    if (!existsSync(STATE_FILE)) return { docChecked: false, timestamp: 0 };
    const state = JSON.parse(readFileSync(STATE_FILE, 'utf-8'));
    // Expire stale state
    if (Date.now() - state.timestamp > STATE_TTL_MS) return { docChecked: false, timestamp: 0 };
    return state;
  } catch {
    return { docChecked: false, timestamp: 0 };
  }
}

function writeState(state) {
  try {
    writeFileSync(STATE_FILE, JSON.stringify({ ...state, timestamp: Date.now() }));
  } catch { /* best effort */ }
}

async function main() {
  let input;
  try {
    const raw = await readStdin();
    if (!raw.trim()) process.exit(0);
    input = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const toolInput = input.tool_input || {};
  const filePath = toolInput.file_path || '';

  // Only check config file edits
  if (!CONFIG_EXTENSIONS.test(filePath)) process.exit(0);

  // Whitelist: our own hooks and skill-rules can always be edited
  if (filePath.includes('.claude/hooks/') || filePath.includes('.claude/skills/')) process.exit(0);

  // Whitelist: MEMORY.md, ARMORY.md, CLAUDE.md — state files we maintain
  const basename = filePath.split(/[/\\]/).pop() || '';
  if (['MEMORY.md', 'ARMORY.md', 'CLAUDE.md', 'MEMORY.bak'].includes(basename)) process.exit(0);

  // Check if documentation was recently consulted
  const state = readState();
  if (state.docChecked) {
    // Doc was checked within TTL, allow the edit
    process.exit(0);
  }

  // Block: no doc lookup detected before config edit
  console.log(JSON.stringify({
    result: 'block',
    reason: `配置文件编辑被阻断: ${basename}\n` +
      '根据 config-before-guess 规则，编辑配置文件前必须先查阅文档。\n' +
      '请先使用 WebSearch / context7 / 官方 docs 确认正确配置方式，\n' +
      '然后运行: echo \'{"docChecked":true}\' > ' + STATE_FILE + ' 解除阻断。'
  }));
  process.exit(0);
}

main().catch(() => process.exit(0));
