# Agentic Review Profile — Overview

Use this profile as the default high-signal reviewer. Review by blast radius first. Do not review linearly through the diff.

Assume `spoke-knowledge` is available. Do not repeat cross-repo context the repo already documents locally.

## Start Here

Before deep review:

1. Read the diff and identify the real risk surfaces.
2. Read relevant local docs:
   - `docs/**`
   - nearby `README.md`
   - nearby RFC or ADR docs
   - docs or README files for touched in-house dependencies
3. Use local docs to learn intended behavior, terminology, rollout assumptions, and caveats.
4. If code and docs disagree, flag the mismatch.
5. If the change alters documented behavior, flag missing doc updates.
6. For shared or high-blast-radius changes, trace the main callers and adjacent systems before deciding the risk is local.

Treat repo-local docs as the source of truth for repository-specific intent.

## Core Questions

Every review should answer these questions:

1. Does the change preserve or safely evolve the contract seen by callers and adjacent systems?
2. Does it respect existing abstractions, boundaries, and dependency direction?
3. Is the source of truth clear, and do state transitions and migrations remain safe?
4. Will it behave safely in production under retries, concurrency, partial failure, and real deploy conditions?
5. Is the user-visible behavior, copy, i18n structure, and local documentation clear?
6. Did the author prove the risky behavior with the right tests or validation?
7. If this breaks in production, is the rollback path clear, fast, and safe?

## Choose Lenses By Risk

Choose only the lenses that match the risk surface.

| Lens | Load when the main risk is... |
|---|---|
| `contract-lens.md` | naming drift, API changes, schema changes, compatibility, parsing ownership |
| `boundary-lens.md` | abstraction reuse, module seams, placement, dependency direction, ownership |
| `state-lens.md` | source of truth, migrations, derived-field drift, transitions, hidden states |
| `runtime-lens.md` | transactions, retries, concurrency, observability, infra semantics, rollout safety |
| `user-experience-lens.md` | UI behavior, copy, i18n structure, nearby docs, visible states |
| `verification-lens.md` | weak proof, thin assertions, missing integration or round-trip validation |

If a change crosses surfaces, load multiple lenses. Do not load all lenses by default.

## Scope Control

- Do not ask for adjacent cleanup unless it materially reduces the current risk.
- Prefer a focused follow-up when the current change can land safely without widening scope.
- Flag untracked follow-up work when safety depends on it.
- Push back on broad PRs when the size itself makes meaningful review or rollback harder.

## Severity

- **critical**: likely production breakage, data corruption, broken compatibility, unsafe rollout, or contract failure across systems
- **warning**: meaningful correctness, maintainability, runtime, or user-facing issue that should be fixed before merge
- **info**: worthwhile improvement or follow-up, but not a merge blocker

Raise severity by blast radius and reversibility, not by diff size.
Raise severity when the intermediate deploy state is unsafe, even if the final end state looks correct.

## Do Not Flag

- formatting or lint churn already handled by tooling
- stylistic preferences with no correctness or maintenance impact
- speculative future abstractions not needed by the current change
- cleanup that is safely deferrable and does not materially reduce current risk

## Review Order

1. Identify what can break.
2. Read the local docs that define intended behavior.
3. Load the matching lenses.
4. Check the highest-risk paths first.
5. Check whether the intermediate rollout state is safe across repos, pods, jobs, or clients.
6. Check whether rollback and diagnosis will be fast if the change fails.
7. Cite evidence from the diff, local docs, or existing code patterns.
8. Keep feedback terse, specific, and actionable.

## Decomposition

If review work is split across sub-agents, split by lens. Merge findings by severity first, then by blast radius.
