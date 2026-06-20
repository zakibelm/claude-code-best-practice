#!/usr/bin/env bash
# smoke-test.sh — Run the smoke-test SQL and verify all expected objects exist.
# Usage: DATABASE_URL=postgres://... ./scripts/smoke-test.sh
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "Error: DATABASE_URL is not set." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SMOKE_SQL="$SCRIPT_DIR/../migrations/validate/smoke-test.sql"

echo "Running smoke test..."

# Run the smoke test and capture table count (first SELECT returns tables_found)
TABLES_FOUND=$(psql "$DATABASE_URL" -t -c "
  SELECT COUNT(*) FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name IN (
      'clients','video_production_notion','image_generation_queue',
      'fal_video_queue','video_memory_notion','processing_locks',
      'alert_queue','notion_sync_events'
    );
")

TABLES_FOUND=$(echo "$TABLES_FOUND" | tr -d '[:space:]')

if [[ "$TABLES_FOUND" -eq 8 ]]; then
  echo "Smoke test passed: $TABLES_FOUND/8 tables found."
  echo "Running full diagnostic..."
  psql "$DATABASE_URL" -f "$SMOKE_SQL"
  exit 0
else
  echo "Smoke test FAILED: expected 8 tables, found $TABLES_FOUND." >&2
  echo "Run migrations first: ./scripts/migrate.sh" >&2
  exit 1
fi
