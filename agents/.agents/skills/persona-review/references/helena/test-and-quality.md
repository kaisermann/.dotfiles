# Test and Quality

Test coverage expectations, auth test requirements, integration test preferences, and code style patterns from Helena's review corpus.

## Auth Test Coverage

Every API endpoint must have auth tests. This is Helena's most consistent testing requirement.

**What to look for:**

- New endpoints without tests for: missing auth token, wrong auth token, wrong team.
- Auth test coverage that only checks the happy path without verifying rejection cases.
- Missing 401/403 assertions on protected endpoints.

**Severity:** Warning for missing auth tests on new endpoints.

**Corpus examples:**

- _"Add auth tests: missing auth, wrong auth, wrong team"_ (backend-services)

## Integration Over Mocking

**What to look for:**

- Heavy mocking of Firestore operations when emulator-backed integration tests would provide better coverage.
- Mocked tests that don't actually verify the Firestore query logic (the mock returns whatever you tell it to).
- Unit tests for code that primarily orchestrates external service calls — these should be integration tests.
- Tests that could use realistic data volumes but test with trivially small datasets.

**Severity:** Warning for mocked Firestore tests that should be integration tests. Info for data volume suggestions.

**Corpus examples:**

- _"Don't mock things that could be tested with emulators"_ (backend-services)
- _"Test with realistic data volumes"_ (backend-services)

## Edge Case Coverage

**What to look for:**

- Missing tests for empty result sets, null/undefined inputs, and boundary conditions.
- Tests that only cover the happy path without error scenarios.
- Missing tests for concurrent operation scenarios when the code handles concurrency.

**Severity:** Info for most edge case suggestions.

## Code Style Patterns

Helena has consistent preferences for code clarity and organization:

**What to look for:**

- Arrow functions where function declarations would be clearer (preference for `function` keyword).
- Type assertions (`as`) when proper typing or type guards are available.
- Typeguard functions missing the `is` prefix convention.
- Unclear variable names (`aa`, `bb`, `s`) instead of descriptive names.
- Reusable logic inline instead of extracted to a separate file/function.
- Missing JSDoc on exported functions.
- `async/await` mixed with `.then/.catch` in the same function.
- Functions exported solely for testing that should be in their own module.

**Severity:** Info for most style suggestions.

**Corpus examples:**

- _"Use function keyword instead of arrow function"_ (backend-services)
- _"Use a typeguard with `is` prefix"_ (backend-services)
- _"Extract this to a separate file — it's reusable"_ (backend-services)

## Performance Awareness

**What to look for:**

- `Array.includes` for large collections where `Set` lookup would be O(1).
- Wildcard Elasticsearch queries that could be bounded.
- Large data structures loaded into memory without consideration for size.
- Sequential operations that could be parallelized with `Promise.allSettled`.

**Severity:** Info for most performance suggestions. Warning for unbounded operations on production data.

**Corpus examples:**

- _"Use Set for lookups instead of Array.includes"_ (backend-services)
- _"Use Promise.allSettled for these independent operations"_ (backend-services)

## Anti-Patterns

1. **Missing auth tests** — Every new endpoint needs tests for missing auth, wrong auth, and wrong team.
2. **Mocked Firestore tests** — Use emulator-backed integration tests instead of mocking Firestore operations.
3. **Happy-path-only tests** — Missing error scenarios and edge cases.
4. **Type assertions over proper typing** — `as` casts when type guards or proper generic types exist.
5. **Array.includes on large sets** — Use Set for O(1) lookups.
6. **Functions exported only for testing** — Move to their own module instead of exporting internals.
