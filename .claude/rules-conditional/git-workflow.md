# Git Workflow Discipline

## Conventional Commits

Format: `<type>(<scope>): <description>`

Types: `feat` | `fix` | `refactor` | `docs` | `test` | `chore` | `perf` | `ci`

- Subject: imperative mood, lowercase, no period, max 72 chars
- Body: wrap at 80 chars, explain *why* not *what*
- Scope: optional, indicates module/area affected

## Atomic Commit Splitting

| Changed files | Min commits | Split strategy |
|---------------|-------------|-------------------------------|
| 1-2           | 1           | Single commit OK              |
| 3-4           | 2+          | Split by concern              |
| 5-9           | 3+          | Config / logic / tests separate |
| 10+           | 5+          | One commit per logical unit   |

Split criteria:
- Different directories/modules = SPLIT
- Different concerns (config vs logic vs tests vs docs) = SPLIT
- Each commit must be independently revertable without breaking build
- Commit in dependency order: deps first, then code, then tests

## Style Detection (before committing)

Detect project convention from `git log -20 --pretty=format:"%s"`:
- Match language (English/Chinese), format (semantic `feat:` / plain / short)
- Match casing and punctuation pattern

## PR Workflow

1. Analyze FULL commit history: `git diff <base>...HEAD`
2. Title under 72 chars, describes the change
3. Body: summary bullets + test plan
4. Push with `-u` if new branch
5. Request review after CI passes

## Branch Protection

- NEVER push directly to `main` or `master`
- NEVER use `--force` — only `--force-with-lease`
- NEVER rebase `main`/`master`
- Stash dirty files before rebase
- Create feature branch from up-to-date base

## NEVER List

- `git push --force` (use `--force-with-lease`)
- `git reset --hard` on shared branches
- `git checkout .` without stashing first
- Monolithic commits (10+ files, "update various files")
- Commit messages mismatching project convention
- Committing secrets, `.env`, credentials, large binaries
- Skipping hooks with `--no-verify`
- Amending commits already pushed to remote
