# Structure and Scope

Code should live where it belongs — close to its consumers, at the right level of the hierarchy, in the right package. Components, utilities, and types that leak across boundaries are flagged. Import direction is treated as a first-class architecture signal.

## Colocation Rules

Code should live next to its consumers. When something is used in only one place, it belongs co-located with that consumer, not in a shared directory.

**What to look for:**

- Contexts living in global `/contexts` when they're only consumed within a specific route folder.
- Hooks used in only one place that should be co-located with their consumer.
- Components only used within private routes that belong under `(private)/`.
- Components defined in one file but only used in another — should be inlined or moved.
- Exports that shouldn't be exported (used only internally).
- Utilities placed in generic locations (`utils/`, `helpers/`) when they belong in a feature module.

**Corpus examples:**

- _"All files in this PR need to be co-located under `src/app/(private)/...`"_ (web-apps #3657)
- _"This context can live in /contexts in the billings page folder"_ (web-apps #3666)
- _"This component should be moved to the other file then, it has nothing to do with the 'empty state' anymore. It can be inlined in the other file and not exported"_ (web-apps #4358)

## Import Direction as Architecture

More-specific modules importing from less-specific locations is structurally wrong. If `/features/optimization-relations/` imports from `/(plans)/plans/contexts/PlanContext`, the dependency direction is inverted.

**What to look for:**

- A less-specific folder importing from a more-specific one.
- Feature modules reaching into page-specific contexts or hooks.
- Barrel file exports that create implicit dependency chains.

**Severity:** Warning. Import direction violations are structural issues, not style preferences.

**Corpus examples:**

- _"this is effectively importing a context from a 'more specific' folder into a 'less specific' module... this doesn't seem to follow any colocation guideline we set"_ (web-apps #4070)
- _"These two imports don't look right. Can we kill the `index` and have both imports coming from an internal file within the folder?"_ (web-apps #4070)

## Package Boundary Correctness

Shared packages have strict scopes. App-specific code does not belong in shared packages. Generic packages should not absorb business-domain concerns.

**What to look for:**

- `web-utils` containing business logic — business code goes to `@getcircuit/algorithms`.
- `web-map`'s GoogleMaps module importing Spoke data structures — it should be standalone.
- `components` package depending on analytics.
- Dispatch-specific code living in `ui-models` or other shared packages.
- App-specific ESLint rules in the base config.
- Generic component APIs auto-injecting untranslated strings (design-system drift).

**Corpus examples:**

- _"this seems business-related so it should go to @getcircuit/algorithms, not web-utils"_ (web-apps #3981)
- _"We should treat the 'modules/GoogleMaps' as a standalone package. It shouldn't know anything about 'Spoke's data structures"_ (web-apps #3992)
- _"We don't need the analytics package as a dependency of `local/components`"_ (web-apps #3643)
- _"If this is Dispatch-exclusive, I would recommend adding it to src/models or src/modules or somewhere inside the dispatch app"_ (web-apps #3816)
- _"I'm not sure this belongs in this package. It feels too specific to be in the base eslint config."_ (web-packages #1317)

## Placement Heuristics

- Utilities used by a single app belong in that app, not in a shared package.
- Shared package additions should be coordinated — design-system additions should not proliferate ad hoc.
- Package-level additions that are too app-specific should be moved into the app.
- "Should this be in `schema` instead?" — question whether data definitions are at the right level.

## Anti-Patterns

1. **Wrong colocation level** — Code living too high (shared when single-use) or too low (duplicated across features).
2. **Import direction violations** — Less-specific modules importing from more-specific ones.
3. **App-specific code in shared packages** — Business logic in `web-utils`, Spoke data structures in `GoogleMaps` module, dispatch-specific models in `ui-models`.
4. **Uncoordinated design-system additions** — Ad hoc component/icon additions to shared packages without design team awareness.
5. **Global contexts for local state** — Contexts that serve only one route folder but live at the app root.
