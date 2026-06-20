# MOS v4.1-RC1 — End-to-End Test Plan

## Preconditions

- All 7 migrations (000–006) applied and smoke test passing
- All 9 n8n workflows imported and **active**
- ComfyUI instance running with `sdxl_base_1.0.safetensors` loaded
- All env vars set (see `.env.example`)
- `mos-images` Supabase Storage bucket created and public

## Test Data

Create the following records in your Notion database before starting:

| Field | Value |
|---|---|
| Client | Test Client |
| Titre | Test MOS Pipeline |
| Plateforme | `instagram_reels` |
| Langue | `fr-CA` |
| Statut | `À scripter` |

Also create a `clients` record in Supabase with `name = 'Test Client'`.

## Expected Flow

### Step 1 — Notion Sync picks up the record
- **Trigger**: Notion Sync workflow fires (every 5 min)
- **Expected**: Record upserted into `video_production_notion` with `statut = 'a_scripter'`

**SQL validation**:
```sql
SELECT id, statut, notion_page_id
FROM video_production_notion
WHERE titre = 'Test MOS Pipeline';
-- Expected: 1 row, statut = 'a_scripter'
```

---

### Step 2 — Script Agent generates the video script
- **Trigger**: Notion Sync detects `statut = 'a_scripter'` and calls Script Agent
- **Expected**: `prompt_fal`, `prompt_comfyui`, `negative_prompt` fields populated; `statut = 'script_approved'`

**SQL validation**:
```sql
SELECT statut, prompt_fal, prompt_comfyui
FROM video_production_notion
WHERE titre = 'Test MOS Pipeline';
-- Expected: statut = 'script_approved', prompts non-null
```

---

### Step 3 — ComfyUI generates the reference image
- **Trigger**: Notion Sync detects `script_approved`, calls ComfyUI Submit
- **Expected**: Image generated, uploaded to Supabase Storage, `reference_image_url` populated; `statut = 'image_approved'`

**SQL validation**:
```sql
SELECT statut, reference_image_url, comfyui_status
FROM video_production_notion v
JOIN image_generation_queue q ON q.video_id = v.id
WHERE v.titre = 'Test MOS Pipeline';
-- Expected: comfyui_status = 'completed', reference_image_url non-null
```

---

### Step 4 — fal.ai generates the video
- **Trigger**: Notion Sync detects `image_approved`, calls Fal Submit
- **Expected**: fal.ai job queued; `fal_status = 'processing'`

**SQL validation**:
```sql
SELECT fal_status, fal_request_id
FROM fal_video_queue
WHERE video_id = (
  SELECT id FROM video_production_notion WHERE titre = 'Test MOS Pipeline'
);
-- Expected: fal_status = 'processing', fal_request_id non-null
```

---

### Step 5 — Fal Webhook / Sweeper completes the job
- **Trigger**: fal.ai webhook OR Sweeper (within 30 min)
- **Expected**: `fal_status = 'completed'`, `video_url` populated; `statut = 'video_generee'`

**SQL validation**:
```sql
SELECT fal_status, video_url
FROM fal_video_queue
WHERE video_id = (
  SELECT id FROM video_production_notion WHERE titre = 'Test MOS Pipeline'
);
-- Expected: fal_status = 'completed', video_url starts with https://
```

---

### Step 6 — Blotato schedules the publication
- **Trigger**: Notion Sync detects `video_generee`, calls Blotato Publish
- **Expected**: Post scheduled in Blotato; `statut = 'scheduled'`; `blotato_publication_log` has an entry

**SQL validation**:
```sql
SELECT action, platform, scheduled_at
FROM blotato_publication_log
WHERE video_id = (
  SELECT id FROM video_production_notion WHERE titre = 'Test MOS Pipeline'
);
-- Expected: action = 'scheduled', scheduled_at in the future
```

---

### Step 7 — KPI Ingest and Learning Loop
- **Trigger**: Learning Loop workflow (daily or manual trigger)
- **Expected**: `video_kpi_log` populated; `video_memory_notion` updated for client

**SQL validation**:
```sql
SELECT * FROM learning_loop_candidates
WHERE client_id = (SELECT id FROM clients WHERE name = 'Test Client');
-- Expected: 1+ rows with engagement metrics
```

## Pass Criteria

All 7 steps complete without errors and all SQL validations return expected results.  
Total time budget: < 45 minutes from Step 1 to Step 6 (video generation is the bottleneck).
