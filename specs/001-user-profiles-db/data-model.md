# Data Model: Godot Routine Profile Database

## Entities

### User
- `user_id`: unique identifier
- `username`: username or account name
- `email`: optional email for local login or SSO mapping
- `password_hash`: required for local auth, empty for pure SSO accounts
- `auth_provider`: local, google, apple, or other SSO provider
- `consent_location_tracking`: boolean flag
- `created_at`: account creation timestamp
- `last_login`: most recent login timestamp
- `status`: active, suspended, or deleted

### Point
- `point_id`: unique identifier for a map point
- `name`: human-readable label
- `coordinates`: object or pair (latitude, longitude) — prefer normalized representation
- `region_key`: optional map region or zone identifier
- `tags`: list of gameplay labels

### VisitEvent
- `event_id`: unique event identifier
- `user_id`: foreign key to `User` (must exist before insertion)
- `point_id`: foreign key to `Point`
- `timestamp`: event timestamp (UTC)
- `duration_seconds`: optional dwell duration
- `accuracy_meters`: optional GPS accuracy
- `session_id`: game session identifier
- `source_latitude`: optional raw player location latitude
- `source_longitude`: optional raw player location longitude
- `metadata`: optional JSON metadata

### UserProfile
- `profile_id`: unique identifier
- `user_id`: foreign key to `User`
- `points_frequented`: normalized frequency summary by `point_id` with counts
- `time_windows`: frequency summary by hour or time window
- `activity_score`: computed engagement metric
- `similarity_signature`: compressed representation for clustering
- `last_aggregated_at`: last recomputation timestamp
- `profile_state`: pending, generated, or stale

### ProfileGroup
- `group_id`: unique identifier
- `group_label`: human-readable name or code
- `centroid_signature`: representative similarity signature
- `member_count`: number of profiles in the group
- `similarity_threshold`: minimum similarity required
- `created_at`: creation timestamp
- `updated_at`: last update timestamp


## Validation Rules
- A PlayerAccount must exist before VisitEvent insertion.
- A VisitEvent must reference a valid point and must be rejected if consent is missing.
- `visited_at` cannot be null and should not drift far into the future.
- `duration_seconds`, if present, must be non-negative.
- `latitude` and `longitude` must be valid coordinates when present.
- `activity_score` and similarity values are derived data and must be recomputable from VisitEvent history.

## State Transitions
- User: active -> suspended -> deleted
- UserProfile: pending -> generated -> stale -> regenerated
- ProfileGroup: created -> updated -> retired

## Archive Schema (`visits_archive`)

Purpose: keep an audit/archival copy of old `VisitEvent` rows before purge, allowing regulatory/archive workflows.

- Table: `visits_archive`
	- `archive_id` INTEGER PRIMARY KEY AUTOINCREMENT
	- `event_id` TEXT
	- `user_id` TEXT
	- `point_id` TEXT
	- `timestamp` DATETIME
	- `duration_seconds` INTEGER
	- `accuracy_meters` REAL
	- `session_id` TEXT
	- `metadata` JSON
	- `archived_at` DATETIME DEFAULT CURRENT_TIMESTAMP

Indexes suggested:
- `CREATE INDEX idx_visits_archive_timestamp ON visits_archive(timestamp);`
- `CREATE INDEX idx_visits_archive_user_id ON visits_archive(user_id);

Migration note: create migration script `src/infrastructure/sqlite/migrations/create_visits_archive.sql` which creates the table and indexes atomically.
