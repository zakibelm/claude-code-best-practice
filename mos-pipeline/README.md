# MOS v4.1-RC1 — Pipeline Vidéo IA

[![Validate JSON](https://github.com/zakibelm/mos-pipeline/actions/workflows/validate.yml/badge.svg)](https://github.com/zakibelm/mos-pipeline/actions/workflows/validate.yml)
[![Secret Scan](https://github.com/zakibelm/mos-pipeline/actions/workflows/validate.yml/badge.svg?event=push&label=secrets)](https://github.com/zakibelm/mos-pipeline/actions/workflows/validate.yml)

Automated video production pipeline: Notion brief → AI script → reference image → AI video → social scheduling.

---

## Quick Start (7 steps)

**Step 1** — Clone and configure
```bash
git clone https://github.com/zakibelm/mos-pipeline.git
cd mos-pipeline
cp .env.example .env
# Fill in your values in .env
```

**Step 2** — Apply database migrations
```bash
export DATABASE_URL="postgresql://postgres:PASSWORD@db.PROJECT.supabase.co:5432/postgres"
./scripts/migrate.sh
```

**Step 3** — Verify migrations
```bash
./scripts/smoke-test.sh
# Expected: Smoke test passed: 8/8 tables found.
```

**Step 4** — Create the `mos-images` storage bucket in Supabase (public)

**Step 5** — Import all 9 workflows into n8n from the `n8n/` directory

**Step 6** — Set all env vars in n8n Settings → Environment Variables

**Step 7** — Toggle all 9 workflows to **Active** in n8n

Full details in [`docs/setup.md`](docs/setup.md).

---

## I'm a...

### Novice
→ Follow [`docs/setup.md`](docs/setup.md) step by step.  
→ Use the default configuration — everything works out of the box with ComfyUI + fal.ai Kling.  
→ If something breaks, consult [`docs/troubleshooting.md`](docs/troubleshooting.md).

### Standard
→ Customize the script agent prompt in `prompts/video-script-agent.md`.  
→ Switch the video model by changing `FAL_VIDEO_MODEL` in `.env` (see `.env.example` for supported models).  
→ Bring your own reference images by skipping ComfyUI and setting `reference_image_url` directly in Notion.

### Expert
→ Fork the migrations and add custom tables following the Sprint pattern.  
→ Add new n8n workflows using the established RPC patterns (see `docs/architecture.md`).  
→ Contribute back via a PR — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## What's inside

```
mos-pipeline/
├── migrations/          # PostgreSQL migrations (000–006)
│   └── validate/        # Smoke test SQL
├── n8n/                 # n8n workflow JSON files (importable)
├── comfyui/             # ComfyUI workflow JSON
├── prompts/             # LLM system prompts
├── scripts/             # migrate.sh / migrate.ps1 / smoke-test.sh
├── docs/
│   ├── setup.md         # Installation guide
│   ├── architecture.md  # Pipeline diagram and design decisions
│   ├── security.md      # Security guidelines
│   ├── operations.md    # Daily runbook
│   ├── troubleshooting.md
│   └── e2e-test-plan.md
└── .env.example         # All required environment variables
```

## Pipeline Stages

| Stage | Tool | n8n Workflow |
|---|---|---|
| Content sync | Notion | MOS-v4.1-Notion-Sync |
| Script generation | OpenRouter (LLM) | MOS-v4.1-Script-Agent |
| Reference image | ComfyUI (SDXL) | MOS-v4.1-ComfyUI-Submit / Callback |
| Video generation | fal.ai | MOS-v4.1-Fal-Submit / Webhook / Sweeper |
| Publishing | Blotato | MOS-v4.1-Blotato-Publish |
| Analytics | Supabase | MOS-v4.1-Learning-Loop |

## Documentation

- [Setup guide](docs/setup.md)
- [Architecture](docs/architecture.md)
- [Security](docs/security.md)
- [Operations runbook](docs/operations.md)
- [Troubleshooting](docs/troubleshooting.md)
- [E2E test plan](docs/e2e-test-plan.md)
- [Contributing](CONTRIBUTING.md)

## License

MIT
