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

When a PR template exists, use its section structure. Write prose within each section — do not add sub-forms, bold-keyword lists, or extra headings beyond what the template defines.

When no template exists, the default is the shortest body that makes review easy. Many PRs need only a title and a sentence or two. Larger PRs need more, but still paragraphs and bullets, not boilerplate sections. Use `## Summary` only when the body is long enough to benefit from a heading.

Focus the body on:

- **Why** the change exists — the one thing the diff cannot show.
- Non-obvious behavior, contract changes, or gotchas a reviewer would miss.
- Links to related PRs, RFCs, Twist threads, Linear tickets — inline where relevant, not in a dedicated section.
- Screenshots, Looms, or demo links when the visual impact matters — use placeholders when unavailable.
- Testing notes when the test approach is non-obvious.
- Deferred work named directly, not hidden.
- Stack or cross-repo context when the PR is part of a sequence.

Do not:

- Narrate the diff file-by-file or bullet-by-bullet. If the diff already shows it, the body should not repeat it.
- Add sections with no content. No empty `## Testing` or `## Not in scope`.
- Describe what changed without explaining why. "Exports `catchError`" is diff narration; "replaces `onError` because solid-js v2 removes it" is context.

Add `Closes PRO-12345` when a Linear ticket exists.

### Calibrating length

A one-line fix gets a one-line body (or none). A multi-concept refactor gets a few paragraphs explaining the shape. A cross-repo rollout gets related PR links, deploy ordering, and migration notes. Match the depth of the body to the complexity of the change.

### Bad and good examples

**Bad — inventing sections not in the template, on a simple change:**

```markdown
## Summary
Fixes the auth redirect issue when opening route links in background tabs.

## How to review
Look at the auth store changes.

## Not in scope
Other auth issues.
```

`## How to review` and `## Not in scope` are not in the repo template. Do not invent headings. Fill the template sections; omit the rest.

**Good — same change, follows a `## Summary` / `## How to Test` template:**

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

**Bad — diff narration that adds nothing beyond what the code shows:**

```markdown
## Summary

Upgrades solid-js from 1.6.2 to 1.9.12.

**API changes:**
- Exports `catchError`
- Marks `onError` as `@deprecated`
- Removes `splitProps` and `mergeProps` re-exports

**Migration:**
- `watchSignal` migrated from `onError` to `catchError`
- `createLoadableMemo` uses `try/catch` instead of `catchError`
- Removed stale `@ts-expect-error` in `timeout.ts`

All 154 tests pass.
```

Every bullet restates the diff. The bold-keyword sub-sections are section headers without `##` — same anti-pattern, different formatting. "All 154 tests pass" claims results without saying how to reproduce.

**Good — same change, explains decisions the diff cannot show:**

```markdown
## Summary

Upgrades solid-js to 1.9.12 in `@local/reactivity` to prepare for the v2
migration. The main change is replacing `onError` (removed in v2) with
`catchError`.

`createLoadableMemo` is the exception — it uses plain `try/catch` because
inside a memo callback, `catchError` defers its handler and does not flush
before the memo returns. This is a solid-js semantics constraint.

`onError` is still re-exported but deprecated. Unused re-exports removed.

## How to Test

`yarn test` in `packages/reactivity`. Type-check with `yarn typecheck`
covers `@local/reactivity` and its downstream consumers.
```

### Final pass

- Self-review before requesting review.
- Check that the title and body still match the branch contents.
- If the PR should be split, split it before polishing the writeup.
