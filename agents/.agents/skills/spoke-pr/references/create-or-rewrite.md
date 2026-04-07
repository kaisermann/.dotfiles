## Create Or Rewrite A PR

### Before writing

1. No uncommitted changes — commit or amend before writing the PR body
2. On the right branch — create a task branch from main if still on main (use `pro-12345-description` for Linear-linked work, a descriptive slug otherwise)
3. Pushed to remote
4. Full diff reviewed against the target branch — the PR body describes this diff, not the session history
5. Check for a `.github/pull_request_template.md` — if it exists, follow its structure and leave placeholders for sections the agent cannot fill (screenshots, Loom links, etc.)

### Title

- Treat the title as a likely squash-merge commit message.
- Make it specific and accurate.
- Reflect user-facing or architectural intent, not a file list.
- If the repo uses ticket-prefixed titles, keep that convention.
- Use draft status instead of `WIP` in the title.

### Body

Write the body as prose — paragraphs and bullets, not a form. The default is the shortest body that makes review easy. Many PRs need only a title and a sentence or two. Larger PRs need more, but still prose, not boilerplate sections.

What belongs in a PR body:

- **Why** the change exists — the one thing the diff cannot show.
- Non-obvious behavior, contract changes, or gotchas a reviewer would miss.
- Links to related PRs, RFCs, Twist threads, Linear tickets — inline where relevant, not in a dedicated section.
- Screenshots, Looms, or demo links when the visual impact matters — use placeholders when unavailable.
- Testing notes when the test approach is non-obvious.
- Deferred work named directly, not hidden.
- Stack or cross-repo context when the PR is part of a sequence.

What does **not** belong:

- Sections for the sake of sections. No empty `## Testing` or `## Not in scope`.
- File-by-file narration restating the diff.
- Anything the diff already makes obvious.

Use `## Summary` when the body is long enough to benefit from a heading. Skip it when the body is short — just write.

Add `Closes PRO-12345` when a Linear ticket exists.

### Calibrating length

A one-line fix gets a one-line body (or none). A multi-concept refactor gets a few paragraphs explaining the shape. A cross-repo rollout gets related PR links, deploy ordering, and migration notes. Match the body to the complexity of the change — not to a template.

### Bad and good examples

**Bad — boilerplate form on a simple change:**

```markdown
## Summary
Fixes the auth redirect issue when opening route links in background tabs.

## How to review
Look at the auth store changes.

## Testing
Open a route link in a background tab and verify no redirect to /stops.

## Not in scope
Other auth issues.
```

**Good — same change, prose:**

```markdown
Opening a route link in a background tab could briefly resolve auth readiness
before the user state subscription was active, which made the app think the
user was signed out and redirect to /stops. This change makes readiness and
current user come from the same eagerly-created auth store, so they stay in
sync and the redirect no longer happens.

Closes PRO-19688
```

**Bad — section padding on a docs PR:**

```markdown
## Summary
Adds AGENTS.md conventions for page bundles, engineClient, Firestore hooks,
and i18n.

## What changed
- Added page bundle pattern section
- Added getEngineClient section
- Added @local/hooks section
- Added i18n defineMessages section

## Testing
N/A
```

**Good — same change, explains the why:**

```markdown
## What

Expands `AGENTS.md` with four additional conventions that agents (and
engineers) often miss:

- **Page bundle pattern**: pages define their own typed bundle items and are
  self-contained — no cross-page bundle imports
- **`getEngineClient()` for all API calls**: all Engine API calls go through
  the function accessor, never raw fetch
- **`@local/hooks` over raw Firestore**: directs toward `useWatchDocument`
  etc. instead of calling `watchDocument` from `firestore-kit` directly
- **i18n `defineMessages()`**: all user-facing strings declared at module
  level via `defineMessages()` from `@getcircuit/intl-tools`

These were gaps identified while reviewing recent PRs.
```

### Final pass

- Self-review before requesting review.
- Check that the title and body still match the branch contents.
- If the PR should be split, split it before polishing the writeup.
