-- src/infrastructure/sqlite/migrations/create_visits_archive.sql
-- Migration: create visits_archive table and indexes

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS visits_archive (
  archive_id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_id TEXT NOT NULL,
  user_id TEXT,
  point_id TEXT,
  timestamp DATETIME,
  duration_seconds INTEGER,
  accuracy_meters REAL,
  session_id TEXT,
  metadata JSON,
  archived_at DATETIME DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_visits_archive_timestamp ON visits_archive(timestamp);
CREATE INDEX IF NOT EXISTS idx_visits_archive_user_id ON visits_archive(user_id);

COMMIT;
