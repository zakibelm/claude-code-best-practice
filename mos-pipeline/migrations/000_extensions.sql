-- =============================================================================
-- MOS v4.1-RC1 — Migration 000 : PostgreSQL Extensions
-- Run this before all other migrations.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
