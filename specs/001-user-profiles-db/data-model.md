# Data Model: Godot Routine Profile Database

## Entities

### PlayerAccount
- `player_id`: unique identifier
- `login_name`: username or account name
- `email`: optional email for local login or SSO mapping
- `password_hash`: required for local auth, empty for pure SSO accounts
- `auth_provider`: local, google, apple, or other SSO provider
- `consent_location_tracking`: boolean flag
- `created_at`: account creation timestamp
- `last_login_at`: most recent login timestamp
- `status`: active, suspended, or deleted

### LocationPoint
- `point_id`: unique identifier for a map point
- `name`: human-readable label
- `latitude`: location latitude
- `longitude`: location longitude
- `region_key`: optional map region or zone identifier
- `tags`: list of gameplay labels

### VisitEvent
- `event_id`: unique event identifier
- `player_id`: foreign key to PlayerAccount
- `point_id`: foreign key to LocationPoint
- `visited_at`: event timestamp
- `duration_seconds`: optional dwell duration
- `accuracy_meters`: optional GPS accuracy
- `session_id`: game session identifier
- `source_latitude`: optional raw player location latitude
- `source_longitude`: optional raw player location longitude
- `source_metadata`: optional JSON metadata

### RoutineProfile
- `profile_id`: unique identifier
- `player_id`: foreign key to PlayerAccount
- `dominant_points`: normalized frequency summary by point
- `time_buckets`: frequency summary by hour or time window
- `activity_score`: computed engagement metric
- `similarity_signature`: compressed representation for clustering
- `last_aggregated_at`: last recomputation timestamp
- `profile_state`: pending, generated, or stale

### ProfileCluster
- `cluster_id`: unique identifier
- `cluster_label`: human-readable name or code
- `centroid_signature`: representative similarity signature
- `member_count`: number of profiles in the cluster
- `similarity_threshold`: minimum similarity required
- `created_at`: creation timestamp
- `updated_at`: last update timestamp

## Relationships
- One PlayerAccount has many VisitEvent records.
- One LocationPoint has many VisitEvent records.
- One PlayerAccount has zero or one current RoutineProfile, with history stored through recomputation snapshots if required.
- One ProfileCluster contains many RoutineProfile records.

## Validation Rules
- A PlayerAccount must exist before VisitEvent insertion.
- A VisitEvent must reference a valid point and must be rejected if consent is missing.
- `visited_at` cannot be null and should not drift far into the future.
- `duration_seconds`, if present, must be non-negative.
- `latitude` and `longitude` must be valid coordinates when present.
- `activity_score` and similarity values are derived data and must be recomputable from VisitEvent history.

## State Transitions
- PlayerAccount: active -> suspended -> deleted
- RoutineProfile: pending -> generated -> stale -> regenerated
- ProfileCluster: created -> updated -> retired
