# MOS v4.1-RC1 — Setup Guide

## Prerequisites

- **PostgreSQL client** (`psql`) installed locally — for running migrations
- **n8n** instance (self-hosted or cloud) — v1.x or later
- **ComfyUI** instance with SDXL base checkpoint
- **Supabase** project (free tier works for development)
- **fal.ai** account with API key
- **Blotato** account with API key
- **Notion** workspace with integration token
- **OpenRouter** account with API key

---

## 1. Clone the Repository

```bash
git clone https://github.com/zakibelm/mos-pipeline.git
cd mos-pipeline
cp .env.example .env
# Edit .env with your values
```

---

## 2. Supabase Setup

1. Create a new Supabase project
2. Copy the **Project URL** and **Service Role key** into `.env`
3. In the Supabase dashboard, go to **Storage** → create a new bucket named `mos-images` → set it to **Public**

---

## 3. Apply Migrations

```bash
# Set your database URL
export DATABASE_URL="postgresql://postgres:YOUR_PASSWORD@db.YOUR_PROJECT_ID.supabase.co:5432/postgres"

# Apply all migrations in order
./scripts/migrate.sh

# Verify everything was created correctly
./scripts/smoke-test.sh
```

Expected output from smoke test: `Smoke test passed: 8/8 tables found.`

On Windows, use PowerShell:
```powershell
$env:DATABASE_URL = "postgresql://..."
.\scripts\migrate.ps1
```

---

## 4. Configure n8n

1. Open your n8n instance
2. Go to **Workflows** → **Import from file**
3. Import each file from the `n8n/` directory (9 workflows total):
   - `MOS-v4.1-Notion-Sync.json`
   - `MOS-v4.1-Script-Agent.json`
   - `MOS-v4.1-ComfyUI-Submit.json`
   - `MOS-v4.1-ComfyUI-Callback.json`
   - `MOS-v4.1-Fal-Submit.json`
   - `MOS-v4.1-Fal-Webhook.json`
   - `MOS-v4.1-Fal-Sweeper.json`
   - `MOS-v4.1-Blotato-Publish.json`
   - `MOS-v4.1-Learning-Loop.json`
4. In n8n **Settings** → **Environment Variables**, add all variables from `.env`

---

## 5. Configure ComfyUI

1. Download `sdxl_base_1.0.safetensors` and place it in `ComfyUI/models/checkpoints/`
2. Verify ComfyUI is accessible at the URL set in `COMFYUI_BASE_URL`
3. Test: `curl $COMFYUI_BASE_URL/system_stats` should return JSON

The ComfyUI workflow JSON is in `comfyui/reference-image-workflow.json`. It is submitted programmatically by n8n — no manual import needed.

---

## 6. Activate Webhooks

Each n8n workflow must be **toggled to active** after import:

1. Open each workflow in n8n
2. Click the toggle in the top-right corner
3. Confirm activation

Webhook-based workflows will display their public URL once activated. Copy the fal.ai callback URL and confirm it matches `PUBLIC_WEBHOOK_BASE_URL/webhook/mos-fal-callback`.

---

## 7. Smoke Test

Follow the test scenario in [`docs/e2e-test-plan.md`](e2e-test-plan.md):

1. Create a test video record in Notion
2. Wait for Notion Sync to pick it up (or trigger manually)
3. Verify each step progresses through the pipeline
4. Confirm video is scheduled in Blotato

If any step fails, consult [`docs/troubleshooting.md`](troubleshooting.md).
