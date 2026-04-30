# Data and Firestore

Firestore data modeling, document design, collection patterns, timestamp handling, and field semantics. Overlaps with transactions (see `transactions-and-safety.md`) but focuses on the data layer rather than operation safety.

## Document Design and Write Constraints

**What to look for:**

- Documents that could exceed the 1 write/sec/doc rate limit under normal load — suggests denormalization or sharding.
- Sequential indexed fields (auto-incrementing IDs, monotonically increasing timestamps as the sole index) that cause hotspotting.
- Collection group queries without team-path prefix scoping — security risk for multi-tenant data.
- Missing awareness of the 500-write batch limit — large batch operations need chunking.

**Severity:** Critical for write rate limit violations on high-traffic documents. Warning for collection group query scoping.

**Corpus examples:**

- _"This document could get more than 1 write/sec — consider sharding or denormalizing"_ (backend-services)
- _"Collection group queries need to be prefixed with the team path for security"_ (backend-services)

## Timestamp Handling

**What to look for:**

- `new Date()` or client-generated timestamps used where `serverTimestamp()` is needed for ordering correctness.
- `Date` used where `PreciseDate` is needed for nanosecond precision (Firestore timestamps have nanosecond granularity).
- Timestamp comparisons that don't account for Firestore's `Timestamp` type vs JavaScript `Date`.
- Missing `serverTimestamp` for fields used in ordering or conflict resolution.

**Severity:** Warning for client timestamps on ordering-critical fields. Info for precision suggestions.

**Corpus examples:**

- _"Use `serverTimestamp` here for ordering correctness"_ (backend-services)
- _"Use `PreciseDate` not `Date` for nanosecond precision"_ (backend-services)

## Field Semantics

**What to look for:**

- Field deletion vs setting to `null` — these have different Firestore semantics (deleted fields don't appear in queries with inequality filters).
- New required fields without migration plan for existing documents that lack them.
- Optional fields without documented null semantics (what does `null` mean vs `undefined` vs absent?).
- `update` vs `set` with merge — different behaviors for nested fields.

**Severity:** Warning for undocumented null semantics on new fields. Info for style suggestions.

## Schema Placement

**What to look for:**

- Types defined locally in a service that should live in the `schema` repo for cross-service use.
- Types in `domain` that are implementation-specific and should stay in the service.
- Schema dependencies on infrastructure libraries (e.g., Luxon, date-fns) — schemas should be lean.

**Severity:** Info for placement suggestions.

## Anti-Patterns

1. **Hot documents** — Single documents receiving >1 write/sec without sharding awareness.
2. **Client timestamps for ordering** — Using `new Date()` instead of `serverTimestamp()` for ordering-critical fields.
3. **Unscoped collection group queries** — Missing team-path prefix on collection group queries in multi-tenant data.
4. **Ambiguous null semantics** — New nullable fields without documenting what null/absent/undefined mean.
5. **Sequential indexed fields** — Monotonically increasing values as the primary index causing hotspots.
6. **Date instead of PreciseDate** — Losing nanosecond precision when it matters for Firestore timestamp comparisons.
