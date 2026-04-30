# State Lens

Use this lens when the main risk is source-of-truth drift, incomplete lifecycle modeling, or state transitions that do not match real user behavior over time.

## Focus

This lens focuses on:

- authoritative field and model choice
- lifecycle and transition correctness
- derived-field and trigger-backed drift risk
- persisted visibility for hidden, disabled, historical, or partial states
- migration shapes insofar as they preserve state meaning over time

If the question is "which field or status is authoritative, and does that stay true over time?", start here.

## Default Heuristics

- Keep one clear source of truth.
- Treat derived fields, trigger sync, and dual representations as drift risks until proven durable.
- Make transitions and hidden states explicit when users or operators need to reason about them later.
- Prefer migration shapes that let old and new representations coexist when necessary.
- Question guards that assume users move through states only one way.
- Treat migrations, triggers, and backfills as operational code paths that need safe reruns, clear checkpoints, and tolerable intermediate states.

## High-Signal Pattern Types

- new and old fields both acting like the source of truth
- a compatibility field that is kept, but no durable sync story explains how it stays correct
- hidden, disabled, refunded, historical, or inactive states represented only in UI logic instead of persisted explicitly
- migration logic that assumes existing records are already complete or that every writer moves first
- response or model cleanup that removes data still needed to choose the correct UX branch
- transition guards that rely on stale flags or the nominal path only
- sync logic that writes one path but misses another legitimate write path

## Pattern Anchors

- If a new representation is the real future model, make it authoritative and keep the legacy shape only as a compatibility field with an explicit sync story.
- If a service or option is no longer available, ask whether it should be hidden, disabled, or historically visible. UI-only hiding is often not enough.
- If refunds, deactivations, or similar lifecycle events matter later to users or operators, they usually need persisted state or history.
- If a status is no longer written, transition guards that still check it are stale.
- If users can jump from failed to delivered through a shortcut path, a guard that only models the normal path is incomplete.

## Severity Anchors

### Flag As Critical

- competing sources of truth that can drift silently
- migration or coexistence logic likely to corrupt, orphan, or misrepresent state
- missing persisted state or history needed for users or operators to understand what happened
- lifecycle changes that break invariants across systems
- stale or incomplete transition guards that miss a real user path

### Flag As Warning

- ambiguous ownership of state transitions
- missing disabled, inactive, or transitional states
- partial lifecycle modeling that ignores realistic edge cases
- derived-field or trigger-backed sync that is plausible but not clearly durable
- cleanup that drops branching data still needed for wording, warnings, or behavior

## Usually Ignore

- local code movement that does not change how state is stored or interpreted
- low-risk schema cleanup with no migration effect
- implementation detail changes beneath a stable and well-modeled lifecycle
- transition-adjacent cleanup when the authoritative state model stays intact

## Review Moves

- Ask which field or document is the actual source of truth.
- Ask how compatibility fields stay in sync, and through which write paths.
- Ask whether users or operators need disabled, inactive, or historical visibility.
- Ask whether a real shortcut or edge flow bypasses the coded transition guard.
- Check local docs and RFCs for lifecycle definitions and migration assumptions.
- Ask whether old data, partially migrated data, and newly written data all behave acceptably during rollout.

## Anti-Pattern Examples

1. Two fields both treated as authoritative.
2. Compatibility field kept without a durable sync story.
3. Frontend-only or runtime-only hidden state for an important product condition.
4. Lifecycle design with missing persisted history or edge states.
5. Transition guard that assumes only one user path through the workflow.
6. Cleanup that removes state needed to choose a valid behavior branch.
