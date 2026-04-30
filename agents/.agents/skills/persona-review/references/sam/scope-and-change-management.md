# Scope and Change Management

Keep the PR focused, defer adjacent cleanup when it is safe to defer, and coordinate related changes tightly when a direct swap is acceptable. Sam often uses review comments to protect mergeability as much as code quality.

## Scope Control

**What to look for:**

- Adjacent cleanup bundled into a feature PR without being necessary for correctness.
- Design discussions that would significantly widen the change even though the current PR can land safely without them.
- Follow-up work identified but not tracked.

**Severity:** Info when a follow-up PR or ticket is the better path. Warning when scope expansion is blocking a safe, focused change.

**Corpus examples:**

- _"Yeah I'll create a ticket for it, just seemed better in its own PR"_ (backend-services #3292)
- _"I don't want to increase the scope now to remove it"_ (domain #1243)

## Coordinated Changes

**What to look for:**

- Paired schema and consumer changes that are intended to merge together.
- Rollout plans that rely on timing but have not been made explicit in the PR description.
- Narrow-scope migrations where a direct swap is acceptable because the usage set is tiny and known.

**Severity:** Warning when coordinated merge assumptions are implicit or brittle. Info when the reviewer is explicitly choosing a low-overhead coordinated rollout.

**Corpus examples:**

- _"I won't merge this until the corresponding engine PR is ready to be merged in, and then we effectively merge them both within a couple minutes of each other"_ (domain #1219)

## Anti-Patterns

1. **Unnecessary scope expansion** - Folding unrelated cleanup into a focused behavior change.
2. **Untracked follow-up work** - Deferring cleanup without a clear next step.
3. **Implicit coordinated rollout** - Depending on near-simultaneous merges without documenting that dependency.
