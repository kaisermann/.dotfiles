# Error Handling and Observability

Defensive error handling, structured logging, tracing, and the principle that unexpected conditions must never be swallowed silently.

## Defensive Error Handling

**What to look for:**

- Silent returns on unexpected conditions without logging — every unexpected branch should log before returning.
- Empty catch blocks or catch blocks that only re-throw without adding context.
- `.then/.catch` chains where `try/catch` with `async/await` would be clearer.
- Deep nesting from multiple condition checks — prefer early returns to flatten control flow.
- Missing error handling on external service calls (HTTP, Firestore, Pub/Sub).

**Severity:** Warning for silent error swallowing. Info for style preferences (try/catch over .then/.catch).

**Corpus examples:**

- _"Log the error before returning here"_ (backend-services)
- _"Use try/catch with async/await instead of .then/.catch"_ (backend-services)
- _"Early return here to avoid the deep nesting"_ (backend-services)

## Structured Logging

**What to look for:**

- Template literal log messages instead of structured object parameters — `logger.info('message', { key: value })` not `` logger.info(`message ${value}`) ``.
- `err` key in log objects instead of `error` — the convention is `{ error }`.
- Missing trace attributes that would help correlate logs during debugging.
- Log level misuse — `info` for errors, `error` for non-error conditions.
- Missing context in error logs — the log should include enough metadata to reproduce the issue.

**Severity:** Warning for missing error logging. Info for structured logging style suggestions.

**Corpus examples:**

- _"Use `{ error }` not `{ err }` in the log object"_ (backend-services)
- _"Add trace attributes here for debugging"_ (backend-services)
- _"Use structured logging with object params, not template literals"_ (backend-services)

## Trace Attributes

**What to look for:**

- `snake_case` for trace attribute keys and Honeycomb fields — not camelCase.
- Missing span attributes on operations that would benefit from distributed tracing correlation.
- Trace context not propagated across service boundaries.

**Severity:** Info for most tracing suggestions.

## Anti-Patterns

1. **Silent error swallowing** — Returning early on unexpected conditions without logging.
2. **Template literal logging** — Using string interpolation instead of structured log objects.
3. **Wrong error key** — Using `err` instead of `error` in structured log objects.
4. **`.then/.catch` chains** — Prefer `try/catch` with `async/await` for readability.
5. **Deep nesting** — Multiple nested conditions instead of early returns.
6. **Missing error context** — Error logs without enough metadata to diagnose the issue.
