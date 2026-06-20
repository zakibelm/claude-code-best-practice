# Contributing to MOS Pipeline

## Pull Request Checklist

Before opening a PR, verify every item below:

### Environment variables
- [ ] Every new env var is documented in `.env.example` with an explanatory comment
- [ ] No real credentials appear anywhere in the diff (run `gitleaks detect` locally)

### n8n Workflows
- [ ] Every new or modified workflow has a corresponding contract in `docs/contracts/`
- [ ] The contract documents: trigger, inputs, outputs, error paths, Supabase RPCs called
- [ ] The workflow JSON has been exported from n8n and placed in `n8n/`

### Database Migrations
- [ ] Migration tested on a clean Supabase project (empty schema) before merging
- [ ] Migration is idempotent where possible (`CREATE ... IF NOT EXISTS`, `ON CONFLICT DO NOTHING`)
- [ ] Migration follows the naming convention: `NNN_description.sql`
- [ ] No hard-coded URLs, project IDs, or credentials in SQL files

### Security
- [ ] `gitleaks detect --source .` passes with zero findings
- [ ] No real infrastructure identifiers (hostnames, project IDs) in any documentation
- [ ] RLS is enabled on any new table that will be accessed by client-side code

### Tests
- [ ] `./scripts/smoke-test.sh` passes after applying the migration
- [ ] Manual E2E walkthrough completed against the plan in `docs/e2e-test-plan.md`

## Branch Naming

```
feat/short-description
fix/short-description
chore/short-description
docs/short-description
```

## Commit Style

Use conventional commits:
- `feat:` — new feature
- `fix:` — bug fix
- `docs:` — documentation only
- `chore:` — build, config, tooling
- `ci:` — CI pipeline changes

One commit per logical change. Do not bundle unrelated files.
