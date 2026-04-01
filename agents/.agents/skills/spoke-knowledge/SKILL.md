---
name: spoke-knowledge
description: Spoke background knowledge — domain, architecture, repo structure, conventions. What a tenured engineer knows without having to infer.
when_to_use: Need Spoke context beyond the current repo: business rules, data models, Firestore, org processes, boundaries.
---

# Spoke Knowledge Base

The Spoke Knowledge Base lives at `~/.spoke-knowledge/` and contains durable Spoke context organized into scopes.

Use this as the single knowledge base consumption skill.

## Freshness Protocol (Once Per Session)

Run this check **once per session**, not on every skill load. If you've already done it in this conversation, skip it.

```bash
branch=$(git -C ~/.spoke-knowledge rev-parse --abbrev-ref HEAD)
```

- **If on `main`:** pull latest and proceed.
  ```bash
  git -C ~/.spoke-knowledge pull --ff-only origin main
  ```
- **If on any other branch:** switch to main and pull. Tell the user the knowledge base was on branch `{branch}` and you've switched back.
  ```bash
  git -C ~/.spoke-knowledge checkout main && git -C ~/.spoke-knowledge pull --ff-only origin main
  ```

## When To Use The Knowledge Base

Use the knowledge base when the task depends on:

- company, org, or process context
- business or product behavior
- cross-repo engineering patterns or architecture
- repo conventions that may already be documented centrally

Do not use it as a default corpus. Start with repo-local `AGENTS.md`, source code, and local docs for repo-specific implementation details.

## Read Strategy

Read the smallest useful thing first:

1. Load this skill.
2. Use the decision tree below to pick a starting doc.
3. Read that scope's `_index.md` first when it exists.
4. Read only the specific deep docs needed for the task.

Treat each `_index.md` as the distilled entrypoint for that scope.

## Find the Right Doc

Pick the first match. All paths relative to `~/.spoke-knowledge/scopes/`.

- Which repo owns this work? → `engineering/repository-catalog.md`
- Monorepo boundaries or package placement? → `engineering/multi-monorepo-architecture.md`
- Firestore access, construction rules, or gotchas? → `engineering/firestore-patterns.md`
- Firestore indexes (add/remove/cleanup)? → `engineering/firestore-index-patterns.md`
- Reactive Firestore / subscription / loading design? → `engineering/firestore-reactive-architecture.md`
- Data migration or backfill? → `engineering/migration-patterns.md`
- Trigger / Pub/Sub / event pipeline? → `engineering/trigger-patterns.md`
- Test philosophy, test structure, or running tests in monorepos? → `engineering/testing-guidelines.md`
- Entity relationships, collection paths, or model construction? → `business/data-models.md`
- Product boundaries, naming, or portfolio questions? → `business/product-overview.md`
- Public API compatibility or export contracts? → `business/public-api-design-rules.md`
- "Circuit" vs "Spoke" naming confusion? → `company/brand.md`
- How Spoke teams work, async norms, or ownership model? → `company/how-we-work.md`
- Project execution, states, or shared context expectations? → `company/projects-framework.md`
- Active incident, alert triage, or pod restarts? → `operations/incident-response.md` + `operations/runbooks/k8s-alert-triage.md`
- AGENTS.md structure, spec, or review? → `engineering/agents-md-spec.md`
- Internal tools? → `operations/internal-tools.md`
- Repo-specific implementation guide (endpoints, deploy, testing setup)? → Not in knowledge base. Check `{repo}/docs/` and `{repo}/AGENTS.md` first
- Something else? → Read the relevant scope `_index.md`, then the specific doc

## Scopes

| Scope | Start here | Use when |
|---|---|---|
| **Company** | `scopes/company/_index.md` | naming, branding, org context |
| **Business** | `scopes/business/_index.md` | domain logic, data models, product rules |
| **Engineering** | `scopes/engineering/_index.md` | architecture, Firestore, triggers, migrations, repo catalog |
| **Operations** | `scopes/operations/_index.md` | incident, deploy, infra, or operational tasks only |

## Guardrails

- **Run the freshness protocol once per session** — see above. Do not repeat on every skill load.
- **Read distilled docs first** — prefer `_index.md` before deep files to keep context tight.
- **Never inject operations scope into general coding contexts**.
- **Respect `confidence` levels** in document frontmatter: skip `deprecated`, hedge on `low`, trust `high`
- **Check `last_verified` dates** — warn the user if a document hasn't been verified in 90+ days
- **If you discover something wrong or missing**, load the `spoke-kb-update` skill to propose a PR
- **The knowledge base supplements local repo docs** — it does not replace them
