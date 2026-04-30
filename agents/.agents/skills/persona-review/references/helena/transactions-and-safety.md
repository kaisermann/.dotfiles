# Transactions and Safety

Transaction correctness, atomicity guarantees, phased rollout discipline, and deployment safety awareness. Helena's highest-frequency and highest-severity review dimension.

## Transaction Ordering and Atomicity

Firestore transactions have strict ordering requirements and size constraints that are frequently violated.

**What to look for:**

- Reads that happen after writes inside a transaction — all reads must precede all writes.
- Side effects inside transactions (sending emails, publishing events) that will execute on every retry.
- `set` used where `create` is correct — `set` overwrites silently, `create` fails on existing documents (prevents duplicates).
- Transaction size approaching the 10MB limit without awareness or chunking.
- Missing precondition-based optimistic locking for concurrent write scenarios.
- Batched writes used where transactions are needed (batches don't provide read-then-write atomicity).
- Transactions used where batches suffice (transactions add contention, batches don't need reads).

**Severity:** Critical for ordering violations and side-effect-in-transaction bugs. Warning for suboptimal transaction/batch choice.

**Corpus examples:**

- _"reads must happen before writes in a transaction"_ (backend-services, multiple PRs)
- _"If we're sending an email inside the transaction, it will be sent on every retry"_ (backend-services)
- _"Use `create` instead of `set` to prevent overwriting existing documents"_ (backend-services)
- _"transaction size limit is 10MB"_ (backend-services)

## Phased Rollout Discipline

Breaking changes require phased rollouts because K8s deployments are not atomic — old and new pods coexist during rollout.

**What to look for:**

- Breaking API changes (renamed fields, removed endpoints, changed response shapes) deployed in a single step.
- Missing `.default({})` or similar backward-compatible fallbacks on new zod schema fields.
- New endpoints that callers depend on before the deployment containing them is fully rolled out.
- Database schema changes that assume all readers are on the new version simultaneously.
- Missing rollout plan in PR description for cross-service changes.

**Severity:** Critical when a single-step deploy could cause failures during canary. Warning for missing rollout documentation.

**Corpus examples:**

- _"This is a breaking change. We need to deploy in two steps: first add the new field with a default, then switch callers."_ (backend-services)
- _"K8s deployments are not atomic — old and new pods coexist"_ (backend-services)
- _"Add `.default({})` to make this backward compatible during rollout"_ (backend-services)

## Concurrent Operation Safety

Beyond transactions, concurrent operations need explicit safety reasoning.

**What to look for:**

- `Promise.all` on dependent operations that should be sequential.
- Missing `Promise.allSettled` for independent operations where partial failure is acceptable.
- Race conditions in multi-step operations without locking or idempotency keys.
- Retry logic that doesn't account for already-completed side effects.

**Severity:** Warning for missing concurrency consideration. Critical for data corruption risk.

## Anti-Patterns

1. **Writes before reads in transactions** — Firestore transactions require all reads to precede all writes.
2. **Side effects in transactions** — Emails, webhooks, or event publishing inside transaction bodies that re-execute on retry.
3. **Single-step breaking changes** — Deploying breaking API or schema changes without a phased rollout plan.
4. **`set` where `create` is needed** — Silent overwrites when the intent is to fail on existing documents.
5. **Missing backward compatibility** — New required fields without `.default()` fallbacks during rollout windows.
6. **Transaction overuse** — Using transactions for write-only operations where batches provide sufficient atomicity.
