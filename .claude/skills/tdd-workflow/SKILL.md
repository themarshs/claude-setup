---
name: tdd-workflow
description: "Expert TDD/E2E/EDD workflow: red-green-refactor decision trees, Playwright flaky isolation, eval-driven development with pass@k metrics. Activate when writing tests, debugging flaky E2E, or setting up eval harnesses for AI-assisted development."
---

# TDD + E2E + EDD Expert Workflow

## TDD Decision Tree (not the textbook version)

### When to RED-GREEN-REFACTOR vs When NOT To

```
New feature?
  -> Write User Journey FIRST ("As a [role], I want [action], so that [benefit]")
  -> Derive test cases from journey, NOT from implementation plan
  -> One behavior per test, NOT one function per test

Bug fix?
  -> Write FAILING test that reproduces the bug BEFORE touching code
  -> The test IS the bug report; if you can't write the test, you don't understand the bug

Refactor?
  -> Run existing tests GREEN first
  -> Refactor with tests watching (--watch)
  -> If no tests exist: write characterization tests BEFORE refactoring
  -> NEVER refactor and change behavior in the same commit

Prototype/spike?
  -> Skip TDD. Spike is throwaway. Write tests when promoting to real code.
```

### The Minimal Green Trap

Write JUST ENOUGH code to pass. But "just enough" does NOT mean:
- Hardcoding return values to match assertions (that's cheating, not TDD)
- Skipping error paths because no test demands them yet (add error test cases)
- Writing a 200-line function because "it all passes" (refactor phase exists for a reason)

## NEVER List (Anti-patterns)

1. NEVER test implementation details (internal state, private methods, call counts on internals)
   - Test BEHAVIOR: what the user/caller sees
2. NEVER use brittle selectors (`.css-class-xyz`, `div > span:nth-child(3)`)
   - Use `[data-testid="..."]`, `role`, or semantic text selectors
3. NEVER let tests depend on execution order
   - Each test sets up its own data, tears down after
4. NEVER use `waitForTimeout(N)` in E2E tests
   - Use `waitForResponse()`, `waitForSelector()`, `waitForLoadState()`
5. NEVER mock what you don't own (third-party internals change without notice)
   - Wrap third-party in your own adapter, mock the adapter
6. NEVER skip the REFACTOR phase
   - Green is not done. Green + refactored + still green = done.
7. NEVER commit skipped/disabled tests without a tracking issue number
   - `test.fixme(true, 'Flaky - Issue #123')` -- the issue number is mandatory

## Playwright E2E: Expert Patterns

### Flaky Test Triage Protocol

```
Test fails intermittently?
  1. QUARANTINE immediately: test.fixme(true, 'Flaky - Issue #NNN')
  2. REPRODUCE: npx playwright test path/to/test.spec.ts --repeat-each=10
  3. CLASSIFY root cause:
     - Race condition -> Replace page.click() with page.locator().click() (auto-wait)
     - Network timing -> waitForResponse(resp => resp.url().includes('/api/...'))
     - Animation -> waitFor({state:'visible'}) + waitForLoadState('networkidle') THEN click
     - Data dependency -> Isolate test data per test, use fixtures
  4. FIX the classified cause, run --repeat-each=10 again to confirm
  5. UNQUARANTINE only after 10/10 passes
```

### POM Navigation Guard

Every Page Object `goto()` must end with a load gate:
```typescript
async goto() {
  await this.page.goto('/path')
  await this.page.waitForLoadState('networkidle')  // mandatory
}
```
Without `networkidle`, subsequent locator actions race against pending fetches.

### Response-Gated Actions

Any action that triggers an API call must wait for the response before asserting:
```typescript
async search(query: string) {
  await this.searchInput.fill(query)
  await this.page.waitForResponse(r => r.url().includes('/api/search'))
  // NOW safe to assert on results
}
```

### CI Stability Config (non-obvious settings)

- `retries: process.env.CI ? 2 : 0` -- retries mask flakiness locally, only use in CI
- `workers: process.env.CI ? 1 : undefined` -- parallel workers cause port/DB conflicts in CI
- `trace: 'on-first-retry'` -- traces are huge; only capture when investigating failures
- `video: 'retain-on-failure'` -- same principle; don't record successful runs

## Eval-Driven Development (EDD)

EDD extends TDD to AI-assisted workflows where outputs are non-deterministic.

### When to Use EDD vs TDD

```
Deterministic output (pure functions, CRUD, algorithms)?
  -> Standard TDD. Evals are overkill.

Non-deterministic output (LLM calls, search relevance, recommendations)?
  -> EDD. Tests can't assert exact output; evals measure quality.

Agentic workflows (multi-step, tool-using)?
  -> EDD with pass@k. Single-run assertions are meaningless.
```

### Eval Type Decision Tree

```
"Can Claude do X now that it couldn't before?"
  -> Capability Eval (measures new abilities)

"Did my change break existing behavior?"
  -> Regression Eval (pass^k = ALL k trials must succeed)
```

### Grader Selection

```
Output is objectively verifiable (file exists, test passes, build succeeds)?
  -> Code-Based Grader (deterministic, preferred)

Output is subjective quality (code style, explanation clarity)?
  -> Model-Based Grader (score 1-5 with mandatory reasoning)

Output involves security, money, or PII?
  -> Human Grader (NEVER fully automate these)
```

### Metrics That Matter

| Metric | Formula | Use Case | Target |
|--------|---------|----------|--------|
| pass@1 | Success on first attempt | Developer experience | >80% |
| pass@3 | At least 1 success in 3 attempts | Reliability floor | >90% |
| pass^3 | ALL 3 consecutive attempts succeed | Critical paths | 100% |

- Track pass@k over time per feature. Declining trend = regression signal.
- pass@1 dropping but pass@3 stable = flakiness problem, not capability problem.

### EDD Workflow (4 phases, strict order)

```
1. DEFINE: Write eval spec BEFORE any code
   - List capability evals (new things)
   - List regression evals (things that must not break)
   - Set pass@k thresholds

2. IMPLEMENT: Write code to pass the evals

3. EVALUATE: Run all evals, record pass/fail per attempt
   - Code graders first (fast, deterministic)
   - Model graders second (slower, probabilistic)
   - Human review last (only for flagged items)

4. REPORT: Structured output with metrics
   - Feature name, capability pass rate, regression pass rate
   - pass@1 and pass@3 numbers
   - SHIP IT / NEEDS WORK / BLOCKED verdict
```

## Cross-Cutting Rules

- Test files live next to source: `Button.tsx` + `Button.test.tsx` in same dir
- E2E tests in dedicated `e2e/` or `tests/e2e/` directory, organized by feature
- Eval definitions in `.claude/evals/feature-name.md`, versioned with code
- Coverage threshold: 80% lines/branches/functions as gate, not goal
  - 80% that tests behavior > 100% that tests implementation
