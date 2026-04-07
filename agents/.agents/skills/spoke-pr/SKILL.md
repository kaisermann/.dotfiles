---
name: spoke-pr
description: Write, update, review, and address feedback on Spoke pull requests. Use when drafting a PR, refreshing stale PR context, reviewing for merge risk, or working through review comments and requested changes.
---

Use this for PR authoring, review, and feedback tasks that need Spoke-specific guidance.

Use `spoke-knowledge`, `spoke-linear`, `spoke-figma`, or `spoke-ask` only when the task needs them.

## When To Use

- writing a new PR title or body
- rewriting a PR after the branch changed
- reviewing a PR for merge risk, reviewability, or missing context
- addressing review comments, requested changes, or questions on a PR

## Modes

- Create or rewrite a PR: read `references/create-or-rewrite.md`
- Update an existing PR after changes: read `references/update.md`
- Review a PR: read `references/review.md`
- Address review feedback: read `references/address-feedback.md`

Read `references/pr-heuristics.md` when deciding how much context is enough.

## Shared defaults

- PRs start as draft — the developer moves to ready for review manually.
- Add `Closes PRO-12345` in the PR body for Linear integration when a ticket exists.
- Keep titles and bodies concise and objective.
- If the diff already tells the story, keep the body short.
- Use placeholders for links or artifacts the agent cannot fetch.
- Use the repository's docs, `AGENTS.md`, and PR template for local requirements.

## Guardrails

- When a repo has a PR template, follow its section structure. Write prose within each section. Do not invent extra headings beyond what the template defines, and do not suppress template sections in favor of free-form prose.
- When no template exists, do not generate section headers like `## How to review`, `## Testing`, `## Not in scope`, or `## Artifacts` unless the PR is complex enough that a heading genuinely helps navigation. Most PRs need zero or one heading.
- Do not narrate the diff. If the change is visible in the code, the body should explain why it was made, not restate what it does.
- Ignore bot comments, copilot/agent boilerplate, and automated PRs when inferring good Spoke practice.
- Do not assume tool access to Loom, Linear, Figma, or other external systems; use placeholders when a human needs to supply links.
- Do not force a markdown-heavy body onto a simple PR.
- Do not hide deferred work; name it directly.
- Do not make reviewers reconstruct stack structure, rollout order, or testing intent from the diff alone.
- Do not post comments, replies, or review submissions on GitHub unless the user explicitly asks. The agent makes code changes; the user decides what to say to reviewers.
