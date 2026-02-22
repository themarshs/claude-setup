#!/usr/bin/env node
/**
 * search-router.mjs — PreToolUse Hook (Grep)
 * Classifies Grep queries into structural/literal/semantic,
 * injects routing suggestions but ALLOWS execution (suggest mode, not deny).
 * Adapted from parcadei/Continuous-Claude-v3 smart-search-router.ts.
 * Zero external dependencies.
 */

import { readFileSync } from 'fs';

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => resolve(data));
    setTimeout(() => resolve(data), 3000);
  });
}

function classifyQuery(pattern) {
  // STRUCTURAL: code definitions, imports, function calls, decorators
  const structuralPatterns = [
    /^(class|function|def|async def|const|let|var|interface|type|export)\s+\w+/,
    /^(import|from|require)\s/,
    /^\w+\s*\([^)]*\)/,
    /^async\s+(function|def)/,
    /\$\w+/,
    /^@\w+/,
  ];
  if (structuralPatterns.some(p => p.test(pattern))) return 'structural';

  // LITERAL: identifiers, regex patterns, file paths, short queries
  if (pattern.includes('\\') || pattern.includes('[') || /\([^)]*\|/.test(pattern)) return 'literal';
  if (/^[A-Z][a-zA-Z0-9]*$/.test(pattern)) return 'literal'; // CamelCase
  if (/^[a-z_][a-z0-9_]*$/.test(pattern)) return 'literal';  // snake_case
  if (/^[A-Z_][A-Z0-9_]*$/.test(pattern)) return 'literal';  // SCREAMING_CASE
  if (pattern.includes('/') || /\.(ts|py|js|go|rs|md)/.test(pattern)) return 'literal';
  const words = pattern.split(/\s+/).filter(w => w.length > 0);
  if (words.length <= 2 && !/^(how|what|where|why|when|find|show|list)/i.test(pattern)) return 'literal';

  // SEMANTIC: natural language questions, multi-word queries
  const semanticPatterns = [
    /^(how|what|where|why|when|which)\s/i,
    /\?$/,
    /^(find|show|list|get|explain)\s+(all|the|every|any)/i,
    /works?$/i,
    /^.*\s+(implementation|architecture|flow|pattern|logic|system)$/i,
  ];
  if (semanticPatterns.some(p => p.test(pattern))) return 'semantic';
  if (words.length >= 3) return 'semantic';

  return 'literal';
}

const SUGGESTIONS = {
  structural: 'Structural query detected. Consider using Glob to find definitions, or Task(Explore) for codebase navigation.',
  semantic: 'Semantic/conceptual query detected. Consider using Task(Explore) for deeper analysis, or WebSearch for external knowledge.',
  literal: null, // No suggestion needed for literal patterns — Grep is the right tool
};

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
  const pattern = toolInput.pattern || '';
  if (!pattern) process.exit(0);

  const queryType = classifyQuery(pattern);
  const suggestion = SUGGESTIONS[queryType];

  // Suggest mode: output advice but don't block
  if (suggestion) {
    console.log(suggestion);
  }

  // Always allow — we suggest, not deny
  process.exit(0);
}

main().catch(() => process.exit(0));
