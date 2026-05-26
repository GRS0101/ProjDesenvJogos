# Specification Quality Checklist: Banco de Dados de Perfis de Usuário (user-profiles-db)

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 19 de maio de 2026
**Feature**: [spec.md](specs/001-user-profiles-db/spec.md#L1)

## Content Quality

- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
 - [x] All mandatory sections completed

## Requirement Completeness

 - [x] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Success criteria are technology-agnostic (no implementation details)
- [ ] All acceptance scenarios are defined
- [ ] Edge cases are identified
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

## Feature Readiness

- [ ] All functional requirements have clear acceptance criteria
- [ ] User scenarios cover primary flows
- [ ] Feature meets measurable outcomes defined in Success Criteria
- [ ] No implementation details leak into specification

## Notes

- Items marked incomplete require spec updates before `/speckit.clarify` or `/speckit.plan`

## Requirement Traceability Addendum

- [ ] CHK001 Are the login and account data fields explicitly bounded to the minimum necessary set for registration and authentication? [Clarity, Spec §FR-001]
- [ ] CHK002 Is the consent requirement defined clearly enough to distinguish opt-in, opt-out, and rejected-location scenarios? [Coverage, Spec §FR-007]
- [ ] CHK003 Are location capture requirements explicit about what data is stored locally versus derived from the player routine? [Completeness, Spec §FR-002, Spec §FR-004]
- [ ] CHK004 Are time-window and frequency-based profiling terms defined with objective grouping criteria? [Measurability, Spec §FR-004, Spec §FR-005]
- [ ] CHK005 Does the retention requirement clearly state what happens to events and derived data after the 1-year window? [Gap, Spec §FR-008]
- [ ] CHK006 Is the hybrid authentication requirement unambiguous about which login methods are in scope for v1? [Clarity, Spec §FR-009]
- [ ] CHK007 Are the acceptance scenarios sufficient to cover registration, routine capture, and clustering as independently testable user journeys? [Coverage, Spec User Stories 1-3]
- [ ] CHK008 Are the success criteria quantified in a way that allows objective verification without implementation-specific assumptions? [Measurability, Spec Success Criteria]
- [ ] CHK009 Are edge cases for out-of-order events, future timestamps, duplicates, and empty histories explicitly called out? [Coverage, Spec Edge Cases]
- [ ] CHK010 Do the plan and tasks preserve the Godot-first constraint, with the bridge-service fallback clearly marked as conditional? [Consistency, Plan §Summary, Tasks Phase 6]
- [ ] CHK011 Are the data entities and relationships in the plan consistent with the domain terms used in the specification? [Consistency, Spec §Key Entities, Plan §Project Structure]
- [ ] CHK012 Are the tasks ordered so test artifacts appear before implementation tasks for each story? [Traceability, Tasks Phases 3-5]
- [ ] CHK013 Is the privacy boundary around local location storage and consent described without implying cloud-first collection? [Ambiguity, Spec §FR-002, Plan §Technical Context]
- [ ] CHK014 Are recommendation-oriented grouping requirements stated without prescribing a single clustering algorithm? [Flexibility, Spec §FR-005, Plan §Phase 0 Research Outputs]
 - [ ] CHK001 Are the login and account data fields explicitly bounded to the minimum necessary set for registration and authentication? [Clarity, Spec §FR-001]
	Proposed acceptance: `user_id`, `username` or `email`, `password_hash` (when local auth), `created_at`, `last_login`, `consent_flags`. Add task to document exact schema fields in `data-model.md` and verify via unit tests that no extra PII fields are stored.
 - [ ] CHK002 Is the consent requirement defined clearly enough to distinguish opt-in, opt-out, and rejected-location scenarios? [Coverage, Spec §FR-007]
	Proposed acceptance: Consent model supports flags `consent_location_tracking` (true/false) and an audit log of consent changes. Tasks: add unit tests for opt-out enforcement and integration tests verifying rejection of visit inserts.
 - [ ] CHK003 Are location capture requirements explicit about what data is stored locally versus derived from the player routine? [Completeness, Spec §FR-002, Spec §FR-004]
	Proposed acceptance: Raw visit events (lat/lon, point_id, timestamp) are stored locally; derived `UserProfile` contains aggregated summaries only (point_id counts, time_buckets) and no raw lat/lon unless consented. Add task to annotate tables with `sensitive` flags in `data-model.md`.
 - [ ] CHK004 Are time-window and frequency-based profiling terms defined with objective grouping criteria? [Measurability, Spec §FR-004, Spec §FR-005]
	Proposed acceptance: Define `time_windows` as hourly buckets (0-23) and `points_frequented` as counts over a rolling 30-day window. Add task to implement deterministic aggregation and unit tests with synthetic visit series.
 - [ ] CHK005 Does the retention requirement clearly state what happens to events and derived data after the 1-year window? [Gap, Spec §FR-008]
	Proposed acceptance: After 1 year, system supports `archive` (move rows to `visits_archive`), `anonymize` (null user_id and PII), and `purge` (delete). Add migration script and scheduled job (T043/T044) with dry-run and audit logging.
 - [ ] CHK006 Is the hybrid authentication requirement unambiguous about which login methods are in scope for v1? [Clarity, Spec §FR-009]
	Proposed acceptance: v1 supports local credentials (email/username + password hash) and SSO adapters (Google/Apple/OAuth) via pluggable adapters. Add tasks T041/T042 and an integration test for SSO mapping.
 - [ ] CHK007 Are the acceptance scenarios sufficient to cover registration, routine capture, and clustering as independently testable user journeys? [Coverage, Spec User Stories 1-3]
	Proposed acceptance: Each story has Gherkin coverage and unit/integration tests as listed in `tasks.md`. Confirm Gherkin scenarios exist for edge cases (invalid timestamps, consent denied).
 - [ ] CHK008 Are the success criteria quantified in a way that allows objective verification without implementation-specific assumptions? [Measurability, Spec Success Criteria]
	Proposed acceptance: Map SC-001 to synthetic registration performance test (95th percentile < 120s), SC-002 to ingestion test (simulate N events, expect 99% persisted), SC-004 to qualitative grouping validation dataset included in `tests/fixtures/`.
 - [ ] CHK009 Are edge cases for out-of-order events, future timestamps, duplicates, and empty histories explicitly called out? [Coverage, Spec Edge Cases]
	Proposed acceptance: Add unit tests demonstrating rejection/normalization of future timestamps, idempotent insertion logic for duplicates, and behavior for zero-visit users (no profile generated).
 - [ ] CHK010 Do the plan and tasks preserve the Godot-first constraint, with the bridge-service fallback clearly marked as conditional? [Consistency, Plan §Summary, Tasks Phase 6]
	Proposed acceptance: `plan.md` contains explicit conditional for fallback; tasks T037 mark fallback as conditional. Confirm in plan and add a gating test verifying addon availability during build.
 - [ ] CHK011 Are the data entities and relationships in the plan consistent with the domain terms used in the specification? [Consistency, Spec §Key Entities, Plan §Project Structure]
	Proposed acceptance: `plan.md` uses canonical `User/Point/UserProfile/ProfileGroup`; `data-model.md` updated accordingly. Add a glossary section to `spec.md` to lock terms.
 - [ ] CHK012 Are the tasks ordered so test artifacts appear before implementation tasks for each story? [Traceability, Tasks Phases 3-5]
	Proposed acceptance: Verify `tasks.md` lists tests (unit/integration/functional) before implementation tasks for each story. Add CI check to fail if any implementation task appears before its test task (optional static check script).
 - [ ] CHK013 Is the privacy boundary around local location storage and consent described without implying cloud-first collection? [Ambiguity, Spec §FR-002, Plan §Technical Context]
	Proposed acceptance: `spec.md` and `plan.md` state local-first storage and conditional cloud export; add explicit statement in Quickstart and a test that ensures export path is only enabled when a config flag is true.
 - [ ] CHK014 Are recommendation-oriented grouping requirements stated without prescribing a single clustering algorithm? [Flexibility, Spec §FR-005, Plan §Phase 0 Research Outputs]
	Proposed acceptance: Spec requires clustering by similarity signature; plan suggests algorithms but does not mandate one. Add acceptance test that validates cluster quality on a reference dataset rather than algorithm specifics.
