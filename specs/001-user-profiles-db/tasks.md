# Tasks: Godot Routine Profile Database

**Input**: Design documents from `/specs/001-user-profiles-db/`
**Prerequisites**: `plan.md` (required), `spec.md` (required for user stories), `research.md`, `data-model.md`, `quickstart.md`

**Tests**: The tasks below include BDD, unit, integration, and functional test tasks because the constitution requires test-first delivery and business-rule coverage.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize the Godot project structure, test layout, and SQLite addon workspace.

- [ ] T001 Create the Godot feature folders in `src/`, `tests/`, `addons/sqlite/`, and `docs/`
- [ ] T002 Configure the Godot project entry and autoload placeholder in `project.godot`
- [ ] T003 [P] Add the test folder structure for unit, integration, and functional coverage in `tests/unit/`, `tests/integration/`, and `tests/functional/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core domain and infrastructure boundaries that must exist before any user story can be implemented.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T004 Define the SQLite bootstrap and schema loading entrypoint in `src/infrastructure/sqlite/schema_loader.gd`
- [ ] T005 [P] Create repository interface contracts for players, visits, profiles, and clusters in `src/domain/repositories/player_repository.gd`, `src/domain/repositories/visit_repository.gd`, `src/domain/repositories/profile_repository.gd`, and `src/domain/repositories/cluster_repository.gd`
- [ ] T006 [P] Create the shared domain entities and value objects in `src/domain/entities/` and `src/domain/value_objects/`
- [ ] T007 Implement consent and location validation policies in `src/domain/services/consent_policy.gd` and `src/domain/services/location_validation.gd`
- [ ] T008 Set up the composition root and dependency wiring in `src/presentation/autoload/app_container.gd`
- [ ] T009 [P] Add BDD scenario scaffolding for the three stories in `tests/functional/`
 - [ ] T005 [P] Create repository interface contracts for users, visits, profiles, and groups in `src/domain/repositories/user_repository.gd`, `src/domain/repositories/visit_repository.gd`, `src/domain/repositories/profile_repository.gd`, and `src/domain/repositories/group_repository.gd`
 - [ ] T006 [P] Create the shared domain entities and value objects in `src/domain/entities/` and `src/domain/value_objects/`
 - [ ] T007 Implement consent and location validation policies in `src/domain/services/consent_policy.gd` and `src/domain/services/location_validation.gd`
 - [ ] T008 Set up the composition root and dependency wiring in `src/presentation/autoload/app_container.gd`
 - [ ] T009 [P] Add BDD scenario scaffolding for the three stories in `tests/functional/`
 - [ ] T039 Add pre-test compilation/static-analysis gate script and task to run before any test execution (`scripts/ci/pre_test_check.ps1`) and wire it into CI
 - [ ] T040 Configure test coverage enforcement to require 100% coverage for unit tests and add CI check configuration (`tests/config/coverage_policy.json`)
 - [ ] T041 [P] Implement local authentication flow and password hashing with tests in `src/application/auth_local_service.gd` and `tests/unit/test_auth_local.gd`
 - [ ] T042 [P] Implement SSO adapter hooks and mapping tests in `src/application/auth_sso_adapter.gd` and `tests/integration/test_sso_integration.gd`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel.

---

## Phase 3: User Story 1 - Registro e Login (Priority: P1) 🎯 MVP

**Goal**: Persist local account data and support login with `last_login` updates for the player.

**Independent Test**: Create a player account, log in again with the same credentials, and verify that the stored account data and `last_login` timestamp are updated.

### Tests for User Story 1

- [ ] T010 [P] [US1] Write Gherkin scenarios for player registration and login in `tests/functional/player_registration_login.feature`
- [ ] T011 [P] [US1] Add unit tests for player account creation and authentication rules in `tests/unit/test_player_account.gd`
- [ ] T012 [P] [US1] Add unit tests for the account repository persistence rules in `tests/unit/test_player_account_repository.gd`
- [ ] T013 [P] [US1] Add an integration test for the full registration and login flow in `tests/integration/test_registration_login_flow.gd`

### Implementation for User Story 1

 - [ ] T014 [P] [US1] Implement the `User` entity in `src/domain/entities/user.gd`
 - [ ] T015 [US1] Implement the account application service in `src/application/account_service.gd`
 - [ ] T016 [US1] Implement the SQLite user repository in `src/infrastructure/repositories/sqlite_user_repository.gd`
 - [ ] T017 [US1] Wire login timestamp updates and consent checks into `src/application/account_service.gd`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently.

---

## Phase 4: User Story 2 - Registro de Rotina (Priority: P2)

**Goal**: Capture visit events from the game world, store location history, and support historical queries.

**Independent Test**: Record a visit event for a player, query it by time range, and verify that invalid or non-consented events are rejected.

### Tests for User Story 2

- [ ] T018 [P] [US2] Write Gherkin scenarios for visit capture and history lookup in `tests/functional/player_visit_capture.feature`
- [ ] T019 [P] [US2] Add unit tests for visit event validation and point matching in `tests/unit/test_visit_event.gd`
- [ ] T020 [P] [US2] Add unit tests for visit repository queries, ordering, and idempotency in `tests/unit/test_visit_repository.gd`
- [ ] T021 [P] [US2] Add an integration test for visit storage, period filtering, and consent rejection in `tests/integration/test_visit_capture_flow.gd`

### Implementation for User Story 2

- [ ] T022 [P] [US2] Implement the `VisitEvent` entity and metadata handling in `src/domain/entities/visit_event.gd`
- [ ] T023 [US2] Implement the visit capture application service in `src/application/visit_capture_service.gd`
- [ ] T024 [US2] Implement the SQLite visit repository in `src/infrastructure/repositories/sqlite_visit_repository.gd`
- [ ] T025 [US2] Implement history query normalization and timestamp validation in `src/application/visit_capture_service.gd`

**Checkpoint**: At this point, User Stories 1 and 2 should both work independently.

---

## Phase 5: User Story 3 - Geração e Agrupamento de Perfis (Priority: P3)

**Goal**: Aggregate visit history into routine profiles and group players with compatible routines for future recommendations.

**Independent Test**: Recompute profiles for a set of visits and verify that the resulting clusters group similar players by frequent points and time windows.

### Tests for User Story 3

- [ ] T026 [P] [US3] Write Gherkin scenarios for profile generation and clustering in `tests/functional/routine_profile_grouping.feature`
- [ ] T027 [P] [US3] Add unit tests for routine scoring and similarity calculation in `tests/unit/test_routine_profile_scoring.gd`
- [ ] T028 [P] [US3] Add unit tests for profile aggregation and cluster assignment in `tests/unit/test_profile_clusterer.gd`
- [ ] T029 [P] [US3] Add an integration test for profile recomputation and group assignment in `tests/integration/test_profile_grouping_flow.gd`

### Implementation for User Story 3

 - [ ] T030 [P] [US3] Implement the `UserProfile` and `ProfileGroup` entities in `src/domain/entities/user_profile.gd` and `src/domain/entities/profile_group.gd`
 - [ ] T031 [US3] Implement the routine aggregation service in `src/application/user_profile_service.gd`
 - [ ] T032 [US3] Implement the profile and group repositories in `src/infrastructure/repositories/sqlite_profile_repository.gd`
 - [ ] T033 [US3] Implement similarity scoring and clustering logic in `src/domain/services/profile_similarity.gd`

**Checkpoint**: All user stories should now be independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories.

- [ ] T034 [P] Refactor shared repository abstractions and dependency wiring in `src/domain/repositories/` and `src/presentation/autoload/app_container.gd`
- [ ] T035 [P] Update `specs/001-user-profiles-db/quickstart.md` and `specs/001-user-profiles-db/research.md` with validated setup notes
- [ ] T036 [P] Add security and privacy hardening checks for consent, retention, and local location storage in `src/domain/services/consent_policy.gd` and `src/infrastructure/sqlite/`
- [ ] T037 [P] Validate the SQLite addon export path and implement the fallback bridge only if addon integration is blocked in `src/infrastructure/sqlite/` and `src/application/`
- [ ] T038 Run the validation flow from `specs/001-user-profiles-db/quickstart.md` against the Godot project
 - [ ] T036 [P] Add security and privacy hardening checks for consent, retention, and local location storage in `src/domain/services/consent_policy.gd` and `src/infrastructure/sqlite/`
 - [ ] T037 [P] Validate the SQLite addon export path and implement the fallback bridge only if addon integration is blocked in `src/infrastructure/sqlite/` and `src/application/`
 - [ ] T038 Run the validation flow from `specs/001-user-profiles-db/quickstart.md` against the Godot project
 - [ ] T043 [P] Implement retention enforcement (purge/archive/anonymize) job for 1-year policy and add unit/integration tests in `src/infrastructure/sqlite/retention_job.gd` and `tests/integration/test_retention_job.gd`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories.
- **User Stories (Phase 3+)**: All depend on Foundational phase completion.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational phase - no dependencies on other stories.
- **User Story 2 (P2)**: Can start after Foundational phase - may integrate with User Story 1, but remains independently testable.
- **User Story 3 (P3)**: Can start after Foundational phase - may integrate with User Stories 1 and 2, but remains independently testable.

### Within Each User Story

- Tests MUST be written and failing before implementation begins.
- Domain entities before repositories and services.
- Services before integration wiring.
- Story complete before moving to the next priority.

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel.
- All Foundational tasks marked [P] can run in parallel.
- Once Foundational work is done, all user stories can start in parallel if staffing allows.
- All tests for a user story marked [P] can run in parallel.
- Different user stories can be worked on in parallel by different team members.

---

## Parallel Example: User Story 1

```bash
Task: "Write Gherkin scenarios for player registration and login in tests/functional/player_registration_login.feature"
Task: "Add unit tests for player account creation and authentication rules in tests/unit/test_player_account.gd"
Task: "Add unit tests for the account repository persistence rules in tests/unit/test_player_account_repository.gd"
Task: "Add an integration test for the full registration and login flow in tests/integration/test_registration_login_flow.gd"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Stop and validate User Story 1 independently.
5. Demo or inspect the account flow before continuing.

### Incremental Delivery

1. Complete Setup + Foundational.
2. Add User Story 1 and validate it.
3. Add User Story 2 and validate it.
4. Add User Story 3 and validate it.
5. Finish with polish and cross-cutting hardening.

### Parallel Team Strategy

1. Team completes Setup + Foundational together.
2. After Foundational is done:
   - Developer A works on User Story 1.
   - Developer B works on User Story 2.
   - Developer C works on User Story 3.
3. Each story is completed and validated independently.

---

## Notes

- [P] tasks = different files, no dependencies.
- [Story] label maps the task to a specific user story.
- Verify tests fail before implementing the corresponding code.
- Keep the fallback bridge task conditional; only execute it if the SQLite addon path is blocked in Godot export validation.