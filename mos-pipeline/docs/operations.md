# MOS v4.1-RC1 — Operations Runbook

## Pipeline Health in 30 Seconds

Run this query against your Supabase database:

```sql
SELECT
  statut,
  COUNT(*) AS count,
  MAX(updated_at) AS last_update
FROM video_production_notion
WHERE updated_at > NOW() - INTERVAL '24 hours'
GROUP BY statut
ORDER BY count DESC;
```

Red flags:
- More than 3 records in `dead_letter` → investigate immediately
- Records stuck in `image_generating` or `video_generating` for > 2h → check ComfyUI / fal.ai status
- No records updated in the last hour during business hours → check if n8n workflows are active

## Restarting a Dead-Letter Job

```sql
-- Find the stuck job
SELECT id, statut, updated_at, error_log
FROM video_production_notion
WHERE statut = 'dead_letter'
ORDER BY updated_at DESC;

-- Reset to retry (triggers the relevant n8n workflow on next sync)
UPDATE video_production_notion
SET statut = 'image_approved',  -- or the appropriate retry status
    error_log = NULL,
    retry_count = 0
WHERE id = 'YOUR_VIDEO_ID';
```

Then manually trigger the relevant n8n workflow or wait for the next Notion Sync cycle.

## Handling a Critical Alert

```sql
-- View unresolved critical alerts
SELECT id, client_id, alert_type, severity, message, created_at
FROM alert_queue
WHERE resolved_at IS NULL
  AND severity = 'critical'
ORDER BY created_at DESC;

-- Resolve after investigation
UPDATE alert_queue
SET resolved_at = NOW()
WHERE id = 'YOUR_ALERT_ID';
```

## n8n Workflow Frequencies

| Workflow | Trigger | Purpose |
|---|---|---|
| Notion Sync | Every 5 min | Detect new/updated video records |
| Fal Sweeper | Every 30 min | Recover missed fal.ai webhooks |
| Learning Loop | Daily at 02:00 | Ingest KPIs + update memory weights |

To verify a workflow is active: open n8n → Workflows → check the green/grey toggle.

## Cost Monitoring

```sql
-- Estimated costs by client (last 30 days)
SELECT
  c.name AS client,
  SUM(v.cost_total_cad) AS total_cad,
  COUNT(*) AS videos_produced
FROM video_production_notion v
JOIN clients c ON c.id = v.client_id
WHERE v.updated_at > NOW() - INTERVAL '30 days'
  AND v.statut = 'published'
GROUP BY c.name
ORDER BY total_cad DESC;
```

Cost breakdown per video: `cost_comfyui_cad + cost_fal_cad + cost_openrouter_cad = cost_total_cad` (computed column).
