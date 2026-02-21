---
name: database-expertise
description: "PostgreSQL expertise: index selection matrix (B-tree/GIN/BRIN/Hash), query optimization, schema design anti-patterns, RLS security, connection pooling, concurrency patterns (SKIP LOCKED, deadlock prevention), and migration best practices. Use when designing database schemas, optimizing queries, reviewing database code, or setting up RLS policies."
---

# PostgreSQL — Expert Decision Reference

## Index Selection Matrix

| Index Type | Operators | Use Case | Size |
|-----------|-----------|----------|------|
| B-tree (default) | `=` `<` `>` `BETWEEN` `IN` `IS NULL` | Equality + range on scalar columns | Baseline |
| GIN | `@>` `?` `?&` `?|` `@@` | JSONB containment, arrays, full-text search | 2-3x B-tree |
| GIN (jsonb_path_ops) | `@>` only | JSONB containment (subset of GIN, 2-3x smaller) | ~1x B-tree |
| BRIN | Range on physically sorted data | Time-series tables >100M rows, append-only | ~0.01x B-tree |
| Hash | `=` only | Pure equality lookups (marginally faster than B-tree) | ~0.8x B-tree |

### Composite Index Rules

```sql
-- Column order: equality columns FIRST, then range columns
CREATE INDEX idx ON orders (status, created_at);
-- Works for: WHERE status = 'pending'
-- Works for: WHERE status = 'pending' AND created_at > '2024-01-01'
-- DOES NOT work for: WHERE created_at > '2024-01-01' alone (leftmost prefix rule)
```

### Covering Index (index-only scans, 2-5x speedup)

```sql
CREATE INDEX idx ON users (email) INCLUDE (name, created_at);
-- All columns served from index, no table heap lookup
```

### Partial Index (5-20x smaller, faster writes)

```sql
CREATE INDEX idx ON users (email) WHERE deleted_at IS NULL;
-- Common filters: soft deletes, status = 'pending', non-null SKU
```

## Schema Anti-Patterns → Fixes

| Anti-Pattern | Fix | Why |
|-------------|-----|-----|
| `int` for IDs | `bigint GENERATED ALWAYS AS IDENTITY` | int overflows at 2.1B |
| `varchar(255)` | `text` | Artificial limit, no perf difference in PG |
| `timestamp` | `timestamptz` | Without timezone = silent data corruption |
| `float` for money | `numeric(10,2)` | float has precision loss |
| `varchar` for booleans | `boolean` | Type safety + storage |
| Random UUID PK | UUIDv7 or IDENTITY | Random UUID fragments B-tree inserts |
| Mixed-case identifiers | `lowercase_snake_case` | Quoted identifiers are contagious |

## RLS Patterns

```sql
-- 1. Enable + Force (force applies to table owner too)
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders FORCE ROW LEVEL SECURITY;

-- 2. Policy with cached function call (100x faster than per-row call)
CREATE POLICY orders_policy ON orders
  FOR ALL
  USING ((SELECT auth.uid()) = user_id);    -- SELECT wrapper = called once, not per-row

-- 3. Supabase pattern
CREATE POLICY orders_policy ON orders
  FOR ALL TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- 4. ALWAYS index the RLS column
CREATE INDEX orders_user_id_idx ON orders (user_id);
```

## Concurrency Patterns

### SKIP LOCKED (job queues, 10x throughput)

```sql
UPDATE jobs
SET status = 'processing', worker_id = $1, started_at = now()
WHERE id = (
  SELECT id FROM jobs
  WHERE status = 'pending'
  ORDER BY created_at
  LIMIT 1
  FOR UPDATE SKIP LOCKED
) RETURNING *;
```

### Deadlock Prevention

```sql
-- Lock rows in consistent order (sort by PK)
SELECT * FROM accounts WHERE id IN (1, 2) ORDER BY id FOR UPDATE;
-- Then mutate in any order
```

### Short Transactions

```sql
-- Do external calls OUTSIDE the transaction
-- Lock held only for the UPDATE, not the API call
BEGIN;
UPDATE orders SET status = 'paid', payment_id = $1
WHERE id = $2 AND status = 'pending'
RETURNING *;
COMMIT;
```

## Connection Pooling

| Mode | Returns Conn | Supports | Use When |
|------|-------------|----------|----------|
| Transaction | After each txn | Most apps | Default choice |
| Session | On disconnect | Prepared statements, temp tables, LISTEN/NOTIFY | Stateful sessions |

Pool size formula: `(CPU_cores * 2) + spindle_count`
Max connections formula: `(RAM_MB / 5) - reserved`

```sql
-- Mandatory idle timeouts
ALTER SYSTEM SET idle_in_transaction_session_timeout = '30s';
ALTER SYSTEM SET idle_session_timeout = '10min';
```

## Query Optimization Patterns

### N+1 Elimination

```sql
-- WRONG: 100 separate queries
SELECT * FROM orders WHERE user_id = 1;  -- repeated N times

-- RIGHT: single query
SELECT * FROM orders WHERE user_id = ANY(ARRAY[1, 2, 3, ...]);
-- Or JOIN
SELECT u.id, o.* FROM users u LEFT JOIN orders o ON o.user_id = u.id WHERE u.active;
```

### Cursor Pagination (O(1) at any depth)

```sql
-- WRONG: OFFSET degrades linearly
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 199980;  -- scans 200K rows

-- RIGHT: cursor-based
SELECT * FROM products WHERE id > :last_seen_id ORDER BY id LIMIT 20;
```

### Batch Insert (10-50x faster)

```sql
-- WRONG: N round trips
INSERT INTO events (user_id, action) VALUES (1, 'click');

-- RIGHT: single statement
INSERT INTO events (user_id, action) VALUES (1,'click'),(2,'view'),(3,'click');

-- BEST: COPY for bulk
COPY events (user_id, action) FROM '/path/data.csv' WITH (FORMAT csv);
```

### UPSERT (atomic, race-condition-free)

```sql
INSERT INTO settings (user_id, key, value)
VALUES (123, 'theme', 'dark')
ON CONFLICT (user_id, key)
DO UPDATE SET value = EXCLUDED.value, updated_at = now()
RETURNING *;
```

## Partitioning Decision

Use when: tables >100M rows, time-series, need to DROP old data instantly.

```sql
CREATE TABLE events (...) PARTITION BY RANGE (created_at);
CREATE TABLE events_2024_01 PARTITION OF events
  FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
-- DROP TABLE events_2023_01;  -- instant vs DELETE taking hours
```

## EXPLAIN ANALYZE Diagnosis

| Indicator | Problem | Fix |
|-----------|---------|-----|
| `Seq Scan` on large table | Missing index | Add index on filter/join columns |
| `Rows Removed by Filter` high | Poor selectivity | Rethink WHERE clause or add partial index |
| `Buffers: read >> hit` | Cold cache | Increase `shared_buffers` |
| `Sort Method: external merge` | `work_mem` too low | Increase `work_mem` |
| Estimated rows far from actual | Stale statistics | Run `ANALYZE tablename` |

## Migration Best Practices

- Add columns as `NULL` first, backfill, then add `NOT NULL` constraint
- Create indexes `CONCURRENTLY` to avoid table locks
- Test migrations against production-sized data before deploying
- Keep migrations backward-compatible (old code must still work)
- One migration per logical change, never batch unrelated changes

## NEVER

- NEVER use `SELECT *` in production code — list explicit columns
- NEVER use `int` for primary keys — use `bigint`
- NEVER use `timestamp` without timezone — use `timestamptz`
- NEVER use `float` for money — use `numeric`
- NEVER use OFFSET pagination on tables >10K rows
- NEVER use `GRANT ALL` for application roles — least privilege only
- NEVER call functions per-row in RLS policies without `(SELECT ...)` wrapper
- NEVER leave foreign key columns unindexed
- NEVER hold locks during external API calls or long computations
- NEVER use random UUIDs as primary keys — use UUIDv7 or IDENTITY
- NEVER create indexes without `CONCURRENTLY` on production tables
- NEVER skip `ANALYZE` after bulk data changes
