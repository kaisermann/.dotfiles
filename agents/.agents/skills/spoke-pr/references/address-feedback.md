## Address Review Feedback

Use this mode when a PR has received review comments, requested changes, or questions that need addressing.

### Gather feedback

Fetch all review activity for the PR. The user may provide a PR number, URL, or the agent may infer it from the current branch.

```bash
# Determine repo owner/name from git remote
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# Get PR number from current branch if not provided
PR=$(gh pr view --json number -q .number)

# Formal reviews (approved, changes_requested, commented)
gh api "repos/${REPO}/pulls/${PR}/reviews" --paginate

# Inline review comments (line-level feedback on the diff)
gh api "repos/${REPO}/pulls/${PR}/comments" --paginate

# General PR comments (conversation-level, not attached to code lines)
gh api "repos/${REPO}/issues/${PR}/comments" --paginate
```

Ignore bot comments, automated checks, and copilot-generated suggestions when building the feedback summary.

### Categorize

Group every piece of human feedback into one of these categories:

- **Blocker** — the reviewer explicitly requested changes or flagged correctness, regression risk, or fragility. These must be addressed before the PR can merge.
- **Question** — the reviewer asked something. Needs either a code change that answers it, a reply explaining the rationale, or both.
- **Suggestion** — the reviewer proposed an alternative approach or improvement. Worth considering; not necessarily required.
- **Nit** — cosmetic, stylistic, or minor preference. Address if easy; acknowledge if not.
- **Resolved** — already addressed in a subsequent commit, or the reviewer resolved the thread themselves. Skip these.

For inline comments, note the file path and line range so the agent can navigate directly to the relevant code.

### Present a summary

Before making changes, present the categorized feedback to the user as a compact list:

```
## PR #1234 — Review feedback

### Blockers (2)
1. [reviewer] src/components/Auth.tsx:45 — race condition in auth readiness check
2. [reviewer] src/hooks/useRoute.ts:12 — missing null guard on route.stops

### Questions (1)
3. [reviewer] general — why not use the existing useWatchDocument hook?

### Suggestions (1)
4. [reviewer] src/utils/format.ts:30 — consider extracting the formatter

### Nits (1)
5. [reviewer] src/components/Auth.tsx:78 — naming: prefer isReady over ready
```

Let the user confirm the plan, re-prioritize, or skip items before starting work.

### Address each item

Work through items in priority order: blockers first, then questions, suggestions, nits.

For each item:

1. **Read the comment in full** — understand what the reviewer is asking, not just the surface text. Check if there is a thread with follow-up context.
2. **Navigate to the code** — read the relevant file and surrounding context.
3. **Make the change** if the fix is clear and unambiguous. If the reviewer's suggestion conflicts with existing patterns or has tradeoffs, present the tradeoffs to the user and let them decide.
4. **Mark the item done** in your tracking.

Do not batch all changes into a single commit. Group related changes logically: one commit per reviewer concern or per cohesive set of changes is a reasonable default.

Do not post comments or replies on GitHub unless the user explicitly asks. The agent's job is to make the code changes; the user decides what to say to reviewers and when.

### After addressing feedback

- If the scope of the PR changed while addressing feedback, update the PR body to reflect the current state.
- Do not move the PR out of draft, merge, re-request review, or post comments unless the user asks.
- If addressing feedback revealed new issues unrelated to the review, note them but do not scope-creep the PR. File them separately or add a TODO comment.
