## Self-Review Analysis

Step-by-step procedure for reviewing your own changes before requesting peer review.

### 1. Gather The Diff

Collect all changes that will be part of the PR:

```bash
# See what's changed
git diff --stat HEAD~N  # or against the base branch
git diff --name-only <base-branch>...HEAD
```

Read every changed file. The diff shows what changed; you need to understand what each change touches and what depends on it.

### 2. Scope Check

For each changed file, answer: does this change relate directly to the task intent?

**Flag these:**

- Files that "came along for the ride" (unrelated formatting, import reordering, accidental saves)
- Changes that started as part of the task but grew beyond the original scope
- Refactoring mixed with feature work (split into separate PRs when possible)

If a file does not belong, remove it from the changeset. Scope drift is the most common source of hidden blast radius.

### 3. Risk Assessment

Classify the overall change risk. Read `~/.spoke-knowledge/content/engineering/_reference/change-risk-assessment.md` for the full risk signal reference.

Check each of these:

**Blast radius indicators:**

- Does the change touch shared state, core abstractions, or foundational components (layouts, navigation, overlays, base hooks)?
- Does it span multiple repositories or require coordinated deploys?
- Does it modify data models, migrations, or indexing?
- Does it add or update dependencies?
- How many flows pass through the changed code paths? Trace callers, not just the diff.

**Rollback assessment:**

- Can this be reverted cleanly with a single revert commit?
- Does the change involve data migrations or schema changes that cannot be reversed?
- Are there cross-repo dependencies that complicate rollback?

**Production-vs-local gap:**

- Are there data scale differences that could surface issues only in production?
- Are there service configuration or secret differences between environments?
- Does the change depend on infrastructure behavior (pub/sub ordering, trigger timing, queue capacity)?

Summarize the risk level and state what specifically makes it higher or lower risk.

### 4. Convention Scan

Check for pattern violations and quality issues. Load `spoke-knowledge` to look up relevant convention docs for the repository's domain.

**Repository conventions:**

- Read the repo's `AGENTS.md` for local patterns and known gotchas
- Check if modified code follows the established patterns in the surrounding files
- Look for reinvented abstractions: does a shared hook, helper, factory, or selector already exist for what the new code does?

**AI-generated code signals** (apply extra scrutiny when the changes were AI-generated):

- Are existing abstractions used, or were equivalent implementations created from scratch?
- Does the code use proper types, or does it lean on `as any`, loose generics, or type assertions?
- Is the implementation appropriately simple, or does it add complexity that the problem does not require?
- Does it follow the file's existing style and the repo's conventions, or does it introduce a new pattern?

**High-frequency misses** (common patterns that reviewers flag):

- Firestore queries that would benefit from projection or bounds (check the decision framework in `firestore-patterns.md` § Query Performance Patterns)
- App code importing raw Firestore SDK when `firestore-kit` already wraps the needed API (some raw imports are valid; check whether a wrapper exists first)
- Error responses with message strings but no stable error code
- Page-level data fetched outside the page-bundle pattern in web-apps
- Tests using hardcoded doc IDs or hand-built fixtures when `buildTest*()` factories and ref selectors exist for that model
- New Firestore models without matching ref selectors or schema factories
- Missing error handling on paths that can fail in production
- Test coverage gaps for changed behavior
- Stale comments or documentation that the change invalidates

### 5. Merge Readiness

Verify the change is ready for someone else to review:

- [ ] Tests pass locally (or in CI if available)
- [ ] Type checks pass with no new errors or suppressions
- [ ] Linter/formatter clean (no unrelated formatting changes)
- [ ] No debug code, console logs, or temporary workarounds left in
- [ ] PR description explains intent and non-obvious decisions
- [ ] Context comments added on the PR for areas that need reviewer attention
- [ ] Dependent changes in other repos are merged or coordinated
- [ ] Rollback strategy identified for higher-risk changes
- [ ] Feature flag or rollout plan identified if the change warrants gradual exposure

### 6. Report

Present findings organized by severity:

**MUST** — Blocking issues that should be fixed before requesting review. Incorrect behavior, missing error handling on critical paths, scope drift that changes the blast radius, broken tests.

**SHOULD** — Issues that a reviewer will likely flag. Convention violations, missing tests for changed behavior, unclear code that needs comments, suboptimal patterns that increase maintenance burden.

**CONSIDER** — Non-blocking suggestions. Alternative approaches, minor simplifications, documentation improvements.

For each finding, include:

- The specific file and line range
- What the issue is
- Why it matters (consequence, not just rule citation)
- A suggested fix when the path forward is clear

End with a summary: overall risk level, number of findings by severity, and whether the change is ready for peer review or needs further work first.
