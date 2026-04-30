# Patterns and Abstractions

Existing abstraction reuse is the single most frequent class of review comment. Kaisermann tracks shared utilities, hooks, factories, query constructors, and selectors across the entire Spoke ecosystem. When a PR introduces code that overlaps with an existing shared abstraction, he points to the existing one — often with a direct link to the source file.

This dimension also covers the inverse: detecting unnecessary abstractions that add indirection without earning their existence.

## Existing Abstractions Over Reinvention

**What to look for in a diff:**

- Manual Firestore document/collection references instead of `refSelectors()`. This is the most-flagged specific instance (7+ times in a single PR).
- Handcrafted Firestore queries instead of `firestore-kit` query constructors (`chunkedQuery`, `select()`, aggregate queries).
- New utility functions that duplicate existing ones in `web-utils`, `web-packages`, or the local app's shared modules.
- Custom callback stabilization instead of `useEffectEvent`.
- Manual test data construction instead of shared test factories (`buildTestTeam`, `buildTestStop`, etc.).
- Inline Firestore batch operations instead of using the batch writer helpers.
- Known existing utilities: `useIsMounted`, `usePlanMapEvent`, `mockWindowLocation()`, `getCountFromServer`, `createComputed`, `createLoadableSignal`.

**Severity:**

- Warning for most cases. Info when the existing abstraction is merely better but the current code works.
- Always name the specific existing abstraction and where it lives.
- If the existing abstraction does not quite fit, suggest extending it rather than reinventing.

**Corpus examples:**

- _"we can use our query constructor from `firestore-kit/admin`. We can also use `select()` to not fetch any field."_ (backend-services #3142)
- _"We should use ref selectors here"_ (web-apps #4318, repeated 7+ times)
- _"We have `getTimePartsFromSeconds(): hour minute second`"_ (web-apps #4407)
- _"Can you stabilize the `onSlaStartTimeChange` via a `useEffectEvent`? Callers shouldn't need to remember to memoize the callback"_ (web-apps #4407)
- _"We should always use the test factories. `buildTestTeam` etc"_ (backend-services #3142)
- _"We have a `useIsMounted` hook"_ (web-apps #3616)
- _"I think we have a `createLoadableSignal` to avoid the `createdLoadableMemo` at the end"_ (web-apps #4098)

## Unnecessary Abstraction Detection

Hooks, components, wrappers, and indirection layers that don't earn their existence are questioned before their implementation details are reviewed. The question is always "does this need to exist at all?"

**What to look for:**

- New hooks that wrap a single primitive call with no additional logic.
- New components that could be inlined in their only consumer.
- Wrapper functions that add no transformation or error handling.
- Context providers for data that could be passed as props or derived inline.

**Corpus examples:**

- _"Do we even need this hook? Can we just use the `useGlobalShortcut` alongside `GLOBAL_SEARCH_SHORTCUT` where needed instead?"_ (web-apps #4006)
- _"A context here seems super overkill"_ (web-apps #3783)
- _"do we even intend to use this Limits somehow? Or will we just use LLMTokenUsage?"_ (domain #1053)
- _"usePlanPickerBundleFromPaths doesn't feel like the right abstraction. Currently, we only need to load one plan from the planPath and map it to a PlanPickerItem."_ (web-apps #4003)

## Cross-Referencing as Review Method

Kaisermann links to exact existing files, PRs, helpers, external articles, and Linear issues in review comments. An agent should do the same — reference specific code locations and documentation rather than making abstract suggestions.

**Corpus examples:**

- Links to `kyleshevlin.com/no-outer-margin` when flagging margin issues
- Links to existing test utilities with direct GitHub URLs (web-apps #3958)
- Links to TanStack Query discussions for `isPending` vs `isLoading` (web-apps #3855)
- Links to Linear issues for planned future work (web-apps #3737)
- _"If you want we can use our more general `mockWindowLocation()` instead!"_ with a direct link to the source file (web-apps #3958)

## Anti-Patterns

1. **Reinventing `refSelectors`** — Any manual `doc()` / `collection()` call that could use refSelectors.
2. **Full document fetches** — Queries that fetch entire documents when `select()` projection would suffice.
3. **Manual test data** — Constructing test objects inline instead of using shared factories.
4. **Unnecessary hooks/wrappers** — Abstractions that add indirection without earning their existence.
5. **Abstract suggestions** — Review comments that say "consider using an existing utility" without naming which one and where it lives.
