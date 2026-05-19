# Research Notes: Godot Routine Profile Database

## Decision 1: Runtime and storage
- Decision: Use Godot 4.2+ with GDScript 2.0 and an embedded SQLite database.
- Rationale: This keeps the implementation compatible with the engine, preserves offline operation, and avoids introducing an extra backend for v1.
- Alternatives considered: External API plus separate database service, plain file storage, and PostgreSQL via bridge service.

## Decision 2: Fallback bridge
- Decision: Keep an external bridge service as a contingency only if the SQLite addon or equivalent Godot integration cannot be used reliably in the export target.
- Rationale: The user explicitly prefers GDScript, so a pure Godot implementation should be attempted first.
- Alternatives considered: Making the bridge the primary architecture or exposing the database directly over HTTP from day one.

## Decision 3: Routine similarity model
- Decision: Derive routine profiles from weighted point frequency, visit timing buckets, and recent activity windows, then cluster players by similarity score.
- Rationale: The model is simple enough to implement in GDScript, explainable to designers, and suitable for future recommendation features.
- Alternatives considered: K-means, DBSCAN, graph-based community detection, and fully learned embeddings.

## Decision 4: Data capture shape
- Decision: Store each visit as a normalized event with player, point, timestamp, and location metadata.
- Rationale: Raw events preserve auditability and allow recomputation of profiles when clustering rules evolve.
- Alternatives considered: Storing only aggregated counters or fully denormalized player snapshots.

## Decision 5: Consent and location handling
- Decision: Treat location tracking as consent-gated data and keep location data local by default.
- Rationale: The feature depends on location access, so consent and privacy boundaries need to be explicit from the start.
- Alternatives considered: Implicit collection without consent and cloud-first analytics.
