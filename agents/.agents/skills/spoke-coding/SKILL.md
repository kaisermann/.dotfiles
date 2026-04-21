---
name: spoke-coding
description: Spoke engineering conventions for implementation work including coding, testing, technical debt, design handoffs, and repo orientation. Use when actively building or reviewing code and you need developer guidance with platform guardrails.
---

Implementation-focused Spoke engineering guidance from the Knowledge Base (`~/.spoke-knowledge/`).

Use `spoke-knowledge` for broader company, product, design, or architecture context when the task is not primarily about implementation. Use `spoke-pr`, `spoke-linear`, `spoke-figma`, or `spoke-ask` only when the task needs those workflows.

## Workflow

1. Start with the repository's `AGENTS.md`, nearby code, and local `docs/`. Use this skill for shared engineering defaults, not repo-local implementation detail.
2. Match the task to a shortcut below. If none match, start from `content/engineering/_index.md` or `content/engineering/web/_index.md`.
3. Read only the docs needed for the current implementation slice.

## Doc shortcuts

### Getting Oriented

- Starting in an unfamiliar repo or deciding which repo owns the change?: `content/engineering/_reference/repository-catalog.md`
- Web monorepo conventions, package placement, or frontend repo structure?: `content/engineering/web/_index.md`
- Cross-repo architecture or package boundary questions?: `content/engineering/_explanation/multi-monorepo-architecture.md`
- Model shapes, collection paths, or construction rules?: `content/engineering/_reference/data-models.md`
- Mobile vs web platform boundaries or platform-specific rules?: `content/engineering/_explanation/mobile-web-platform-split.md`

### Coding And Validation

- Test structure, explicit inputs, or mock boundaries?: `content/engineering/_reference/testing-guidelines.md`
- Error handling, error codes, or structured error responses?: `content/engineering/_reference/error-handling-patterns.md`
- Logging, telemetry, product tracking, or instrumentation metadata?: `content/engineering/_reference/logging-and-instrumentation-guidelines.md`
- TODO or FIXME comments, deferred cleanup, or technical-debt follow-up in code?: `content/engineering/_reference/technical-debt-approach.md`
- Reviewability, PR size, or author and reviewer expectations?: `content/engineering/_reference/code-review-practices.md`
- Recurring pitfalls, environment gotchas, or hidden failure modes?: `content/engineering/_reference/common-engineering-gotchas.md`

### Data And Backend Seams

- Firestore access, construction rules, or emulator-backed testing?: `content/engineering/_reference/firestore-patterns.md`
- Firestore model fields, required shapes, or rollout concerns?: `content/engineering/_reference/firestore-models-and-fields.md`
- Reactive subscriptions or loading-state architecture?: `content/engineering/_explanation/firestore-reactive-architecture.md`
- Long-running workflows, retries, or operation models?: `content/engineering/_explanation/modeling-long-running-work.md`

### Design And Cross-Functional Implementation

- Handoff readiness or walkthrough expectations before build?: `content/design/_reference/design-handoff-workflow.md`
- Ambiguous or changing design handoff during implementation?: `content/engineering/_reference/working-with-design-handoffs.md`
- Project-level implementation contract or shared artifact rules?: `content/company/_reference/projects-framework.md`
- Who reviews implemented user-facing work before ship?: `content/company/_reference/user-facing-implementation-review-responsibilities.md`

### Related Workflow Skills

- Linear issue context or issue mutations?: use `spoke-linear`, and read `content/company/_reference/linear-ticket-conventions.md` before mutating tickets
- PR writing, review, or review feedback?: use `spoke-pr`
- Figma inspection or export?: use `spoke-figma`
- Historical context or prior decisions not captured in docs?: use `spoke-ask`

## Guardrails

- Shared knowledge-base docs are defaults for general engineering guidance. Repository `AGENTS.md`, local docs, and established code patterns win for repo-specific implementation.
- During refactors, pay attention to existing comments. Keep, move, or adapt comments that still apply after extraction, renaming, or file moves instead of dropping them as incidental text.
- Do not project web conventions onto iOS, Android, backend, or infra work without repo-local evidence.
- Do not pull in `content/engineering/infra/` docs unless the task is operational or runtime-debugging.
- Pull Linear, Figma, PR, or historical context only when the task actually needs those workflows.
