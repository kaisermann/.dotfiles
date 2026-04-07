# PR Heuristics

Use this to decide how much PR context is enough.

## Add more context when

- the PR spans multiple concepts
- the change is risky, subtle, or hard to test from the diff alone
- the PR is part of a stack or cross-repo rollout
- the reviewer needs artifacts such as screenshots, Looms, benchmarks, or decision docs
- work is intentionally deferred and that affects how the diff should be read

## Keep it short when

- the change is small and the diff already tells the story
- the only useful additions are the why, one non-obvious detail, and a quick testing note

## Common high-value context

These are things worth including in the body. Place them in the appropriate template section when one exists, or inline when writing free-form:

- why the change exists
- the main non-obvious behavior or contract change
- how to test it, when non-obvious
- what is intentionally deferred
- what depends on this PR or was already reviewed before it
- related links (PRs, RFCs, Twist threads, Linear tickets) placed where relevant

## Common review blockers

- correctness or regression risk
- fragile behavior or unsafe rollout
- missing context that prevents confident review
- unresolved cross-repo or stack dependencies

## Common review friction

- titles that do not describe the real change
- bodies that restate the diff instead of explaining it
- bodies that are not concise and objective
- large PRs with no guideposts
- hidden deferred work
- history rewrites that make re-review harder
- treating taste or tiny nits as blockers

## Ask Spoke topics

Ask Spoke about:

- stacked PR context and TODO markers
- preserving re-reviewability after comments start
- moving PRs back to draft for substantial changes
- blocking only for genuinely important issues
