---
name: api-design
description: "REST API design standards and best practices. URL naming (plural nouns, kebab-case), HTTP method semantics, status code reference, response envelope format, pagination strategy (cursor vs offset decision), rate limiting tiers, versioning, and API design checklist. Use when designing new APIs, reviewing API contracts, or building backend endpoints."
---

# API Design — Expert Decision Reference

## URL Design Decision Table

| Scenario | Pattern | Example |
|----------|---------|---------|
| Standard CRUD | `/{plural-noun}` | `/api/v1/users` |
| Relationship | `/{parent}/:id/{child}` | `/api/v1/users/:id/orders` |
| Non-CRUD action | `POST /{resource}/:id/{verb}` | `POST /api/v1/orders/:id/cancel` |
| Auth flows | `POST /auth/{action}` | `POST /api/v1/auth/refresh` |
| Multi-word resource | kebab-case | `/api/v1/team-members` |
| Filtering | query params | `/api/v1/orders?status=active` |
| Sparse fields | `fields=` param | `/api/v1/users?fields=id,name,email` |

## HTTP Method Semantics

| Method | Idempotent | Safe | Body in Response | Success Code |
|--------|-----------|------|-----------------|-------------|
| GET | Yes | Yes | Yes | 200 |
| POST | No | No | Yes | 201 + Location header |
| PUT | Yes | No | Optional | 200 or 204 |
| PATCH | No* | No | Yes | 200 |
| DELETE | Yes | No | No | 204 |

## Status Code Quick Reference

```
SUCCESS
200 OK                GET/PUT/PATCH with body
201 Created           POST (must include Location header)
204 No Content        DELETE, PUT without body

CLIENT ERROR
400 Bad Request       Malformed JSON, missing required field
401 Unauthorized      No/invalid auth token
403 Forbidden         Authenticated but no permission
404 Not Found         Resource does not exist
409 Conflict          Duplicate key, state machine violation
422 Unprocessable     Valid JSON but semantically wrong data
429 Too Many Requests Rate limit hit (must include Retry-After)

SERVER ERROR
500 Internal          Unexpected failure (NEVER expose internals)
502 Bad Gateway       Upstream dependency failed
503 Unavailable       Overload (must include Retry-After)
```

## Response Envelope

```jsonc
// Single resource
{ "data": { "id": "abc-123", "email": "a@b.com", "created_at": "2025-01-15T10:30:00Z" } }

// Collection with pagination
{ "data": [...], "meta": { "total": 142, "page": 1, "per_page": 20 }, "links": { "self": "...", "next": "...", "last": "..." } }

// Error (field-level details mandatory for validation errors)
{ "error": { "code": "validation_error", "message": "...", "details": [{ "field": "email", "message": "...", "code": "invalid_format" }] } }
```

## Pagination Decision Tree

```
Dataset size?
├── <10K rows OR admin dashboard → Offset (page + per_page)
│   SQL: LIMIT 20 OFFSET 40
│   Pros: jump-to-page, simple
│   Cons: perf degrades at deep offsets, drift on concurrent writes
│
├── >10K rows OR infinite scroll OR feed → Cursor (opaque token)
│   SQL: WHERE id > :cursor LIMIT 21  (fetch N+1 to detect has_next)
│   Pros: O(1) at any depth, stable under writes
│   Cons: no jump-to-page
│
└── Public API → Cursor default, offset optional
```

## Rate Limiting Tiers

| Tier | Limit | Window | Scope |
|------|-------|--------|-------|
| Anonymous | 30/min | Per IP | Public read endpoints |
| Authenticated | 100/min | Per user | Standard access |
| Premium | 1000/min | Per API key | Paid plans |
| Internal | 10000/min | Per service | Service-to-service |

Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` (unix epoch).
On 429: must return `Retry-After` header.

## Versioning Strategy

```
1. Start at /api/v1/ — don't version until you must
2. Max 2 active versions (current + previous)
3. Non-breaking (no new version): add fields, add optional params, add endpoints
4. Breaking (new version): remove/rename fields, change types, change auth
5. Deprecation: 6-month notice → Sunset header → 410 Gone after sunset
```

## Filtering & Sorting Conventions

```
Equality:     ?status=active&customer_id=abc-123
Comparison:   ?price[gte]=10&price[lte]=100
Multi-value:  ?category=electronics,clothing
Sort:         ?sort=-created_at,price    (prefix - = DESC)
Search:       ?q=wireless+headphones
```

## Pre-Ship Checklist

- [ ] URLs: plural nouns, kebab-case, no verbs in path
- [ ] Correct HTTP method + status codes (not 200-for-everything)
- [ ] Input validated at boundary (Zod/Pydantic/schema)
- [ ] Error responses have `code` + `message` + `details`
- [ ] List endpoints paginated (cursor or offset)
- [ ] Auth required (or explicitly public)
- [ ] Authorization checked (ownership + role)
- [ ] Rate limiting configured per tier
- [ ] Response leaks no internals (no stack traces, SQL, paths)
- [ ] Naming consistent across all endpoints (pick camelCase or snake_case, not both)
- [ ] OpenAPI spec updated

## NEVER

- NEVER return 200 for errors — use semantic HTTP status codes
- NEVER put verbs in URL paths (`/getUsers`, `/createOrder`)
- NEVER use singular nouns (`/user` instead of `/users`)
- NEVER use snake_case in URLs (use kebab-case: `/team-members`)
- NEVER expose stack traces, SQL errors, or file paths in error responses
- NEVER skip the Location header on 201 Created
- NEVER use OFFSET pagination for public APIs with large datasets
- NEVER maintain >2 active API versions simultaneously
- NEVER make breaking changes without a version bump
- NEVER omit Retry-After on 429 or 503 responses
