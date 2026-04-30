# Verification Lens

Use this lens when the main question is whether the author proved the risky behavior, not just whether they wrote some tests.

## Focus

This lens focuses on:

- proof level relative to risk
- assertion quality
- realistic setup and fixture quality
- integration and round-trip validation
- auth and negative-path coverage when contract or behavior risk is meaningful

If the question is "what regression would this test actually catch in production?", start here.

## Default Heuristics

- Test behavior, not just success.
- Match proof level to risk: unit, integration, or cross-surface round-trip.
- Use the repo's test helpers and bootstrap patterns when they make the scenario more realistic.
- Ask for round-trip validation when the client or downstream consumer must send data back.
- Prefer assertions that prove semantics over assertions that only prove status codes or non-nullness.
- High-risk endpoints usually need auth and failure-path coverage, not just the happy path.
- Prefer self-contained tests with explicit inputs over wrappers that hide the behavior under test behind defaults.

## High-Signal Pattern Types

- risky changes with no tests or no believable validation path
- assertions that only check `200`, `success`, or `not null` instead of the behavior that matters
- over-mocked tests that cannot catch the real boundary or integration regression
- missing round-trip verification for API, pagination, token, encoding, or serialization contracts
- custom fixture setup that hides the real scenario when a repo helper already exists
- boundary, transition, or runtime changes with no coverage of the new edge case or failure mode
- endpoint changes with no auth, wrong-auth, or negative-path coverage where that risk matters
- tests that hide important inputs in shared wrappers, hooks, or merged defaults

## Pattern Anchors

- A pagination test that only checks `200` but never sends the page token back has not proven the contract.
- If the repo already has bootstrap helpers, route seed helpers, or shared factories, prefer those over manual fixture graphs.
- Replace type-cast assertions in tests with narrowing helpers or stronger typed assertions when possible.
- If a change depends on frontend-backend interplay, ask whether it was validated with the real second request, not just the first unit assertion.
- If a change adds a new transition branch, test the edge path users can actually trigger, not only the nominal flow.
- If the rollout depends on an intermediate compatibility phase, ask whether tests prove that mixed old/new states still work.

## Severity Anchors

### Flag As Critical

- high-risk changes with no believable proof
- integration or contract changes likely to fail outside unit tests
- migration, rollout, or runtime changes whose failure modes are untested and hard to detect
- cross-surface contract changes with no round-trip validation path

### Flag As Warning

- weak assertions that would miss the important regression
- tests at the wrong level for the risk involved
- missing edge-case coverage where the change clearly introduces new branches
- validation that ignores the frontend or downstream consumer in a cross-surface change
- auth or negative-path gaps on endpoints where those behaviors matter to safety

## Usually Ignore

- tiny low-risk diffs where extra test coverage would add little confidence
- requests for exhaustive testing when the current proof is already proportional to the risk
- stylistic test preferences without impact on confidence
- calls for broader integration coverage when the change is local and already well-proven

## Review Moves

- Ask what regression the current test would catch.
- Prefer assertions about semantics over status codes alone.
- Check whether an existing factory or bootstrap helper should replace manual setup.
- Check whether the proof needs an integration or round-trip path, not just a unit test.
- Ask whether auth, failure, and realistic edge cases were covered proportionally to the risk.
- Ask whether the test is readable in isolation, with the important inputs visible in the test body.

## Anti-Pattern Examples

1. Risky change with no evidence beyond manual confidence.
2. Test that proves the endpoint returned `200` but not that the behavior is correct.
3. Heavy mocking that hides the real integration risk.
4. Contract or pagination change with no round-trip validation.
5. New transition logic with no test for the edge path users can actually trigger.
6. Manual fixture sprawl where shared bootstrap helpers would make the scenario clearer.
