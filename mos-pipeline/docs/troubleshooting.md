# MOS v4.1-RC1 — Troubleshooting

## Top 10 Errors

### 1. Migration fails on `CREATE TYPE video_pipeline_status`

**Symptom**: `ERROR: type "video_pipeline_status" already exists`  
**Cause**: Partial previous migration run.  
**Fix**:
```sql
DROP TYPE IF EXISTS video_pipeline_status CASCADE;
```
Then re-run the migration. Use `--single-transaction` so partial runs roll back automatically.

---

### 2. Webhook not received by n8n

**Symptom**: fal.ai job completes but video_url never appears in Supabase.  
**Cause**: n8n webhook URL not reachable from the internet, or workflow is inactive.  
**Fix**:
- Confirm `PUBLIC_WEBHOOK_BASE_URL` is a public URL (not localhost)
- Check the Fal Webhook workflow is **active** in n8n (green toggle)
- The Fal Sweeper runs every 30 min as a safety net — wait for it or trigger manually

---

### 3. ComfyUI timeout

**Symptom**: `comfyui_status = 'failed'`, error log mentions timeout.  
**Cause**: ComfyUI instance is overloaded or unreachable.  
**Fix**:
- Check `COMFYUI_BASE_URL` is correct and reachable from n8n
- Verify ComfyUI is running: `curl $COMFYUI_BASE_URL/system_stats`
- The job will auto-retry with exponential backoff (5 min → 15 min → 45 min)

---

### 4. fal.ai returns FAILED without an error message

**Symptom**: `fal_status = 'FAILED'`, `error_log` is empty.  
**Cause**: fal.ai job failed before generating an error message (e.g., invalid image URL).  
**Fix**:
- Check `reference_image_url` is publicly accessible
- Try submitting the same payload manually via `curl` to `queue.fal.run/{model}`
- Review the fal.ai dashboard for the `request_id`

---

### 5. Blotato auth error

**Symptom**: Blotato workflow fails with 401 or 403.  
**Cause**: `BLOTATO_API_KEY` is invalid or expired.  
**Fix**: Regenerate the API key in the Blotato dashboard and update `.env` and n8n credentials.

---

### 6. OpenRouter rate limit

**Symptom**: Script generation fails with HTTP 429.  
**Cause**: Too many concurrent script generation requests.  
**Fix**:
- Add a delay between batches in the Notion Sync workflow
- Switch to a model with higher rate limits in `OPENROUTER_MODEL`
- Check your OpenRouter plan limits

---

### 7. Processing lock not released

**Symptom**: New jobs for a client are blocked indefinitely.  
**Cause**: A previous job crashed before calling `release_processing_lock`.  
**Fix**: Locks auto-expire based on `p_ttl_minutes` (default 30 min). To force-release:
```sql
DELETE FROM processing_locks
WHERE client_id = 'YOUR_CLIENT_ID'
  AND lock_type = 'fal_video';
```

---

### 8. Fal Sweeper workflow doesn't start

**Symptom**: Sweeper cron hasn't fired in over an hour.  
**Cause**: Workflow is inactive in n8n.  
**Fix**: Open n8n → MOS-v4.1-Fal-Sweeper → toggle to **active**.  
Note: n8n cron triggers only fire when the workflow is active.

---

### 9. Learning Loop runs but no data is written

**Symptom**: `upsert_video_memory` is called but `video_memory_notion` stays empty.  
**Cause**: No published videos with KPI data yet, or `video_kpi_log` is empty.  
**Fix**:
```sql
-- Check if KPI data exists
SELECT COUNT(*) FROM video_kpi_log;
-- Check learning_loop_candidates
SELECT * FROM learning_loop_candidates LIMIT 10;
```
If both are empty, KPI ingest hasn't run yet. Trigger the Learning Loop workflow manually after publishing at least one video.

---

### 10. n8n workflow shows as inactive after import

**Symptom**: Imported workflow has a grey toggle (inactive).  
**Cause**: Imported workflows default to inactive in n8n for safety.  
**Fix**: Open each imported workflow → click the toggle → confirm activation.  
All 9 MOS workflows must be activated after import.
