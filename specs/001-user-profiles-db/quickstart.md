# Quickstart: Godot Routine Profile Database

## Goal
Set up the Godot-side data layer so the game can store player login data, capture location-based visits, and derive similarity groups for future recommendations.

## Prerequisites
- Godot 4.2 or newer
- A SQLite addon or GDExtension compatible with Godot
- GdUnit4 installed for test execution

## Setup Steps
1. Open the Godot project in the editor.
2. Enable the SQLite addon in `addons/sqlite` if it is delivered as a plugin.
3. Configure an autoload singleton for the application service that captures visits and updates profiles.
4. Create the SQLite database file in a writable local location for the first run.
5. Seed the database with a few sample players, points, and visit events for validation.

## Validation Flow
1. Run the unit tests first to validate repository and aggregation rules.
2. Run the integration tests that insert visit events and recompute profiles.
3. Run a functional scene test that simulates a player logging in, visiting points, and generating a compatible profile group.

## Expected Behavior
- Player account data is persisted locally.
- Location events are stored as normalized records.
- Routine profiles are generated from visit history.
- Similar profiles are grouped for future recommendation logic.

## Fallback Path
If the SQLite addon cannot be used in the target export, introduce a small bridge service and keep the Godot-facing API unchanged so the game can continue to call the same use cases.
