# 命名规范

## General Principles

- Names describe **what**, not how. `usersByRole` not `filteredArray`.
- Avoid abbreviations unless universal: `id`, `url`, `db`, `config` OK. `usr`, `mgr`, `proc` not OK.
- Be consistent: if codebase uses `remove`, do not introduce `delete` for the same concept.
- Scope proportional length: larger scope = longer name. Single letters only for loop counters and lambdas.

## JavaScript / TypeScript

- Variables & functions: `camelCase` (`getUserById`, `orderCount`).
- Classes & types: `PascalCase` (`UserService`, `ApiResponse`).
- Constants: `UPPER_SNAKE_CASE` (`MAX_RETRIES`, `DEFAULT_TIMEOUT`).
- Booleans: prefix `is` / `has` / `can` / `should` (`isEnabled`, `hasAccess`).
- Event handlers: `on` / `handle` prefix (`onClick`, `handleSubmit`).
- Enums: `PascalCase` name and members (`enum OrderStatus { Pending, Shipped }`).

## Python

- Variables & functions: `snake_case` (`get_user_by_id`, `is_active`).
- Classes: `PascalCase` (`UserService`, `OrderRepository`).
- Constants: `UPPER_SNAKE_CASE`. Private: `_underscore_prefix`.

## Database

- Tables: `snake_case`, **plural** (`users`, `order_items`).
- Columns: `snake_case`, **singular** (`user_id`, `created_at`, `is_active`).
- Primary keys: `id`. Foreign keys: `<singular_table>_id` (`user_id`, `order_id`).
- Indexes: `idx_<table>_<columns>` (`idx_orders_user_id`).
- Migrations: `<timestamp>_<description>` (`20260115_add_orders_status_column`).

## File Naming

- TypeScript modules: `kebab-case.ts` (`user-service.ts`, `api-client.ts`).
- React components: `PascalCase.tsx` (`UserProfile.tsx`, `OrderList.tsx`).
- Python modules: `snake_case.py` (`user_service.py`).
