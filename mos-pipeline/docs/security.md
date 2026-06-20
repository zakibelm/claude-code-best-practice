# MOS v4.1-RC1 — Security Guidelines

## Secrets Management

**Never commit `.env`.**  
Use `.env.example` as the template. All real credentials live only in `.env` (git-ignored) or your deployment platform's secret manager.

**Service role key is server-side only.**  
`SUPABASE_SERVICE_KEY` bypasses RLS. It must only be used in n8n (server-side). Never embed it in client-side code, browser extensions, or public repositories.

**Anon key is for RLS-protected read-only access.**  
`SUPABASE_ANON_KEY` is safe to expose to clients, but only after RLS is enabled on all tables.

## Internal Webhook Security

All internal webhooks between n8n workflows must include the `X-MOS-Secret` header set to `MOS_WEBHOOK_SECRET`.  
Generate a strong secret: `openssl rand -hex 32`

Verify this header at the receiving workflow before processing the payload.

## Key Rotation Policy

- Rotate all API keys after any staging or production environment change
- Rotate immediately if a key is suspected to be compromised
- Store rotation history in your team's password manager, not in this repo

## Row Level Security (RLS)

Enable RLS on all Supabase tables before going to production.  
The migrations intentionally leave RLS disabled to simplify development — you must enable it before exposing the anon key.

```sql
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_production_notion ENABLE ROW LEVEL SECURITY;
-- Repeat for all tables
```

## Public Documentation

Do not include real infrastructure identifiers (hostnames, project IDs, IP addresses) in any documentation, comments, or commit messages.  
Use placeholders like `YOUR_PROJECT_ID` and `YOUR_HOST`.

## Secret Scanning

Run `gitleaks detect --source .` locally before every push.  
The CI pipeline (`validate.yml`) also runs gitleaks on every push and pull request — any finding blocks the merge.
