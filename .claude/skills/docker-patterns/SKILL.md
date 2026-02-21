---
name: docker-patterns
description: "Docker containerization and deployment patterns. Multi-stage Dockerfile optimization, docker-compose stack design, network isolation, volume strategies, container security hardening (non-root, capability drop, read-only fs), secret management, and deployment patterns (blue-green, canary, rolling). Use when containerizing applications, writing Dockerfiles, designing deployment pipelines, or hardening container security."
---

# Docker & Deployment — Expert Decision Reference

## Multi-Stage Dockerfile Template

```dockerfile
# Stage 1: Dependencies (cached layer)
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Stage 2: Build
FROM node:22-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build && npm prune --production

# Stage 3: Production (minimal surface)
FROM node:22-alpine AS production
WORKDIR /app
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001
USER appuser
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/package.json ./
ENV NODE_ENV=production
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "dist/server.js"]
```

## Security Hardening Checklist

```yaml
services:
  app:
    # 1. Non-root user (set in Dockerfile)
    # 2. Drop ALL capabilities, add back only what's needed
    cap_drop: [ALL]
    cap_add: [NET_BIND_SERVICE]   # only if port < 1024
    # 3. Prevent privilege escalation
    security_opt: [no-new-privileges:true]
    # 4. Read-only root filesystem
    read_only: true
    tmpfs: [/tmp, /app/.cache]
    # 5. Resource limits
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
```

## Network Isolation Pattern

```yaml
services:
  frontend:
    networks: [frontend-net]
  api:
    networks: [frontend-net, backend-net]
  db:
    networks: [backend-net]           # unreachable from frontend

networks:
  frontend-net:
  backend-net:
```

Port exposure: `127.0.0.1:5432:5432` (host-only) in dev. Omit `ports` entirely in production — services communicate over Docker network.

## Volume Strategy Decision Table

| Type | Use Case | Lifecycle |
|------|----------|-----------|
| Named volume | Database data, persistent state | Survives `down`, explicit `down -v` to destroy |
| Bind mount | Source code hot-reload (dev only) | Mirrors host filesystem |
| Anonymous volume | Protect container dirs from bind mount override | Recreated on `up` |
| tmpfs | Scratch/temp files in read-only containers | In-memory, gone on stop |

```yaml
volumes:
  - .:/app                        # bind mount: hot reload
  - /app/node_modules             # anonymous: protect from host
  - pgdata:/var/lib/postgresql/data  # named: persistent
```

## Secret Management

```yaml
# CORRECT: env_file (gitignored .env)
env_file: [.env]

# CORRECT: inherit from host
environment:
  - API_KEY                       # value from host env

# CORRECT: Docker secrets (Swarm/Compose v3.1+)
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## Deployment Strategy Decision Table

| Strategy | Downtime | Rollback Speed | Infra Cost | Use When |
|----------|----------|---------------|-----------|----------|
| Rolling | Zero | Slow (drain old) | 1x | Standard deploys, backward-compatible changes |
| Blue-Green | Zero | Instant (switch) | 2x during deploy | Critical services, zero-tolerance |
| Canary | Zero | Fast (reroute) | ~1.05x | High-traffic, risky changes, feature flags |

### Rolling
```
Instance 1: v1→v2 | Instance 2: v1 | Instance 3: v1
Instance 1: v2   | Instance 2: v1→v2 | Instance 3: v1
Instance 1: v2   | Instance 2: v2   | Instance 3: v1→v2
Requires: backward-compatible changes (two versions coexist)
```

### Blue-Green
```
Blue (v1) ← traffic | Green (v2) idle, verified
Blue (v1) idle      | Green (v2) ← traffic (atomic switch)
Rollback: switch back to Blue
```

### Canary
```
v1: 95% → 50% → 0% traffic
v2:  5% → 50% → 100% traffic
Requires: traffic splitting infra + metrics monitoring
```

## Compose Override Pattern

```bash
docker compose up                    # loads docker-compose.yml + .override.yml (dev)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d  # production
```

## Health Check Patterns

```typescript
// Liveness: is the process alive?
app.get("/health", (_, res) => res.status(200).json({ status: "ok" }));

// Readiness: can it serve traffic? (check dependencies)
app.get("/health/ready", async (_, res) => {
  const checks = { db: await checkDb(), redis: await checkRedis() };
  const ok = Object.values(checks).every(c => c.status === "ok");
  res.status(ok ? 200 : 503).json({ status: ok ? "ok" : "degraded", checks });
});
```

## .dockerignore (mandatory)

```
node_modules
.git
.env
.env.*
dist
coverage
*.log
.next
.cache
docker-compose*.yml
Dockerfile*
tests/
```

## NEVER

- NEVER use `:latest` tag — pin exact versions (`node:22.12-alpine3.20`)
- NEVER run containers as root — create non-root user in Dockerfile
- NEVER put secrets in Dockerfile (`ENV API_KEY=...`) or docker-compose.yml
- NEVER store data in containers without volumes — containers are ephemeral
- NEVER run multiple processes per container — one concern per container
- NEVER use `docker compose` in production without orchestration (use K8s/ECS/Swarm)
- NEVER skip HEALTHCHECK in production Dockerfiles
- NEVER copy entire repo in one COPY layer — copy dependency files first for layer caching
- NEVER install dev dependencies in production images
- NEVER expose database ports to 0.0.0.0 in production
