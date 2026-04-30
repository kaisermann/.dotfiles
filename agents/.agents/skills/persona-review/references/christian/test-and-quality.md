# Test and Quality

Test quality, error handling, logging, and code comment preservation. Spans both test files and production code.

## Test Quality

Tests should use shared factories, seed real data when possible, and be explicit about inputs. Mocked unit tests are questioned when integration tests with seeded data would provide better coverage.

**What to look for:**

- Manual test data construction instead of `buildTestTeam`, `buildTestStop`, and other shared factories.
- Unit tests with heavy mocking when the code touches Firestore — suggest converting to integration tests with emulator-backed seeded data.
- Unnecessary `as` casts in mock setup — use `vi.mocked()` instead.
- Default values in test setup that hide what the test actually covers.
- Test files not colocated with the code they test.
- `beforeEach` setting up test inputs rather than mechanical environment setup.
- Missing tests for changed behavior.
- Single `describe` blocks that add no value and just increase indentation — discouraged.
- Manual `clearAllMocks()` when the base config already sets `clearMocks: true` — redundant.
- Normalize mock variable naming: consistent `mocked{Thing}` or `{thing}Mock`, not a mix of both.
- `vi.mock()` hoisting means variables defined after the mock call won't be available inside the factory.
- Shared mutable test state that couples test cases.

**Severity:** Warning for tests that hide inputs or use wrong test level. Info for cleanup suggestions.

**Corpus examples:**

- _"We should always use the test factories. `buildTestTeam` etc"_ (backend-services #3142)
- _"These are integration tests, right? Can we rename this to `.integration.test.ts` and seed the team properly, query etc, instead of mocking everything?"_ (backend-services #3142)
- _"This is the default. We can remove it"_ (web-packages #1511)
- _"I'm a bit against files with a single describe call as it doesn't add much value and increases the indentation"_ (web-apps #4092)
- _"We don't need to clearAllMocks manually as we set `clearMocks: true` in the base config"_ (web-apps #4092)
- _"Since `mock` calls are hoisted, this 'shouldn't' work since `mockCurrentProduct` is not hoisted"_ (web-apps #4092)

## Server/Test Default Ownership

Production code should not invent server-owned values. Test factories are where magical defaults belong. This prevents production code from masking missing data by providing plausible-looking defaults.

**What to look for:**

- Factory or builder functions in production code that provide defaults for server-owned fields.
- Seed helpers that should hide build-test details but expose test configuration.

## Error Handling and Logging

Unexpected conditions should be logged, not silently swallowed. Prefer `console.error` or structured error logging over silent returns.

**What to look for:**

- Early returns on unexpected conditions without any logging or error reporting.
- Empty catch blocks.
- Missing error boundaries for components that could fail.
- Bugsnag events vs console.error — events are for breadcrumbs, `.error` is for actual errors.
- Portal/element-by-id lookups that silently return null — should throw or log.

**Corpus examples:**

- _"maybe we could emit an error?"_ / _"maybe log an error"_ (web-apps #4407)
- _"I would say that we should throw or log an error if the id is not found"_ (web-apps #3786)
- _"Do we want an event or an error/warn? Maybe this should be a `.error` call. IIRC events in Bugsnag are part of breadcrumbs."_ (web-apps #3625)

## Comment Preservation and Intent

Useful code comments should be preserved during refactoring. AI tools stripping existing comments is flagged. PR descriptions should explain the "why" behind non-obvious removals or changes.

**What to look for:**

- Useful comments removed during refactoring (especially by AI tools).
- Non-obvious decisions lacking inline comments explaining the rationale.
- PR descriptions that don't explain why code was removed or changed.
- Missing comments on hack/workaround rationale.
- Magic numbers without inline documentation.

**Severity:** Warning for stripped comments that explained important behavior. Info for missing new comments.

**Corpus examples:**

- _"Not sure if it was you or an AI, but these comments were ok and should be kept here"_ (web-apps #4180)
- _"Would be nice to have PR comments explaining such type of changes"_ (web-apps #3953)
- _"can you add inline comments where appropriate here? `7` reads very magical"_ (web-apps #3757)

## i18n Awareness

Translatable strings should contain only translatable content. Formatting characters (dividers, structural markup) should be in the template/component, not in the i18n string.

**Corpus example:**

- _"The divider being in the string is a bit weird"_ / _"the divider should be in the markup not in the translatable string"_ (web-apps #4407)

## Configuration Over Runtime Detection

Prefer environment variables and build-time configuration over runtime feature detection for infrastructure concerns like analytics disabling.

**Corpus example:**

- _"I would prefer if we had an env variable that would set this to `false` when we call `createAnalytics`"_ (web-apps #4318)

## Anti-Patterns

1. **Mocked Firestore tests** — Unit tests with heavy Firestore mocking when integration tests with seeded data would be more appropriate.
2. **Hidden test inputs** — `beforeEach` or wrapper functions that hide the inputs to the function under test.
3. **AI-stripped comments** — Useful code comments removed during refactoring, especially by AI tools.
4. **i18n formatting in strings** — Structural markup or formatting characters inside translatable strings.
5. **Silent error swallowing** — Early returns on unexpected conditions without logging.
6. **Single-describe test files** — A lone `describe` block that adds no value and just increases indentation.
7. **Redundant mock cleanup** — Manual `clearAllMocks()` when the base config already sets `clearMocks: true`.
8. **Inconsistent mock naming** — Mixing `mocked{Thing}` and `{thing}Mock` patterns within the same test file.
