#!/usr/bin/env bash
# migrate.sh — Apply MOS v4.1-RC1 migrations in order (Linux/macOS/CI)
# Usage: DATABASE_URL=postgres://... ./scripts/migrate.sh
set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "Error: DATABASE_URL is not set." >&2
  exit 1
fi

MIGRATIONS_DIR="$(cd "$(dirname "$0")/../migrations" && pwd)"

MIGRATIONS=(
  "000_extensions.sql"
  "001_v4_1_sprint1_base.sql"
  "002_v4_1_sprint2_rag.sql"
  "003_v4_1_sprint3_comfyui.sql"
  "004_v4_1_sprint4_fal.sql"
  "005_v4_1_sprint5_blotato.sql"
  "006_v4_1_sprint6_learning_loop.sql"
)

echo "Applying MOS v4.1-RC1 migrations..."

for migration in "${MIGRATIONS[@]}"; do
  file="$MIGRATIONS_DIR/$migration"
  if [[ ! -f "$file" ]]; then
    echo "Missing: $file" >&2
    exit 1
  fi
  echo "  → $migration"
  psql "$DATABASE_URL" -f "$file" --single-transaction -v ON_ERROR_STOP=1
done

echo "All migrations applied successfully."
