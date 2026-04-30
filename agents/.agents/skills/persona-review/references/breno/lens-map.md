# Lens Map

Read this after `overview.md` when you need to choose the right lenses for a change.

Each lens owns one quality dimension. Load the smallest set of lenses that covers the real risk in the diff. Do not load every lens by default.

## The Lenses

| Lens | Primary concern | Typical trigger |
|---|---|---|
| `contract-lens` | External and internal contracts | API changes, schema changes, renames, compatibility risk |
| `boundary-lens` | Abstraction quality and ownership boundaries | New helpers, wrappers, packages, module seams, dependency direction |
| `state-lens` | Source of truth and behavior over time | Migrations, data model changes, state transitions, rollout plans |
| `runtime-lens` | Production safety and operational behavior | Retries, transactions, concurrency, logging, infra, background work |
| `user-experience-lens` | User-visible behavior and clarity | UI changes, copy, i18n, docs, empty states, error states |
| `verification-lens` | Proof that the change is safe | Tests, mocks, integration checks, risky changes with weak evidence |

## What Each Lens Covers

### Contract Lens

- Focuses on naming precision, exported surface design, schema evolution, compatibility windows, and parsing ownership at boundaries.
- Canonical examples: additive compatibility, raw-input vs transformed-output typing, HTTP method and status semantics, client parsing pushed too far.
- Ignore purely internal refactors unless they change what callers see or need to know.

### Boundary Lens

- Focuses on abstraction reuse, code placement, ownership boundaries, dependency direction, and structural indirection.
- Canonical examples: existing helper reuse, co-location, premature promotion to shared code, shared-package drift, barrels obscuring ownership.
- Ignore pure contract or runtime issues unless the boundary choice caused them.

### State Lens

- Focuses on source-of-truth decisions, lifecycle modeling, derived-field drift risk, transitions, migrations, and hidden product states.
- Canonical examples: canonical vs legacy representations, stale transition guards, UI-only hidden states, dropped branching data, trigger-backed drift.
- Ignore runtime implementation detail unless it changes persisted meaning or state transitions.

### Runtime Lens

- Focuses on transaction safety, retries, concurrency, partial failure, observability, deploy semantics, and infrastructure/runtime assumptions.
- Canonical examples: reads-after-writes in Firestore-style transactions, side effects in retries, non-atomic K8s rollout assumptions, structured error logging, webhook duplication.
- Ignore local naming or placement issues unless they create real production risk.

### User Experience Lens

- Focuses on user-visible behavior, copy, i18n structure, doc clarity near the feature, and explanation of non-obvious UI workarounds.
- Canonical examples: single-message i18n structure, stable message declarations, visible disabled vs hidden state, local doc drift, explained CSS workarounds.
- Ignore backend-only design issues unless they surface in the user experience or docs.

### Verification Lens

- Focuses on proof: test level, assertion quality, realistic fixtures, integration confidence, and round-trip validation.
- Canonical examples: status-code-only tests, shared test helper reuse, page-token or contract round trips, auth and edge-path coverage.
- Ignore low-risk diffs where extra proof would not materially change confidence.

## Common Overlaps

Load multiple lenses when a change crosses concerns:

- `contract-lens` + `state-lens`: schema changes, additive rollouts, migration compatibility
- `contract-lens` + `verification-lens`: contract change without proof that callers still work
- `boundary-lens` + `runtime-lens`: structural changes that affect production safety or failure handling
- `state-lens` + `runtime-lens`: jobs, migrations, or rollouts that can fail halfway
- `user-experience-lens` + `verification-lens`: user-facing changes that need interaction, copy, or i18n proof
- `user-experience-lens` + `contract-lens`: frontend changes that reflect renamed or reinterpreted APIs

## Starting Lens

- If the main risk is caller breakage, start with `contract-lens`.
- If the main risk is ownership or indirection, start with `boundary-lens`.
- If the main risk is data drift or lifecycle drift, start with `state-lens`.
- If the main risk is production failure, start with `runtime-lens`.
- If the main risk is user confusion or doc drift, start with `user-experience-lens`.
- If the main risk is insufficient proof, start with `verification-lens`.

When two lenses disagree on severity, prefer the one with the larger blast radius.

## Do Not

- Do not force every finding into one lens.
- Do not duplicate the same finding across multiple lenses.
- Do not load a lens only because a file extension matches. Load it because the risk matches.
- Do not let a lower-risk lens drown out a higher-risk concern.
