# Backend Boundaries and Transformations

Parsing, validation, and data normalization should happen on the right side of the boundary. Sam tends to push transformation work toward the backend when that keeps the contract simpler and more reliable for clients.

## Parsing Ownership

**What to look for:**

- Frontend callers expected to parse or normalize raw API payloads that the backend could shape once.
- Date or timestamp transformations deferred to clients without a strong reason.
- API contracts that expose transport-shaped values instead of application-shaped values.
- Validation or coercion distributed across multiple consumers instead of centralized at the server boundary.

**Severity:** Warning when the wrong side of the boundary owns a core transformation. Info when it is more of a consistency question than a bug.

**Corpus examples:**

- _"So the frontend will parse the date string into a timestamp? Asking as I think in general we do most of this parsing/transformations on the backend"_ (domain #1227)

## Boundary Coherence

**What to look for:**

- API changes that make consumers guess whether a value is raw, parsed, or display-ready.
- Backend handlers that leak internal status or deprecated fields into public contracts.
- Contract updates that should be paired with adjacent filtering or query parameters to remain useful.

**Severity:** Warning when the surface becomes inconsistent or harder to consume. Info for follow-up contract-shape suggestions.

**Corpus examples:**

- _"Not directly related to this PR but I assume we'll want to add some filtering options for startsAt like we have for plans"_ (backend-services #3262)

## Anti-Patterns

1. **Client-owned core parsing** - Making every frontend consumer parse backend values that should arrive normalized.
2. **Ambiguous contract values** - Fields whose type or semantic level is unclear at the boundary.
3. **Leaky public shape** - Internal or deprecated status leaking into exported API behavior.
