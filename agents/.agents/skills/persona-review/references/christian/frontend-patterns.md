# Frontend Patterns

React and Svelte-specific review patterns. These apply to web-apps reviews where the diff contains components, hooks, effects, callbacks, or CSS.

## `useStableCallback` Deprecation -> `useEffectEvent`

Active migration away from `useStableCallback`. Components should stabilize callbacks internally so callers don't need to remember to memoize. `useEffectEvent` is the preferred replacement.

**What to look for:**

- New `useStableCallback` usage — should use `useEffectEvent` instead.
- Existing `useStableCallback` in modified code — suggest migration if the change is nearby.
- Callback props that force callers to memoize — the component should stabilize internally.

**Corpus examples:**

- _"We are slowly moving away from using useStableCallback everywhere. See if we can remove these without any performance hit"_ (web-apps #3743)
- _"In the future we should use useEffectEvent instead of useStableCallback most of the time"_ (web-apps #3743)
- _"We shouldn't need useStableCallback. The component should stabilize this internally if necessary (aka use useEffectEvent)"_ (web-apps #3826)

## Effect Justification

Every `useEffect` should have an obvious reason. Effects that could be derivations, computations, or event handlers are flagged.

**What to look for:**

- Effects that compute derived values — replace with `useMemo`, `createComputed`, or inline derivation.
- Effects inside `useMemo` — never do this.
- Loading state managed by effects when it could be derived from existing query state.
- Effects that could be replaced by event handlers.
- Named functions inside effects preferred for readability.

**Corpus examples:**

- _"No effects in a `useMemo`"_ (web-apps #4003)
- _"Just wrap the call in a `createComputed`"_ (web-apps #4098)
- _"I think we have a `createLoadableSignal` to avoid the `createdLoadableMemo` at the end"_ (web-apps #4098)

## Derivation Over State

If a value can be derived, it should not be stored. Unused state is dead weight. Values used in only one place should be inlined.

**What to look for:**

- State variables that could be computed from other state.
- Unused loading states or other dead state.
- Values stored in state that are only used once — inline them.
- Exhaustive derivation: if someone introduces a new status, the hook should force them to handle it.

**Corpus examples:**

- _"We were not using the isLoading anywhere"_ (web-apps #3727)
- _"If someone introduces a new status, they should consider the hook"_ (web-apps #3625)

## Unnecessary Spread and Over-Passing

Functions, hooks, and components should receive only what they need. Spreading full objects when 2-3 fields are used couples consumers to producer shapes unnecessarily.

**What to look for:**

- Spreading full objects into components or function calls when only a few props are used.
- Hooks or functions accepting entire bundles/contexts when they only need 2-3 fields.
- Missing `Pick<>` types when partial objects are passed.

**Severity:** Warning for spreads that create unnecessary coupling. Info for minor over-passing.

**Corpus examples:**

- _"Please, let's not spread things unnecessarily"_ (web-apps #3884)
- _"No need to pass the whole bundle here just for two props"_ (web-apps #3884)
- _"Maybe a Pick then? Feels like we're passing too much"_ (web-apps #3999)
- _"This could receive just displayName, phone and email instead of the whole member bundle"_ (web-apps #3826)

## Outer Margin Prohibition

Components should never apply outer margin automatically. Margin is leaky and breaks encapsulation. Use padding internally or apply margin from the consumer side.

**Corpus example:**

- _"Components should never apply margin automatically as it breaks encapsulation (margin is leaky). We should use padding instead or apply the margin from the consumer side"_ with link to kyleshevlin.com/no-outer-margin (web-apps #3958)

## Early Returns Over Nesting

Prefer early returns over deeply nested conditionals. This applies to both render logic and data processing.

**Corpus examples:**

- _"We can early return here"_ (web-apps #3744, #3844)
- _"i don't dislike switch statements, but 90% of the time I think a normal if statement reads better"_ (web-apps #3514)

## Memoization Scrutiny

Memoization is neither always good nor always bad. Question `useMemo` when the computation is trivial. Question its absence when an expensive derivation is recomputed on every render. Never put effects inside `useMemo`.

## Container Queries Over Duplicate Components

When a component needs different layouts at different sizes, prefer CSS container queries over creating separate Large/Small component variants with duplicated logic.

**Corpus example:**

- _"The difference between them both seems presentational. CSS (even more with container queries) should be enough for this"_ (web-apps #3547)

## `satisfies` for Literal Type Preservation

Use `satisfies` to validate object shape against a type while preserving literal types. Avoids `as string[]` downcasts.

**Corpus examples:**

- _"const possibleTabs = [...] satisfies PlanAndBillingTab[] might prevent us from needing the as string[] below"_ (web-apps #3641)
- _"We could use satisfies instead to preserve the keys"_ (web-apps #4104)

## Svelte Idioms

In Svelte files, prefer `$: { }` reactive blocks over `subscribe` calls. Avoid imperative patterns when declarative ones exist.

**Corpus example:**

- _"Using a subscribe inside a .svelte component is not exactly idiomatic. Would be better to do this inside a $: { ... } block"_ (web-apps #3702)

## Anti-Patterns

1. **`useStableCallback` usage** — Should be migrated to `useEffectEvent` or removed.
2. **Effects as derivations** — `useEffect` computing values that could be derived inline or via `useMemo` / `createComputed`.
3. **Outer margin on components** — Components applying their own external margin.
4. **Unnecessary object spreads** — Spreading full objects to pass 2-3 props.
5. **Unstabilized callbacks** — Callbacks passed as props without `useEffectEvent`, forcing callers to memoize.
6. **Duplicate responsive components** — Separate Large/Small variants when CSS container queries would suffice.
