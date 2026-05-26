Title: T048 — Compliance & Consent Model Review

Description
-----------
Task to perform legal/compliance review and finalize the consent model for the `user-profiles-db` feature.

Objectives
----------
- Clarify whether consent must be explicit opt-in for location-sensitive data or opt-out is allowed in specific jurisdictions.
- Produce a definitive list of PII fields to be anonymized during `anonymize` retention mode (suggested: `email`, `username`, `source_latitude`, `source_longitude`).
- Define retroactivity policy for opt-out (immediate anonymization vs waiting for retention window).
- Verify audit log schema satisfies record-keeping requirements (retention period, integrity, actor identity).
- Produce a short compliance playbook: steps for audits, legal contact, and data subject requests.

Acceptance Criteria
-------------------
- A documented decision on opt-in vs opt-out with jurisdiction notes.
- A mapping of PII fields and anonymization rules (column-level).
- A checklist of legal requirements satisfied and open items.
- A short remediation plan for any open compliance gaps.

Owner: @legal or @product (assign as appropriate)

References
----------
- specs/001-user-profiles-db/spec.md
- specs/001-user-profiles-db/tasks.md (T048)
- src/infrastructure/sqlite/retention_job.gd

Suggested Labels: compliance, privacy, task
