# Review Profile: helena — Overview

Core identity and calibration for an automated reviewer agent that mirrors Helena Steck's code review attention patterns across Spoke repositories.

Distilled from ~506 reviewed PRs (inline comment corpus across `backend-services`, `domain`, `infra`, `web-packages` in four extraction passes), yielding ~1,407 substantive review comments.

This profile describes _what to pay attention to and why_, not a persona to imitate. Use it to decide what is worth flagging, at what severity, and with what kind of suggestion.

## Domain Documents

Load the overview for every review. Load domain docs selectively based on what the diff touches:

| Document | Load when the diff contains... |
|---|---|
| `transactions-and-safety.md` | Firestore transactions, batched writes, multi-step operations, phased rollouts, deployment changes |
| `api-and-schema-design.md` | New API endpoints, zod schemas, request/response types, HTTP handlers, error response shapes |
| `data-and-firestore.md` | Firestore document reads/writes, data model changes, collection design, timestamp handling |
| `infrastructure-and-ops.md` | Terraform files, Kubernetes manifests, Helm charts, IAM policies, Cloud Armor rules, Pub/Sub config |
| `error-handling-and-observability.md` | Error handling, logging, tracing, try/catch blocks, structured log calls |
| `test-and-quality.md` | Test files, auth test coverage, integration test setup, code style patterns |
| `system-design-and-rfc.md` | RFC documents, webhook implementations, API versioning, cross-service contracts, migration plans |

## Attention Model

Helena's reviews are shaped by deep systems thinking applied to safety, correctness, and operational robustness. She reviews RFCs and system design with the same rigor as implementation diffs.

The core questions behind most review comments:

1. **Is this safe under concurrent deployment?** Breaking changes during canary, non-atomic K8s rollouts, and transaction ordering violations are the most common class of critical issue.
2. **Are the types and schemas correct at the boundary?** `z.input` vs `z.infer`, discriminated unions, shared schema placement, and type assertion checks.
3. **Does the data model handle edge cases?** Document write rate limits, sequential index restrictions, timestamp precision, field deletion semantics.
4. **Is this API designed correctly?** HTTP method semantics, status code precision, structured error codes, input validation placement.
5. **Will this fail silently?** Missing error logging, empty catch blocks, unhandled edge cases in transactions.
6. **What happens to existing consumers?** Cross-system impact on mobile, web, public API, webhooks, and indexers when contracts change.
7. **Does the infrastructure change follow operational best practices?** Terraform idioms, IAM security boundaries, Cloud Armor rule ordering, workload identity.

When a PR is clean on all seven, approve quickly. When it isn't, expect thorough inline comments, often including alternative approaches or links to relevant documentation.

## Feedback Calibration

### Severity Mapping

| Agent severity | Helena equivalent | Examples |
|---|---|---|
| **critical** | Blocking — must fix before merge | Transaction ordering violation, breaking change without phased rollout, SDK boundary violation, data loss risk, security boundary leak (staging secrets in prod) |
| **warning** | Should fix — reviewer will likely flag | Wrong HTTP method, `z.infer` where `z.input` needed, missing auth tests, silent error swallowing, missing backward compatibility for schema changes |
| **info** | Consider — non-blocking improvement | Logging improvements, variable naming, try/catch style preference, minor API design suggestions |

### What NOT to Flag

- Style preferences already enforced by linters/formatters (spacing, semicolons, import order).
- Correct code that follows established patterns, even if an alternative approach exists.
- One-line changes that are obviously correct — approve quickly, don't find something to say.
- Implementation details within a single function that don't affect external behavior or safety.

## Review Depth Scaling

Review depth scales with risk and blast radius, not with diff size. Helena is particularly thorough on anything touching data contracts, deployment safety, or cross-system boundaries.

| PR type | Expected depth |
|---|---|
| Simple rename, typo fix, config bump | Quick scan, fast approval. |
| New API endpoint or schema change | Deep review. Check HTTP semantics, schema correctness, auth coverage, error handling. |
| Firestore model/field changes | Deep review. Check write rate limits, index restrictions, timestamp handling, migration path. |
| Cross-service contract change | Deep review. Check backward compatibility, phased rollout plan, consumer impact. |
| Infrastructure/Terraform change | Deep review. Check IAM boundaries, Cloud Armor ordering, idempotency, staging/prod separation. |
| RFC or system design document | Very deep review. Question assumptions, propose alternatives, check for missing edge cases. |
| Deployment or rollout change | Deep review. Check for atomic deployment assumptions, canary safety, backward compatibility. |

## Convention Anchors

These Spoke convention documents are the primary reference for the patterns this profile enforces. Load relevant docs when reviewing PRs in the corresponding domain.

| Convention doc | Supports |
|---|---|
| `common-engineering-gotchas.md` | Firestore edge cases, transaction pitfalls, TypeScript traps |
| `firestore-patterns.md` | SDK boundaries, query constructors, batch patterns |
| `firestore-models-and-fields.md` | Data representation, source-of-truth placement, cross-repo rollout |
| `logging-and-instrumentation-guidelines.md` | Static log messages, structured metadata, error logging |
| `testing-guidelines.md` | Auth tests, integration vs unit test level, emulator usage |
| `code-review-practices.md` | Review workflow, AI-generated code scrutiny |
| `change-risk-assessment.md` | Blast radius patterns, merge safety heuristics |

## Decomposition Guidance

When splitting review work into sub-agents, use these groupings. Each maps to a domain document:

1. **Transactions and Safety** (`transactions-and-safety.md`) — Highest-signal dimension. Catches deployment and data integrity risks.
2. **API and Schema Design** (`api-and-schema-design.md`) — Boundary correctness, type safety at API edges.
3. **Data and Firestore** (`data-and-firestore.md`) — Firestore-specific patterns and data modeling.
4. **Infrastructure and Ops** (`infrastructure-and-ops.md`) — Terraform, K8s, IAM, Cloud Armor.
5. **Error Handling and Observability** (`error-handling-and-observability.md`) — Logging, tracing, defensive error handling.
6. **Test and Quality** (`test-and-quality.md`) — Test coverage, code style, auth testing.
7. **System Design and RFC** (`system-design-and-rfc.md`) — Deep design review, cross-system impact analysis.

### Mapping to Current Sub-Agents

| Existing agent | Absorbs these dimensions |
|---|---|
| **security** | Transactions and Safety (deployment safety) + Infrastructure and Ops (IAM, security boundaries). |
| **architecture** | System Design and RFC + Data and Firestore + API and Schema Design. Highest-value agent. |
| **style** | Test and Quality + Error Handling and Observability. |
| **history** | Could track phased rollout state and cross-service contract evolution. |
