## Create Or Rewrite A PR

### Before writing

1. No uncommitted changes. Commit before writing the PR body.
2. On the right branch. Create a task branch from main if still on main (use `pro-12345-description` for Linear-linked work, a descriptive slug otherwise)
3. Explicitly check validation expectations before opening: tests, type-check, changeset, and whether the branch is already pushed. Do not open the PR first and discover these afterward.
4. Pushed to remote
5. Full diff reviewed against the target branch. The PR body describes this diff, not the session history.
6. Check for a `.github/pull_request_template.md`. If it exists, follow its structure and leave placeholders for sections the agent cannot fill (screenshots, Loom links, etc.)

### Title

- Treat the title as a likely squash-merge commit message.
- Make it specific and accurate.
- Reflect user-facing or architectural intent, not a file list.
- If the repo uses ticket-prefixed titles, keep that convention.
- Use draft status instead of `WIP` in the title.

### Body

When a PR template exists, use its section structure. Write prose within each section. Do not add sub-forms, bold-keyword lists, or extra headings beyond what the template defines.

When no template exists, write the body as prose: paragraphs and bullets, not a form. The default is the shortest body that makes review easy. Many PRs need only a title and a sentence or two. Larger PRs need more, but still prose, not boilerplate sections. Use `## Summary` only when the body is long enough to benefit from a heading.

Focus the body on:

- Why the change exists. This is the one thing the diff cannot show.
- Non-obvious behavior, contract changes, or gotchas a reviewer would miss.
- Links to related PRs, RFCs, Twist threads, Linear tickets, inline where relevant, not in a dedicated section.
- Screenshots, Looms, or demo links when the visual impact matters. Use placeholders when unavailable.
- Testing notes when the test approach is non-obvious.
- Deferred work named directly, not hidden.
- Stack or cross-repo context when the PR is part of a sequence.
- Why a broader refactor was worth it, when the PR is mechanically larger than the feature it unlocks.

Do not:

- Add sections for the sake of sections. No empty `## Testing` or `## Not in scope`.
- Narrate the diff file-by-file or bullet-by-bullet. If the diff already shows it, the body should not repeat it.
- Describe what changed without explaining why. "Exports `catchError`" is diff narration; "replaces `onError` because solid-js v2 removes it" is context.
- Anything the diff already makes obvious.
- Routine test commands that CI already runs. Only include a test command when the approach is non-obvious or the exact invocation matters for review.
- Bare pass/fail status claims like "All tests pass" or "Checks pass." A PR being opened implies it works. If something does not pass, or the validation approach is non-obvious, explain that instead.
- Agent session artifacts: environment limitations, missing local dependencies, tools that could not run, worktree state, or verification caveats that exist only because of how the agent executed. The PR describes the change, not the agent's working conditions.
- One-line summaries for multi-concept refactors that still leave the reviewer to infer the actual shape of the change.

Add `Closes PRO-12345` when a Linear ticket exists.

### Writing shape

For non-trivial PRs, the default structure is:

1. Open with the problem, constraint, or behavior that made the change necessary.
2. Explain the shape of the fix in one short paragraph: what moved, what now gets computed earlier, or what responsibility changed hands.
3. Name the 1-3 consequences a reviewer would care about: behavior changes, rollout concerns, or why the refactor scope is larger than the feature request.
4. End with deferred work, stack context, or `Closes PRO-12345` when relevant.

Do not force all four parts into every PR. Use them when the diff needs a map.

### Style guardrails

- Start with the substance. Skip openers like `This PR`, `The goal of this PR`, or `Key changes include` unless the sentence genuinely needs the subject.
- State the point directly. Avoid binary contrasts like `not X, Y` or `not because X. because Y.`
- Avoid rhetorical setups like `What changed?`, `The result?`, or `Why does this matter?`
- Avoid dramatic fragments. Write complete sentences.
- Avoid filler transitions like `Importantly`, `Notably`, or `It's worth noting`.
- Avoid bold-first bullets as a house style for PR bodies.
- Avoid em dashes. Use a period, comma, colon, or parentheses instead.

### Calibrating length

A one-line fix gets a one-line body (or none). A multi-concept refactor gets a few paragraphs explaining the shape. A cross-repo rollout gets related PR links, deploy ordering, and migration notes. Match the body to the complexity of the change, not to a template.

### Bad and good examples

**Bad: boilerplate form on a simple change**

```markdown
## Summary
Fixes the auth redirect issue when opening route links in background tabs.

## How to review
Look at the auth store changes.

## Not in scope
Other auth issues.
```

**Good: same change, prose**

```markdown
## Summary

Opening a route link in a background tab could briefly resolve auth readiness
before the user state subscription was active, which made the app think the
user was signed out and redirect to /stops. This change makes readiness and
current user come from the same eagerly-created auth store, so they stay in
sync and the redirect no longer happens.

Closes PRO-19688

## How to Test

Open a route link in a background tab. Verify the page loads without
redirecting to /stops.
```

**Bad: technically correct but under-explained large refactor**

```markdown
The engine notification pipeline now supports service-level notification
overrides.

Closes PRO-19784
```

**Good: same change, explains the constraint and the refactor shape**

```markdown
The notification pipeline couldn't support service-level overrides because
scheduling, dispatching, and channel selection each fetched team preferences
internally. Adding the resolver on top of that would have turned every new
override into a cross-cutting change.

This rewires the flow so callers resolve notification settings once, then pass
the result down. `scheduleNotification` now receives pre-computed
`activeChannels`, `getNextAllowedTimePerChannel` takes the timezone and
allowed-period instead of fetching them, and `notifyRecipientsOut` batches
service lookups per unique service.

Closes PRO-19784
```

### Final pass

- Self-review before requesting review.
- Check that the title and body still match the branch contents.
- If the PR should be split, split it before polishing the writeup.
