---
name: spoke-pr
description: Pull request workflow for Spoke. Use before creating or editing a PR, and for drafting, rewriting, reviewing for merge risk, or addressing review feedback.
---

Use `spoke-knowledge`, `spoke-linear`, `spoke-figma`, or `spoke-ask` only when the task needs them.

## Modes

### Create or rewrite a PR

**For non-engineer roles (designers, PMs, support):** Before creating or rewriting a PR, load and run `spoke-change-review` first. If it reports any MUST-level findings, resolve them before proceeding. This catches scope drift, convention violations, and architectural issues before consuming reviewer time.

Read `references/create-or-rewrite.md`. Read `references/pr-heuristics.md` before drafting when deciding what PR shape fits the change and how much context is enough. Read `references/examples.md` only when you need real PR examples to calibrate tone or structure.

For large refactors, verify the old model in the target branch and lead with the reviewer-relevant constraint, not project history.

### Update an existing PR

- Refresh only the parts that became stale.
- If the change materially altered scope, testing, or rollout, update the PR body before asking for more review.
- If the branch changed the reviewer story, refresh the body shape too, not just the facts.
- After review has started, prefer additive commits over history rewrites that make re-review harder.
- For substantial rewrites, move the PR back to draft.
- If new commits changed what the reviewer should focus on, leave a short delta comment.

### Review a PR

- Read the title and body before diving into the diff.
- If a large PR lacks context, ask for it early.
- Review for: correctness and regressions, scope and reviewability, testing quality, rollout or migration safety, cross-repo coordination and merge order, design fidelity for UI work, missing context that blocks confident review.
- Separate blockers from suggestions. Block on correctness, important risk, fragility, or not-being-ready-to-merge.
- Do not turn taste or minor nits into blockers.
- Say what you did not review when coverage was partial.

### Address review feedback

Read `references/address-feedback.md`.

## Cross-mode defaults

- Spoke is async-first. A PR body is often the only explanation a reviewer gets. Treat it as a message, not a form to fill out.
- PRs start as draft. The developer moves to ready for review manually.
- Add `Closes PRO-12345` in the PR body for Linear integration when a ticket exists.
- Use the repository's docs, `AGENTS.md`, and PR template for local requirements.
- Use placeholders for links or artifacts the agent cannot fetch.
- Do not assume tool access to Loom, Linear, Figma, or other external systems.
- Ignore bot comments, copilot/agent boilerplate, and automated PRs when inferring good Spoke practice.
- Do not post comments, replies, or review submissions on GitHub unless the user explicitly asks. The agent makes code changes; the user decides what to say to reviewers.
