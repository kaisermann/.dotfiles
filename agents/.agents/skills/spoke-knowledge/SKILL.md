---
name: spoke-knowledge
description: Shared Spoke context across company, business, design, and engineering. Use when any task may benefit from Spoke-specific terminology, product rules, operating norms, architecture patterns, or conventions.
---

The Spoke Knowledge Base lives at `~/.spoke-knowledge/` and contains durable Spoke context organized into subject areas.

Use `spoke-ask` for historical context.

## Workflow

When the task involves coding, design, product decisions, ops, or may require background knowledge, guidelines, how-tos, or patterns:

1. **Match the question to a doc below.** Scan the shortcut list first — if a line matches, read that file directly.
2. **No shortcut match? Start from the area index.** Pick the area from the table, read its `_index.md`, then follow pointers to the specific doc.
3. **Read only what the task needs.** Don't bulk-read an area. Use frontmatter `description` to triage candidates.

Do not use the knowledge base as a default corpus. Start with the repository's `AGENTS.md`, source code, and local docs for repository-specific implementation details.

## Doc shortcuts

Pick the first match. Paths are relative to `content/` unless the shortcut explicitly points to `docs/`.

### Codebase and architecture

- Writing or reviewing code in a web-based monorepo? Read conventions first: `engineering/web/_index.md`
- Which repository owns this work?: `engineering/_reference/repository-catalog.md`
- Monorepo boundaries or package placement?: `engineering/_explanation/multi-monorepo-architecture.md`
- Entity relationships, collection paths, or model construction?: `engineering/_reference/data-models.md`
- Firestore model field contracts or common document shapes?: `engineering/_reference/firestore-models-and-fields.md`
- Data consistency, denormalization, or source-of-truth tradeoffs?: `engineering/_explanation/data-consistency-model.md`
- Mobile vs web platform boundaries or platform-specific rules?: `engineering/_explanation/mobile-web-platform-split.md`
- Optimization engine shape, solver stages, or solver dependencies?: `engineering/_explanation/optimization-engine-overview.md`

### Firestore

- Firestore access, construction rules, or gotchas?: `engineering/_reference/firestore-patterns.md`
- Firestore indexes (add/remove/cleanup)?: `engineering/_reference/firestore-index-patterns.md`
- Reactive Firestore / subscription / loading design?: `engineering/_explanation/firestore-reactive-architecture.md`
- Data migration or backfill?: `engineering/_reference/firestore-migration-patterns.md`
- Trigger / Pub/Sub / event pipeline?: `engineering/_reference/firestore-trigger-patterns.md`

### Infrastructure and ops

- Active incident, alert triage, or pod restarts?: `engineering/_how-to/incident-response.md` + `engineering/infra/_how-to/k8s-alert-triage.md`
- Did a backend deploy finish in CI but not seem live?: `engineering/infra/_how-to/deployment-verification-and-rollback.md`
- Staging not reflecting expected code after merge?: `engineering/infra/_how-to/staging-deployment-gotchas.md`
- Which observability tool to use first (logs vs metrics vs traces)?: `engineering/infra/_how-to/monitoring-investigation.md`
- Trigger side effect missing, deadletters growing?: `engineering/infra/_how-to/trigger-failure-investigation.md`
- Cloud Tasks delayed, retrying, or callback failures?: `engineering/infra/_how-to/cloud-tasks-triage.md`
- Local and deployed behavior differ (config, project, secret confusion)?: `engineering/infra/_how-to/config-and-service-account-debugging.md`
- Firestore and Elasticsearch results disagree?: `engineering/_how-to/search-and-index-discrepancy-investigation.md`
- Deploying a new infra application?: `engineering/infra/_how-to/infra-application-deployment.md`
- Deadletter queue accumulating or alert firing?: `engineering/infra/_how-to/deadletter-queue-triage.md`
- GCP project selection or production debugging navigation?: `engineering/infra/_how-to/gcp-debugging-navigation.md`

### Engineering patterns

- Data ownership, references, snapshots, or backend write seams?: `engineering/_explanation/choosing-where-data-lives.md`
- Gated rollout, entitlements, or downgrade behavior?: `engineering/_reference/rolling-out-gated-features.md`
- Long-running workflows, retries, or operation models?: `engineering/_explanation/modeling-long-running-work.md`
- Webhook event delivery or payload contracts?: `engineering/_reference/webhook-event-architecture.md`
- Test philosophy or test structure?: `engineering/_reference/testing-guidelines.md`
- Route or plan optimization failure investigation?: `engineering/_how-to/optimization-investigation.md`
- Code review expectations, PR sizing, or reviewer behavior?: `engineering/_reference/code-review-practices.md`
- Deploy surfaces, release paths, or how code reaches production?: `engineering/_reference/deploy-overview.md`
- Error classification, recovery patterns, or signal preservation?: `engineering/_reference/error-handling-patterns.md`

### Design

- Design handoff readiness or walkthrough expectations?: `design/_reference/design-handoff-workflow.md`
- Figma source of truth or exploratory vs canonical files?: `design/_reference/figma-organization-patterns.md`
- Design tokens or semantic color naming?: `design/_reference/design-token-conventions.md`
- Reviewing a design package before issue creation?: `design/_reference/design-package-audit.md`
- Reusable component intent or shared library updates?: `design/_reference/component-reuse-and-library-updates.md`
- Route Planner design principles or flow structure?: `design/route-planner/_reference/design-principles.md`
- Engineering-side rules for consuming design handoff?: `engineering/_reference/working-with-design-handoffs.md`

### Company and product

- Product boundaries, naming, or portfolio questions?: `business/_reference/product-overview.md`
- Product-development principles, scoping conventions, or tradeoffs?: `business/_reference/product-development-principles.md`
- "Circuit" vs "Spoke" naming confusion?: `company/_reference/brand.md`
- Need role definitions or role shapes across Spoke functions?: `company/roles/_index.md`
- How Spoke teams work, async norms, ownership, or operating conventions?: `company/_reference/how-we-work.md`
- Project execution, states, or shared context?: `company/_reference/projects-framework.md`
- Which official tool for a job or workflow?: `company/_reference/tooling.md`
- Linear ticket format, issue structure, or label conventions?: `company/_reference/linear-ticket-conventions.md`
- Localization flow, translations, or Crowdin?: `company/_reference/localization-workflow.md`
- Support escalation or launch readiness?: `company/support/_index.md`
- Need to adapt agent behavior for the user's role?: Read the matching file from `briefings/`

### Agent and skill configuration

- Agent configuration, skills layout, or tool setup?: `engineering/_reference/agent-configuration.md`
- Repo instruction file structure or spec?: `engineering/_reference/agent-instruction-file-spec.md`
- Internal tools (Ask Spoke, Linear, Figma access)?: `company/_reference/internal-tools.md`

### Not in the knowledge base

- Repository-specific implementation (endpoints, deploy, testing setup)?: Check `{repo}/docs/` and `{repo}/AGENTS.md` first
- Historical context or prior decisions?: Load the `spoke-ask` skill

## Areas

| Area | Index | Scope |
|---|---|---|
| **Company** | `content/company/_index.md` | naming, roles, operating conventions, workflows, Linear, localization, tooling |
| **Business** | `content/business/_index.md` | product rules, domain models, portfolio boundaries, product-development conventions |
| **Design** | `content/design/_index.md` | handoff, Figma, design systems, tokens, design conventions |
| **Engineering** | `content/engineering/_index.md` | architecture, conventions, Firestore, deployment, testing, data models, runtime ops, repo boundaries |

## Guardrails

- **Read `_index.md` before deep files** to keep context tight.
- **Do not inject `engineering/infra/` into general coding contexts unless the task is operational.**
- **The knowledge base supplements repository docs** — it does not replace them.
