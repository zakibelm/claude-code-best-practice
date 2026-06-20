# migrate.ps1 — Apply MOS v4.1-RC1 migrations in order (Windows PowerShell)
# Usage: $env:DATABASE_URL="postgres://..."; .\scripts\migrate.ps1
param()
$ErrorActionPreference = 'Stop'

if (-not $env:DATABASE_URL) {
    Write-Error "DATABASE_URL is not set."
    exit 1
}

$migrationsDir = Join-Path $PSScriptRoot "..\migrations" | Resolve-Path

$migrations = @(
    "000_extensions.sql",
    "001_v4_1_sprint1_base.sql",
    "002_v4_1_sprint2_rag.sql",
    "003_v4_1_sprint3_comfyui.sql",
    "004_v4_1_sprint4_fal.sql",
    "005_v4_1_sprint5_blotato.sql",
    "006_v4_1_sprint6_learning_loop.sql"
)

Write-Host "Applying MOS v4.1-RC1 migrations..."

foreach ($migration in $migrations) {
    $file = Join-Path $migrationsDir $migration
    if (-not (Test-Path $file)) {
        Write-Error "Missing: $file"
        exit 1
    }
    Write-Host "  -> $migration"
    & psql $env:DATABASE_URL -f $file --single-transaction -v ON_ERROR_STOP=1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Migration failed: $migration"
        exit $LASTEXITCODE
    }
}

Write-Host "All migrations applied successfully."
