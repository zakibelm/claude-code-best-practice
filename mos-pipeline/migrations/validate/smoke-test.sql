-- =============================================================================
-- MOS v4.1-RC1 — Smoke Test
-- Verifies that all migrations were applied successfully.
-- Run after all migrations: psql $DATABASE_URL -f migrations/validate/smoke-test.sql
-- Expected output: each check returns count = 1 (exists) or the correct total.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Tables (8 expected)
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS tables_found
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'clients',
    'video_production_notion',
    'image_generation_queue',
    'fal_video_queue',
    'video_memory_notion',
    'processing_locks',
    'alert_queue',
    'notion_sync_events'
  );
-- Expected: 8

-- ---------------------------------------------------------------------------
-- Views (3 expected)
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS views_found
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name IN (
    'fal_jobs_active',
    'learning_loop_candidates',
    'memory_performance_summary'
  );
-- Expected: 3

-- ---------------------------------------------------------------------------
-- Key functions (10 expected)
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS functions_found
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN (
    'acquire_processing_lock',
    'release_processing_lock',
    'queue_fal_video',
    'mark_fal_started',
    'mark_fal_completed',
    'mark_fal_failed',
    'claim_next_comfyui_job',
    'mark_comfyui_completed',
    'upsert_video_memory',
    'ingest_video_kpis'
  );
-- Expected: 10

-- ---------------------------------------------------------------------------
-- Extensions (2 expected)
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS extensions_found
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pgcrypto');
-- Expected: 2
