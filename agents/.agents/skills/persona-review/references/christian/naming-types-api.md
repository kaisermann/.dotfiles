# Naming, Types, and API Design

Names should encode intent, not just describe shape. Type representations should be precise and honest. API surfaces should be minimal and clear. This dimension covers naming precision, TypeScript hygiene, function/API design, JSDoc documentation, discriminated unions, `satisfies` usage, and barrel file skepticism.

## Naming Precision

Appears in nearly every non-trivial review. Generic names that require context to understand are consistently flagged. This applies to types, functions, variables, files, entrypoints, and test IDs.

**What to look for:**

- Type or interface names too generic for their actual scope (`Limits` when it means `LimitedResources` or `LLMLimits`).
- Names that leak implementation details or wrong domain (`TeamCurrency` when it should be `SupportedCurrency`).
- Variable names that misrepresent what they hold (`id` when it's actually a path).
- File names that don't follow kebab-case convention.
- Entrypoint names that don't communicate their purpose.
- Test IDs with non-meaningful prefixes.
- Changeset descriptions that are vague ("Add factory" instead of "Add buildStopTemplate factory").
- Component names that don't reflect what they render (`MainInner` is unclear).
- Function vs component naming: if not used as JSX, name as a function, not a component.
- `shouldBlock` returning `true` when it shouldn't block — the name contradicts the behavior.
- Magic constants without explanatory names or comments.
- Legacy terminology that should be cleaned up (e.g., `multiDepot` prefix from before depots existed).

**Severity:** Warning for names that actively mislead or are too generic. Info for minor improvements. Always suggest a specific alternative name and explain why the current one is imprecise.

**Corpus examples:**

- _"This is quite a generic name. We could maybe make it similar to the comment: `LimitedResources`"_ (domain #1053)
- _"Maybe we should call this 'SupportedCurrency' or 'Currency' or anything not related to a team."_ (domain #986)
- _"also the `id` variable seems to be a path, not an id"_ (backend-services #3033)
- _"`displayName` is an awkward name for a property of a `StopParams` type. `driverName` is more explicit"_ (web-apps #3832)
- _"The `team` is misleading. This bundle is about a member acting as a driver within the context of a plan"_ (web-apps #3737)

## TypeScript Hygiene

Unnecessary type assertions are questioned. Proper narrowing is preferred over casting.

**What to look for:**

- `as` casts that paper over type mismatches instead of fixing the underlying type.
- `as any` usage (especially in AI-generated code).
- `as const` on multiple values when a single `as const` on the parent would suffice.
- String types where union literals would be more precise.
- Optional chaining or nullish coalescing used to hide real type issues.
- `vi.mocked()` preferred over manual type casting in test mocks.

**Severity:** Warning for `as any` and casts that hide real type problems. Info for simplification suggestions.

**Corpus examples:**

- _"a single `as const` here should be enough"_ (domain #1197)
- _"do we need the `as`?"_ with a suggestion to use `vi.mocked()` directly (web-packages #1511)
- _"export type SlaDueStatus = 'default' | 'due-today' | 'overdue'"_ — suggesting union literal type (web-apps #4407)

## JSDoc as API Contract

Exported/public symbols need JSDoc. An undocumented public API is incomplete. The bar is especially high for hooks and components where the name alone doesn't explain behavior.

**What to look for:**

- Exported functions, hooks, or components without JSDoc.
- JSDoc that describes obvious behavior instead of non-obvious constraints or lifecycle.
- Missing documentation of null semantics, fallback behavior, or expected input shapes.
- README updates missing when shared package APIs change.

**Corpus examples:**

- _"We could have a jsdoc explaining what this component does/represents"_ (web-apps #3779)
- _"Imagine that someone without any context will read this code in 8 months"_ (web-apps #3779)
- _"Maybe we could document in the jsdoc that an attempted stop will never have a geocode issue"_ (web-apps #3779)
- _"The readme should be updated with proper instructions"_ (web-packages #1574)

## Discriminated Unions and State Machine Types

Explicit status discriminants are preferred over nullable/optional fields for representing context states. Eliminates ambiguous null states and enables exhaustive checking.

**Corpus examples:**

- _"With the discriminated status union, we can remove the null. userData now either exists or not. No ambiguity."_ (web-apps #3587)
- Extensive discussions about explicit return types vs casting for multi-state LoggedUser context (web-apps #3524)

## API and Function Design

- Named object arguments preferred over positional when there are multiple parameters.
- Optional injectable arguments (e.g., `now = new Date()`) for testability.
- Functions vs objects — question whether a function wrapper is needed when a plain object export would work.
- Return objects from hooks/utilities so the consumer gets named properties, not positional ones.

**Corpus examples:**

- _"Maybe return an object so the name of the variable is not up for the consumer"_ (web-apps #3666)

## Barrel File Skepticism

Internal folders usually don't need barrel files. When they exist, they should use explicit named exports. Multiple exports of the same thing from different files are confusing.

**Corpus examples:**

- _"Can you explicitly export what we need?"_ with link to code organization docs (web-apps #3958)
- _"Can we kill the index and have both imports coming from an internal file within the folder?"_ (web-apps #4070)

## Anti-Patterns

1. **Generic names** — Types, functions, or variables named after their shape rather than their domain.
2. **`as any` or gratuitous `as`** — Type assertions that mask real type problems.
3. **Missing JSDoc on public API** — Exported functions, hooks, and components without documentation.
4. **Unnecessary barrel files** — Index files in internal folders that don't serve a clear re-export purpose.
5. **Positional function arguments** — Multiple parameters where a named object would improve readability.
6. **Redundant nullish patterns** — `?? undefined` or similar no-ops.
