# 依赖管理纪律

## Pre-Add Checklist

- Check before adding: last publish date, open issues count, maintenance status, transitive dependency count.
- Prefer packages with zero or few transitive deps. Avoid duplicating stdlib or existing project functionality.
- Prefer well-known packages: `zod` > `yup`, `date-fns` > `moment`, `got` > `request`.
- Document the reason for each new dependency in the commit message.

## Version Pinning

- **Applications**: pin exact versions (`"lodash": "4.17.21"` not `"^4.17.21"`).
- **Libraries**: use ranges to avoid peer dep conflicts (`"react": "^18.0.0"`).
- Always commit lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `Pipfile.lock`, `Cargo.lock`).

## Auditing

- Run `npm audit` / `pip audit` / `cargo audit` on every CI build.
- **Critical/High severity**: block merge. No exceptions.
- Review Dependabot/Renovate PRs weekly. Do not let them accumulate.

## License Compliance

- Approved: MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC.
- **GPL, AGPL, SSPL**: flag for legal review before use. Never silently add.
- Run `license-checker` or `pip-licenses` in CI.

## Update Cadence

| Severity | Deadline |
|----------|----------|
| Critical security patch | 24 hours |
| High security patch | 7 days |
| Minor/patch updates | Monthly batch, full test suite |
| Major version upgrades | Quarterly, dedicated branch + migration guide review |
