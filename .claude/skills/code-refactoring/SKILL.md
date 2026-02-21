---
name: code-refactoring
description: "Systematic code refactoring and tech debt management. Dead code detection (knip/depcheck), risk-graded removal (SAFE/CAREFUL/RISKY), duplication elimination, dependency cleanup, tech debt ROI quantification, and debt budget strategy. Use when cleaning up codebases, removing dead code, managing tech debt, or planning refactoring sprints."
---

# Code Refactoring & Tech Debt Management

## Detection Toolchain

| Tool | Detects | Command |
|------|---------|---------|
| **knip** | Unused files, exports, dependencies, types | `npx knip` |
| **depcheck** | Unused npm dependencies | `npx depcheck` |
| **ts-prune** | Unused TypeScript exports | `npx ts-prune` |
| **eslint** | Unused disable-directives, variables | `npx eslint . --report-unused-disable-directives` |

Run all detection tools in parallel. Cross-reference results -- an item flagged by 2+ tools is high-confidence dead code.

## Three-Level Risk Classification

### SAFE -- Remove immediately
- Unused npm dependencies (flagged by both knip + depcheck)
- Unused internal exports with zero grep hits
- Commented-out code blocks older than 90 days
- Test files for deleted features
- Unused TypeScript types/interfaces

### CAREFUL -- Verify before removal
- Exports potentially used via dynamic imports (`import()`, `require()` with variables)
- Code referenced only in configuration files (webpack, jest config)
- Utilities used in scripts not covered by static analysis
- Items with recent git activity (< 30 days)

**Verification:** grep for string patterns, check dynamic import paths, review git log for context.

### RISKY -- Requires sign-off
- Public API exports (consumed by external packages)
- Shared utilities across module boundaries
- Code with no tests but serving production traffic
- Items where removal changes bundle structure

**Verification:** grep all consumers, check package.json exports field, verify no external dependents.

## Refactoring Workflow

```
1. Run detection tools (parallel)
2. Classify results: SAFE / CAREFUL / RISKY
3. Remove SAFE items first, one category at a time:
   a. Unused npm dependencies
   b. Unused internal exports
   c. Unused files
   d. Duplicate code
4. Run tests after each batch
5. Commit after each batch (atomic commits)
6. Proceed to CAREFUL items with verification
7. RISKY items require explicit user approval
8. Update DELETION_LOG after each session
```

## ROI Calculation

```
ROI = (Monthly Hours Saved x Hourly Rate x 12) / (Effort Hours x Hourly Rate)

Example:
  Debt Item: Duplicate validation logic in 5 files
  Fix Effort: 8 hours
  Monthly Savings: 20 hours (bug fixes touch 5 places instead of 1)
  Annual Savings: 240 hours
  ROI: 240 / 8 = 30x return
```

**Prioritize by ROI:** Quick wins (high value, low effort) first. Track each item:

| Priority | Effort | Savings/mo | ROI | Timeline |
|----------|--------|-----------|-----|----------|
| P0 Quick Win | < 8h | > 15h | > 20x | This sprint |
| P1 Medium | 8-40h | > 10h | > 3x | This month |
| P2 Long-term | 40-200h | > 20h | > 2x | This quarter |
| P3 Strategic | > 200h | Architectural | Measured quarterly | Next quarter |

## Debt Budget

```yaml
debt_budget:
  allowed_monthly_increase: "2%"      # New debt tolerated per month
  mandatory_quarterly_reduction: "5%"  # Must reduce debt by 5% each quarter
  sprint_allocation: "20%"             # Reserve 20% sprint capacity for debt
  tracking:
    complexity: "knip / eslint"
    dependencies: "depcheck / npm audit"
    coverage: "jest --coverage"
  gates:
    pre_commit:
      - max_complexity: 10
      - max_duplication: "5%"
      - min_coverage_new_code: "80%"
    ci_pipeline:
      - no_high_vulnerabilities: true
      - no_new_architecture_violations: true
```

## DELETION_LOG Template

Maintain at `docs/DELETION_LOG.md`:

```markdown
# Code Deletion Log

## [YYYY-MM-DD] Refactor Session: [Focus Area]

### Unused Dependencies Removed
| Package | Version | Reason | Size Impact |
|---------|---------|--------|-------------|
| lodash | ^4.17.21 | Zero imports in codebase | -72 KB |

### Unused Files Deleted
| File | Replaced By | Reason |
|------|------------|--------|
| src/old-component.tsx | src/new-component.tsx | Feature rewrite |

### Duplicate Code Consolidated
| Sources | Target | Lines Saved |
|---------|--------|-------------|
| Button1.tsx + Button2.tsx | Button.tsx (variant prop) | 120 |

### Unused Exports Removed
| File | Exports | Verification |
|------|---------|-------------|
| src/utils/helpers.ts | foo(), bar() | grep: 0 refs |

### Impact Summary
- Files deleted: N
- Dependencies removed: N
- Lines removed: N
- Bundle size reduction: ~N KB
- Tests passing: YES/NO
```

## Duplicate Consolidation Process

```
1. Identify duplicates (knip, manual grep for similar patterns)
2. Choose the best implementation:
   - Most feature-complete
   - Best tested
   - Most recently maintained
3. Create unified version with variant/config support
4. Update all import paths
5. Delete duplicates
6. Verify tests pass
7. Log in DELETION_LOG
```

## Error Recovery

```
If removal breaks something:
1. git revert HEAD (immediate rollback)
2. npm install && npm run build && npm test
3. Investigate: dynamic import? Detection tool blind spot?
4. Add to "DO NOT REMOVE" list with reason
5. Update detection methodology to prevent recurrence
```

## NEVER

- NEVER remove code without running detection tools first
- NEVER remove RISKY items without explicit user approval
- NEVER skip tests between removal batches
- NEVER remove code you don't understand -- investigate first
- NEVER refactor during active feature development on same files
- NEVER remove right before production deployment
- NEVER do large batch removals -- one category at a time
- NEVER forget to update DELETION_LOG after each session
- NEVER trust a single detection tool -- cross-reference with grep
- NEVER remove public API exports without checking external consumers
