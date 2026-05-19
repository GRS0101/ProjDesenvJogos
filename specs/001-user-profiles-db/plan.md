# Implementation Plan: Godot Routine Profile Database

**Branch**: `001-user-profiles-db` | **Date**: 19 de maio de 2026 | **Spec**: [spec.md](specs/001-user-profiles-db/spec.md)
**Input**: Feature specification from [specs/001-user-profiles-db/spec.md](specs/001-user-profiles-db/spec.md)

## Summary

Build a local-first player data layer for a Godot 4 game using GDScript 2.0 and SQLite so the game can store login data, location-based visit events, derive routine profiles, and group similar players for future recommendations. The plan favors a pure Godot implementation first; an external bridge service is only a fallback if the SQLite addon or equivalent integration cannot be used in the engine.

## Technical Context

**Language/Version**: Godot 4.2+ / GDScript 2.0  
**Primary Dependencies**: Godot core APIs, SQLite addon or GDExtension for Godot, GdUnit4 for automated tests, JSON utilities for export/import  
**Storage**: Embedded SQLite database file stored locally with optional JSON export for diagnostics  
**Testing**: BDD-style feature specs, GdUnit4 unit tests, Godot headless integration tests, scene-level functional tests  
**Target Platform**: Windows desktop Godot export target first, with portability to other Godot-supported platforms  
**Project Type**: Desktop game module / data layer inside a Godot project  
**Performance Goals**: Persist visit events in under 100 ms on local storage; recompute routine profiles for a player's recent history within 5 seconds for up to 10k visit events; cluster lookup under 200 ms for cached profiles  
**Constraints**: Must work offline, respect user consent for location collection, keep sensitive location data local by default, and preserve compatibility with Godot scripting  
**Scale/Scope**: MVP for a single game installation with thousands of users and tens of thousands of visit events per install

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Status: PASS

- TDD and BDD are required: satisfied by planning tests before implementation.
- Clean Architecture / SOLID / DDD / Repository Pattern / DI: satisfied by using domain entities, a repository boundary, and an application service layer.
- Tests-before-code and compile/analyze-before-tests: satisfied by the planned workflow and quickstart validation steps.
- User-facing testing and edge-case coverage: satisfied by the spec stories and acceptance scenarios already captured.

Required gate (enforced): Before any test task runs, CI/local workflow MUST execute the pre-test compilation/static-analysis step and enforce the coverage policy (100% for unit tests). See tasks T039 and T040 in `tasks.md` for concrete tasks. This is a constitution-level enforcement and blocks test execution until satisfied.

## Project Structure

### Documentation (this feature)

```text
specs/001-user-profiles-db/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

### Source Code (repository root)

```text
src/
├── application/
│   ├── routine_profile_service.gd
│   └── visit_capture_service.gd
├── domain/
│   ├── entities/
│   ├── value_objects/
│   └── services/
├── infrastructure/
│   ├── sqlite/
│   └── repositories/
└── presentation/
    └── autoload/

addons/
└── sqlite/

tests/
├── functional/
├── integration/
└── unit/
```

**Structure Decision**: Use a single Godot project with a layered GDScript architecture. The `src/domain` layer owns entities and business rules, `src/application` orchestrates use cases, `src/infrastructure` handles SQLite persistence, `addons/sqlite` hosts the database integration, and `tests/` keeps unit, integration, and functional tests outside production code.

**Terminology mapping**: To avoid drift between spec and implementation, use the following canonical terms in code and tasks:

- `User` == spec's `User` (files: `src/domain/entities/user.gd`, repository: `sqlite_user_repository.gd`)
- `Point` == spec's `Point` (files: `src/domain/entities/point.gd`)
- `UserProfile` == spec's `UserProfile` (files: `src/domain/entities/user_profile.gd`)
- `ProfileGroup` == spec's `ProfileGroup` (files: `src/domain/entities/profile_group.gd`)

Implementations or adapters may use alternate local names internally, but all public repository interfaces, tests and documentation must use the canonical terms above.

## Phase 0 Research Outputs

- Use embedded SQLite rather than an external API for v1 because it keeps the system local-first, compatible with Godot, and simpler to validate offline.
- Use an external bridge only as a contingency if the SQLite addon proves unavailable in the target Godot export pipeline.
- Model routine similarity from weighted visit frequencies and time buckets, then cluster players by a computed similarity score so recommendations can be driven by a stable profile summary instead of raw events.

## Additional Design Decisions

- **Authentication**: v1 must implement local credential auth (email/username + password hashing) and provide SSO adapter hooks to enable external providers. Tasks T041 and T042 implement these flows.
- **Retention enforcement**: v1 enforces a 1-year retention policy for visit events and derived profiles. A scheduled retention job (task T043) must support purge, archive, and anonymization modes and be test-covered.

## Complexity Tracking

No constitution violations required; no complexity justification is needed.
