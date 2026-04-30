# API and Schema Design

HTTP method semantics, status code precision, zod schema correctness, structured error codes, and input validation placement. Helena reviews API boundaries with high scrutiny for correctness and consistency.

## HTTP Method and Status Code Correctness

**What to look for:**

- `GET` used for operations with side effects — should be `POST`.
- `DELETE` used for operations that do more than remove a resource.
- Wrong status codes: 400 (bad input) vs 403 (forbidden) vs 404 (not found) vs 409 (conflict) vs 422 (validation failure).
- Missing status code distinctions — returning generic 400 when a more specific code communicates the error type.
- `POST` endpoints that should be idempotent but aren't.

**Severity:** Warning for incorrect methods. Info for status code refinements on otherwise-working code.

**Corpus examples:**

- _"This should be a POST, not a GET — it has side effects"_ (backend-services)
- _"DELETE should only remove the resource, not trigger all these side effects"_ (backend-services)
- _"This should be 409 (conflict), not 400"_ (backend-services)

## Zod Schema Correctness

**What to look for:**

- `z.infer` used for request type assertions — should be `z.input` (because `z.infer` is `z.output`, which reflects transforms/defaults that haven't been applied to the raw input).
- Missing type assertion checks: `assert<IsExact<SchemaType, InputType>>()` to catch schema/type drift.
- Types that should live in the `schema` repo for cross-service sharing but are defined locally.
- Discriminated unions not used where multiple exclusive shapes exist.
- Missing `.default()` on optional fields that need backward compatibility.
- Coercion not applied to query string parameters (which arrive as strings).

**Severity:** Warning for `z.infer`/`z.input` confusion and missing type assertions. Info for schema placement suggestions.

**Corpus examples:**

- _"Use `z.input` not `z.infer` for the request type — `z.infer` is `z.output`"_ (backend-services)
- _"Add a type assertion: `assert<IsExact<typeof schema, InputType>>()`"_ (backend-services)
- _"This type should live in the schema repo so other services can use it"_ (backend-services)

## Structured Error Codes

**What to look for:**

- Freeform error message strings as the only error identifier — should use typed enum error codes.
- Error responses without a machine-readable code field alongside the human-readable message.
- Inconsistent error response shapes across endpoints in the same service.

**Severity:** Warning for missing structured error codes on new endpoints. Info for inconsistency in existing code.

## Input Validation Placement

**What to look for:**

- Validation logic buried deep in service or data layers instead of at the API handler boundary.
- Duplicate validation in both the handler and the service layer.
- Missing validation on path parameters or query strings.
- Request body params split incorrectly between path, query, and body.

**Severity:** Info for placement suggestions. Warning for missing validation on user-facing inputs.

**Corpus examples:**

- _"Validate at the API layer, not deeper"_ (backend-services)
- _"Split these into separate parameters — path params for identity, body for payload"_ (backend-services)

## Anti-Patterns

1. **`z.infer` for request types** — Use `z.input` for request type assertions; `z.infer` is the output type after transforms.
2. **GET with side effects** — Use POST for any operation that modifies state.
3. **Generic 400 for everything** — Use specific status codes (403, 404, 409, 422) to communicate error types.
4. **Freeform error strings** — Use typed enum error codes for machine-readable error identification.
5. **Deep validation** — Validate inputs at the API boundary, not in service or data layers.
6. **Missing type assertions** — Schema definitions without `assert<IsExact<>>()` checks drift from their intended types silently.
