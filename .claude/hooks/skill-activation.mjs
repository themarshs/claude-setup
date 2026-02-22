#!/usr/bin/env node
/**
 * skill-activation.mjs — UserPromptSubmit Hook
 * Matches user prompt against skill-rules.json, outputs Skill activation suggestions.
 * Adapted from parcadei/Continuous-Claude-v3 (TS→single-file Node.js, zero deps).
 * Improvements: excludeKeywords negative signals, no jq/Python dependency.
 */

import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => resolve(data));
    // Safety: force resolve after 3s to prevent Windows stdin hang
    setTimeout(() => resolve(data), 3000);
  });
}

function matchRule(prompt, triggers) {
  if (!triggers) return { matched: false };

  // Check excludeKeywords first (negative signals)
  const excludes = triggers.excludeKeywords || [];
  for (const ex of excludes) {
    if (prompt.includes(ex.toLowerCase())) return { matched: false };
  }

  // Keyword substring match
  const keywords = triggers.keywords || [];
  for (const kw of keywords) {
    if (prompt.includes(kw.toLowerCase())) {
      return { matched: true, type: 'keyword', term: kw };
    }
  }

  // Intent pattern regex match
  const patterns = triggers.intentPatterns || [];
  for (const pat of patterns) {
    try {
      if (new RegExp(pat, 'i').test(prompt)) {
        return { matched: true, type: 'intent', term: pat };
      }
    } catch { /* ignore bad regex */ }
  }

  return { matched: false };
}

const PRI_ORDER = { critical: 0, high: 1, medium: 2, low: 3 };

async function main() {
  let input;
  try {
    const raw = await readStdin();
    if (!raw.trim()) process.exit(0);
    input = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const prompt = (input.prompt || '').toLowerCase();
  if (!prompt) process.exit(0);

  // Load rules
  const rulesPath = join(__dirname, '..', 'skills', 'skill-rules.json');
  if (!existsSync(rulesPath)) process.exit(0);

  let rules;
  try {
    rules = JSON.parse(readFileSync(rulesPath, 'utf-8'));
  } catch {
    process.exit(0);
  }

  // Ambiguous term check (from CC-v3 skill-validation-prompt)
  const ambiguous = rules.ambiguousTerms || {};

  const matches = [];

  // Match skills
  for (const [name, config] of Object.entries(rules.skills || {})) {
    const result = matchRule(prompt, config.promptTriggers);
    if (!result.matched) continue;

    // Ambiguous keyword? Check for technical co-occurrence
    if (result.type === 'keyword' && ambiguous[result.term]) {
      const indicators = ambiguous[result.term];
      const hasContext = indicators.some(ind => prompt.includes(ind.toLowerCase()));
      if (!hasContext) continue; // Skip: ambiguous without technical context
    }

    matches.push({
      name,
      priority: config.priority || 'low',
      enforcement: config.enforcement || 'suggest',
      description: config.description || '',
      isAgent: false,
    });
  }

  // Match agents
  for (const [name, config] of Object.entries(rules.agents || {})) {
    const result = matchRule(prompt, config.promptTriggers);
    if (!result.matched) continue;
    matches.push({
      name,
      priority: config.priority || 'low',
      enforcement: config.enforcement || 'suggest',
      description: config.description || '',
      isAgent: true,
    });
  }

  if (matches.length === 0) process.exit(0);

  // Sort by priority
  matches.sort((a, b) => (PRI_ORDER[a.priority] ?? 3) - (PRI_ORDER[b.priority] ?? 3));

  // Check for blocking enforcement
  const blocking = matches.filter(m => m.enforcement === 'block');
  if (blocking.length > 0) {
    const names = blocking.map(m => m.name).join(', ');
    console.log(JSON.stringify({
      result: 'block',
      reason: `BLOCKING: Invoke Skill tool for: ${names} before ANY response.`,
    }));
    process.exit(0);
  }

  // Format suggestions
  const lines = ['━━━ SKILL ACTIVATION ━━━'];

  const critical = matches.filter(m => m.priority === 'critical');
  if (critical.length) {
    lines.push('CRITICAL:');
    critical.forEach(m => lines.push(`  -> ${m.name}: ${m.description}`));
  }

  const high = matches.filter(m => m.priority === 'high');
  if (high.length) {
    lines.push('RECOMMENDED:');
    high.forEach(m => lines.push(`  -> ${m.name}: ${m.description}`));
  }

  const rest = matches.filter(m => m.priority === 'medium' || m.priority === 'low');
  if (rest.length) {
    lines.push('SUGGESTED:');
    rest.forEach(m => lines.push(`  -> ${m.name}${m.isAgent ? ' [Agent]' : ''}: ${m.description}`));
  }

  lines.push('ACTION: Use Skill tool to invoke matched skills BEFORE responding.');
  lines.push('━━━━━━━━━━━━━━━━━━━━━━━━');

  console.log(lines.join('\n'));
  process.exit(0);
}

main().catch(() => process.exit(0));
