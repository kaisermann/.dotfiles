# System Design and RFC

Deep design review patterns for RFCs, webhook systems, API versioning, cross-service contracts, and migration planning. Helena reviews system design documents with exceptional depth — questioning assumptions, proposing alternatives, and checking for missing edge cases.

## RFC Review Approach

Helena's RFC reviews go far beyond surface-level feedback. She questions fundamental assumptions, proposes alternative approaches, and identifies missing edge cases systematically.

**What to look for when reviewing RFCs:**

- Assumptions stated without justification — ask "why this approach over alternatives?"
- Missing failure mode analysis — what happens when each component fails?
- Incomplete consumer impact analysis — which systems (mobile, web, public API, webhooks, indexers) are affected?
- Migration plans that assume zero-downtime deployment without proving it.
- Missing capacity/performance estimates for new systems.

**Severity:** Warning for missing failure modes and consumer impact analysis in RFCs.

## Webhook Design

Helena has strong opinions on webhook correctness, drawn from deep domain review experience.

**What to look for:**

- Token-based webhook authentication — should use HMAC signatures instead (tokens are static secrets; HMAC proves payload integrity).
- Missing idempotency handling — webhook receivers must tolerate duplicate deliveries.
- Missing timestamp in webhook payloads — needed for replay attack prevention.
- Ordering assumptions without ordering guarantees — webhooks are not guaranteed to arrive in order.
- Missing versioning strategy for webhook payload changes.
- Webhook retry logic that doesn't use exponential backoff.

**Severity:** Warning for HMAC over tokens, missing idempotency. Info for versioning suggestions.

**Corpus examples:**

- _"Use HMAC signatures instead of tokens for webhook authentication"_ (domain)
- _"Webhooks need idempotency — receivers must handle duplicates"_ (domain)
- _"Add a timestamp for replay prevention"_ (domain)

## API Versioning

**What to look for:**

- Breaking API changes without a versioning strategy.
- Path-based versioning (`/v1/`, `/v2/`) vs header-based versioning — each has tradeoffs that should be documented.
- Version sunset plans that don't account for existing consumer migration timelines.

**Severity:** Info for most versioning discussions.

## Cross-System Impact Analysis

Helena consistently checks whether a change affects systems beyond the immediate PR scope.

**What to look for:**

- API contract changes that affect mobile clients, web clients, public API consumers, webhook receivers, or indexers.
- Database schema changes that require coordinated rollouts across multiple services.
- New fields or endpoints that need to be reflected in documentation, SDKs, or client libraries.
- Eventual consistency implications — when one system updates, how long before others see the change?
- At-least-once delivery semantics — all message consumers must handle duplicates.

**Severity:** Warning for missing cross-system impact analysis on contract changes. Critical for uncoordinated breaking changes.

**Corpus examples:**

- _"What about mobile? Will this break the iOS/Android clients?"_ (domain)
- _"The indexers also need to be updated for this schema change"_ (domain)
- _"This is at-least-once delivery — the handler must be idempotent"_ (domain)

## Migration and Backward Compatibility

**What to look for:**

- Migrations that could be avoided with backward-compatible evolution (additive changes, optional fields with defaults).
- Breaking changes framed as migrations when a non-breaking approach exists.
- Missing rollback plans for data migrations.
- Coupling between migration steps that prevents independent deployment.

**Severity:** Warning for unnecessary migrations. Info for rollback plan suggestions.

**Corpus examples:**

- _"Can we avoid the migration by making the field optional with a default?"_ (domain)
- _"What's the rollback plan if this migration fails halfway?"_ (domain)

## Anti-Patterns

1. **Token-based webhook auth** — Use HMAC signatures for payload integrity verification.
2. **Non-idempotent webhook receivers** — Must tolerate duplicate deliveries.
3. **Missing cross-system impact analysis** — Contract changes must account for all consumers.
4. **Unnecessary migrations** — Prefer backward-compatible evolution over breaking migrations.
5. **Unquestioned assumptions in RFCs** — Every design choice should have a documented rationale.
6. **Missing failure mode analysis** — RFCs must address what happens when components fail.
