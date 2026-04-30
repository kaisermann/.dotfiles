# Runtime Lens

Use this lens when the main risk is production behavior under retries, concurrency, partial failure, deploy overlap, or operational visibility.

## Focus

This lens focuses on:

- transaction and retry safety
- idempotency and duplicate delivery handling
- partial-failure behavior and recovery shape
- observability on risky paths
- deployment and config semantics that change runtime behavior

If the question is "what happens in production when this runs twice, fails halfway, or rolls out gradually?", start here.

## Default Heuristics

- Assume retries, duplicate delivery, timeouts, and overlapping deploys are real.
- Keep side effects out of retryable transaction bodies.
- In transactions, all reads happen before all writes.
- Require useful logs, metrics, or traces on risky paths.
- Treat infra, monitor, IAM, rollout, and config semantics as production behavior, not boilerplate.
- Silent failure on a critical path is usually worse than a visible failure.
- Prefer static log messages with structured context. Dynamic log strings are harder to group, query, and alert on.
- Review rollout and deploy changes for pause points, signal quality, and rollback speed, not just steady-state correctness.

## High-Signal Pattern Types

- reads after writes inside a transaction
- side effects such as email, webhooks, or events inside retryable critical sections
- write paths without idempotency or conflict strategy under duplicate delivery
- handlers or jobs that can fail halfway with no recovery or operator visibility
- rollout plans that assume old and new instances do not coexist
- config or monitor definitions that will not behave the way the author thinks in the real environment
- risky paths with missing logs, structured context, traces, or metrics
- dynamic log messages that bury the stable failure mode inside interpolated text
- `.then/.catch` chains, empty catches, or early returns that swallow unexpected failures silently

## Pattern Anchors

- Transaction models that require all reads before writes should be reviewed as correctness, not style.
- If an email, webhook, or event emission lives inside a retryable transaction body, it can fire on every retry.
- Deployments are rarely atomic. Old and new codepaths may run together during rollout.
- Prefer structured logs that preserve the error object and execution context, not stringified errors or swallowed failures.
- A monitor threshold or environment config that cannot actually degrade the way the author expects is a runtime bug, not config trivia.
- Webhook and at-least-once delivery paths need idempotency because duplicates are part of the delivery model.
- A rollback path that is slow, manual, or ambiguous increases runtime risk even if the code path itself looks correct.

## Severity Anchors

### Flag As Critical

- likely data corruption or duplicate side effects under retries or concurrency
- transaction ordering violations
- silent failure in a critical path
- dangerous rollout, infra, or config assumptions with high blast radius
- runtime changes that cannot be diagnosed because observability is missing where it matters
- risky changes with no clear rollback or pause strategy

### Flag As Warning

- weak error handling around risky operations
- incomplete logging, tracing, or metrics for important execution paths
- retry semantics that are plausible but not clearly safe
- deployment or config changes that need stronger validation
- missing context in error logs for failures operators will need to debug

## Usually Ignore

- low-risk runtime detail with no blast radius
- purely structural cleanup that does not affect execution behavior
- logging preferences when the current visibility is already sufficient
- theoretical failure paths with no realistic trigger in the current change

## Review Moves

- Ask what happens on retry, timeout, duplicate delivery, and partial success.
- Check whether all reads happen before writes in transactions.
- Check whether failures leave the system inconsistent, invisible, or impossible to debug.
- Check whether deploy overlap or old/new consumer coexistence changes the safety story.
- Read local docs for operational caveats before assuming environment behavior.
- Ask whether logs, metrics, and rollout signals will group the failure cleanly enough for fast diagnosis.
- Ask whether the safest first response in production would be rollback, and whether this change makes that easy.

## Anti-Pattern Examples

1. Retryable code path with non-idempotent side effects.
2. Reads after writes inside a transaction.
3. Partial failure with no recovery or visibility.
4. High-risk runtime path with weak structured logging or metrics.
5. Config or infra change that assumes production parity without proof.
6. Rollout assumption that ignores old and new versions coexisting.
