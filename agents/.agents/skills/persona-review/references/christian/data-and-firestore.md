# Data and Firestore

Deep Firestore knowledge applied consistently: query limits, SDK boundaries, projection optimization, batch patterns, data modeling, and representation correctness. This goes beyond gotcha awareness — it includes suggesting the right Firestore API for the job.

## Firestore Query Patterns

**What to look for:**

- `in` or `array-contains-any` queries without awareness of the 30-item limit. Suggest `chunkedQuery`.
- Queries that fetch full documents when only a few fields are needed. Suggest `select()` projection.
- Count operations that fetch documents instead of using aggregate queries.
- `set` used where `update` is correct (upsert vs modify-existing semantics).
- Missing `documentId()` filters where they would simplify queries.
- Batch operations that could hit the 500-write limit without chunking.
- `firestore-kit` query constructors preferred over raw query building for type-safe `where()` calls.
- `getCountFromServer` for non-reactive counts instead of fetching full documents.
- Redundant `isValidDocument` checks after queries that already guarantee valid documents.

**Severity:** Warning for incorrect patterns that could fail in production (query limits, SDK mixing). Info for optimization suggestions (select, aggregates).

**Corpus examples:**

- _"`in` can have `30` items. Also, we can use `chunkedQuery` from `firestore-kit/admin` to support more than 30 if needed."_ (backend-services #3033)
- _"We can also use a `select` to fetch only `email`, `phoneNumber` and `teamId` and `contact`"_ (backend-services #3033)
- _"Better than that, might be to use an aggregate query"_ (backend-services #3142)
- _"We can use a `getCountFromServer` instead of `getDocs` if we only need the number of plans in a non reactive way"_ (web-apps #3511)

## SDK Boundary Enforcement

Mixing Admin and Client SDK imports — even type imports — is a hard boundary violation. Each entrypoint should use only one SDK.

**What to look for:**

- Any file importing from both `firebase` and `firebase-admin`, including type-only imports.
- Components or modules that should use `firestore-kit/client` but import from `firestore-kit/admin` (or vice versa).
- `firestore-types` usage — prefer `firestore-kit/admin` patterns and related abstractions.
- `WithFieldValue` misuse — Firestore update/write helper types leaking into plain model construction.

**Severity:** Critical when SDK mixing could cause bundle or runtime issues. Warning for type-level leakage.

**Corpus examples:**

- _"We should avoid even type imports for both sdks"_ (web-packages #1574)
- _"We need two entrypoints. Having these two here implies importing both firebase and firebase-admin even if we just use one of them."_ (web-packages #1574)

## Data Representation

When a PR introduces data modeling decisions, the representation is scrutinized.

**What to look for:**

- Integer vs string for monetary amounts — prefer the most granular representation ("store smallest unit").
- Whether currency belongs next to the amount or is stored separately.
- Snapshot vs reference semantics.
- Configuration data mixed with execution data that should be separate.
- Schema placement — does a type belong in `domain`, `schema`, or the app?
- Cross-codebase rollout awareness for model changes.
- RFC-needed threshold for larger model changes.
- Dependency skepticism — schemas should stay lean and infra/date-lib agnostic when possible (e.g., Luxon in schema is questioned).
- Required fields vs optional fields — nullability and fallback semantics must be explicit.
- Documenting null semantics and lifecycle notes for new fields.

**Corpus examples:**

- _"Where is the currency information available? Shouldn't it be next to the amount? What if team currency changes?"_ (domain #986)
- _"They do support a `unit_amount` that is an integer though"_ (domain #986, referencing Stripe's API)

## TanStack Query Patterns

- `isPending` preferred over `isLoading` per TanStack Query recommendations.
- Query keys must include all varying parameters — missing a time range or depot ID means stale cache hits.
- Don't load data you don't need — unnecessary context consumption and data fetching is flagged.

**Corpus examples:**

- _"isPending is recommended instead"_ with link to TanStack discussion (web-apps #3855)
- _"this key is wrong as it doesn't contemplate the 'time range'. we should include the start/end here"_ (web-apps #3826)
- _"Not necessary to load members here"_ (web-apps #3997)

## Anti-Patterns

1. **Unbounded `in` queries** — Using `in` filter without chunking awareness.
2. **Mixed SDK imports** — Any file importing from both `firebase` and `firebase-admin`, even types.
3. **Full document fetches** — Queries that fetch entire documents when `select()` projection would suffice.
4. **`WithFieldValue` misuse** — Firestore update/write helper types leaking into plain model construction.
5. **`isLoading` instead of `isPending`** — TanStack Query migration: `isPending` is the recommended property.
6. **Incomplete query keys** — React Query keys that omit varying parameters (time ranges, depot IDs, etc.).
7. **Redundant nullish patterns** — `?? undefined` or similar no-ops.
