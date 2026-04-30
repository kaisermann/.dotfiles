# Contract Lens

Use this lens when the main risk is caller confusion, caller breakage, or contract drift across system boundaries.

## Focus

This lens focuses on:

- contract meaning
- exported and cross-service surface shape
- boundary typing and schema semantics
- compatibility windows and additive evolution
- parsing, coercion, and normalization ownership at the boundary

If the question is "what will callers think this field, endpoint, or type means?", start here.

## Default Heuristics

- Use names that encode the real domain concept, not just the current shape or implementation detail.
- Treat exported renames as contract changes, even when the code diff looks small.
- Prefer additive compatibility when active callers or parallel PRs still depend on the old shape.
- Keep parsing and normalization on the backend boundary unless there is a strong reason not to.
- Validate at the API boundary. Do not scatter core input interpretation across multiple layers or clients.
- Boundary types must be semantically honest: method, status code, schema input/output, and machine-readable error shape should all match the real behavior.
- Treat schema and API changes as cross-repo work until proven otherwise. Review the intermediate states, not just the final intended shape.

## High-Signal Pattern Types

- a rename that broadens or muddies a product concept instead of making it clearer
- request or response changes that force every consumer to migrate at once
- transformed-output typing used where request typing actually needs the raw input shape
- a read-like route or operation with side effects, or a generic client error when a more precise status code exists
- client code expected to parse dates, timestamps, or transport-shaped payloads that the boundary could normalize once
- error responses that only return freeform text instead of a stable machine-readable code
- docs or comments that describe a change as non-breaking even though callers still need to adapt

## Pattern Anchors

- Prefer the domain-truthful name: pick the term that reflects the actual business object and owning boundary, not a broader or implementation-shaped label.
- Treat "breaking by rename" as real breakage. If old callers still exist, keep both shapes briefly instead of relying on merge timing.
- If a field transform only exists because clients must parse raw values later, move that normalization back to the backend boundary.
- Use the schema's raw input type for request typing. Post-transform output typing can hide boundary drift.
- A route with side effects is not a read-only operation, even if it is easy to wire that way.

## Severity Anchors

### Flag As Critical

- breaking changes with no migration or coexistence plan
- schema or API changes likely to break active consumers during deploy
- contract changes hidden inside a refactor, rename, or internal cleanup
- coordinated changes that rely on near-simultaneous merges but preserve no compatibility in the meantime
- method, status-code, or validation semantics that will cause callers to handle the contract incorrectly
- schema or API changes that are safe only after dependent repos merge, but unsafe in the meantime

### Flag As Warning

- misleading naming that encourages incorrect use
- avoidable churn in exported shapes when an additive path is obvious
- schema or error-shape inconsistencies that make the contract harder to consume safely
- parsing or validation responsibility moved to the wrong side of the boundary
- missing or weak documentation around a changed contract

## Usually Ignore

- internal cleanup that does not alter the contract seen by callers
- stylistic naming preferences with no semantic consequence
- purely local refactors that preserve the same interface and meaning
- contract-adjacent follow-up work when the current shape is already compatible and clear

## Review Moves

- Ask what existing callers, docs, or downstream systems think this field or endpoint means today.
- Check whether old and new shapes need to coexist briefly.
- Check whether local docs, examples, and typed clients still describe the new shape correctly.
- Ask whether parsing, coercion, and validation are happening once in the right place.
- Ask whether each intermediate deployed state remains safe across dependent repos and older clients.
- When suggesting a change, name the safer compatibility shape explicitly.

## Anti-Pattern Examples

1. Generic rename that weakens domain precision.
2. Breaking exported surface hidden inside a small refactor.
3. Request type derived from output semantics rather than raw input semantics.
4. Contract change described as non-breaking without checking real callers.
5. Immediate replacement where dual support would reduce rollout risk.
6. Client-owned core parsing that should happen once on the backend.
