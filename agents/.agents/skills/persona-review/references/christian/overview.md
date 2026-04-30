# Review Profile: kaisermann — Overview

Core identity and calibration for an automated reviewer agent that mirrors Christian Kaisermann's code review attention patterns across Spoke repositories.

Distilled from ~424 reviewed PRs (inline comment corpus across `domain`, `web-packages`, `backend-services`, `web-apps` in three passes: 24-PR deep sample, 100-PR expansion, 300-PR expansion), ~400 authored PRs, and the Spoke engineering convention documentation that kaisermann primarily authored.

This profile describes _what to pay attention to and why_, not a persona to imitate. Use it to decide what is worth flagging, at what severity, and with what kind of suggestion.

## Domain Documents

Load the overview for every review. Load domain docs selectively based on what the diff touches:

| Document | Load when the diff contains... |
|---|---|
| `patterns-and-abstractions.md` | Any new code that might duplicate existing shared utilities, hooks, or factories |
| `naming-types-api.md` | New type definitions, function signatures, exports, file additions |
| `structure-and-scope.md` | File moves, new directories, cross-package imports, barrel files |
| `data-and-firestore.md` | Firestore queries, document reads/writes, data model changes, SDK imports |
| `frontend-patterns.md` | React components, hooks, Svelte files, CSS, effects, callbacks |
| `test-and-quality.md` | Test files, mock setup, error handling, logging, code comments |

## Attention Model

Kaisermann's reviews are shaped by a small set of strong convictions applied proportionally to risk and change size.

The core questions behind most review comments:

1. **Does something already exist for this?** Reinvention of shared abstractions is the most common class of issue.
2. **Is this named precisely enough?** Generic names erode codebase navigability over time.
3. **Does this live where it should?** Misplaced code creates coupling and makes ownership unclear. Import direction violations are structural bugs.
4. **Is the data representation correct?** Wrong types, wrong field colocation, wrong Firestore access patterns.
5. **Will someone reading this later understand why?** Missing comments on non-obvious decisions, stripped documentation, unclear intent.
6. **Does this need to exist at all?** Unnecessary hooks, wrappers, abstractions, and indirection are questioned before their implementation is reviewed.
7. **Does this receive/pass only what it needs?** Functions, hooks, and components that accept or spread entire objects when they only use 2-3 fields.

When a PR is clean on all seven, approve quickly. When it isn't, expect 15-20 inline comments on a single PR, each focused and actionable.

## Feedback Calibration

### Severity Mapping

| Agent severity | Kaisermann equivalent | Examples |
|---|---|---|
| **critical** | Blocking — must fix before merge | Incorrect Firestore access pattern that will fail in production, SDK boundary violation, data loss risk |
| **warning** | Should fix — reviewer will likely flag | Reinvented abstraction, generic naming, misplaced code, missing test factories, unnecessary type casts |
| **info** | Consider — non-blocking improvement | Minor naming tweaks, memoization questions, comment suggestions, simplification opportunities |

### What NOT to Flag

- Style preferences already enforced by linters/formatters (spacing, semicolons, import order).
- Correct code that follows established patterns, even if an alternative approach exists.
- One-line changes that are obviously correct — approve quickly, don't find something to say.
- Test structure that is explicit even if verbose — verbosity is preferred over hidden defaults.

## Review Depth Scaling

Review depth scales with risk and complexity, not with diff size.

| PR type | Expected depth |
|---|---|
| Simple rename, typo fix, config bump | Quick scan, fast approval. |
| New feature in a single module | Moderate depth. Check naming, abstractions, test coverage, colocation. |
| Cross-package or cross-repo change | Deep review. Check SDK boundaries, entrypoint design, package scope, blast radius. |
| Firestore model/field addition | Deep review. Check data representation, source-of-truth placement, query patterns, migration needs. |
| Infrastructure/CI/tooling | Moderate depth. Check for redundancy, scope creep, environment safety. |
| Large PR (>500 lines) | Deep review with proportionally more comments. Large PRs get thorough scrutiny, not a pass because they're big. |

## Convention Anchors

These Spoke convention documents are the primary reference for the patterns this profile enforces. Load relevant docs when reviewing PRs in the corresponding domain.

| Convention doc | Supports |
|---|---|
| `code-review-practices.md` | Review workflow, AI-generated code scrutiny, PR size expectations |
| `testing-guidelines.md` | Test factories, explicit inputs, integration vs unit test level |
| `common-engineering-gotchas.md` | Firestore edge cases, TypeScript traps, silent failures |
| `firestore-patterns.md` | SDK boundaries, query constructors, refSelectors, construction rules |
| `firestore-models-and-fields.md` | Data representation, source-of-truth placement, cross-repo rollout |
| `technical-debt-approach.md` | TODO tracking with Linear tickets, opportunistic cleanup |
| `logging-and-instrumentation-guidelines.md` | Static log messages, structured metadata, error logging |
| `code-organization.md` | Colocation, domain-first grouping, promotion/demotion rules |
| `naming-conventions.md` | Function naming, path aliases, `#` prefix convention |
| `change-risk-assessment.md` | Blast radius patterns, merge safety heuristics |

## Decomposition Guidance

When splitting review work into sub-agents, use these groupings. Each maps to a domain document:

1. **Patterns and Abstractions** (`patterns-and-abstractions.md`) — Highest-signal dimension. Benefits from codebase-aware search.
2. **Naming, Types, and API Design** (`naming-types-api.md`) — Largely self-contained from the diff.
3. **Structure and Scope** (`structure-and-scope.md`) — Requires understanding the repo's module hierarchy.
4. **Data and Firestore** (`data-and-firestore.md`) — Highly specialized. Benefits from loaded convention docs.
5. **Frontend Patterns** (`frontend-patterns.md`) — React/Svelte-specific review patterns.
6. **Test and Quality** (`test-and-quality.md`) — Spans both test files and production code.

### Mapping to Current Sub-Agents

| Existing agent | Absorbs these dimensions |
|---|---|
| **security** | Keep as-is. Kaisermann's reviews don't focus heavily on security. |
| **architecture** | Patterns and Abstractions + Structure and Scope + Data and Firestore. Highest-value agent. |
| **style** | Naming, Types, and API Design + Frontend Patterns + Test and Quality + i18n. |
| **history** | Could become the codebase-aware search agent that checks whether abstractions already exist and validates colocation claims against the actual file tree. |
