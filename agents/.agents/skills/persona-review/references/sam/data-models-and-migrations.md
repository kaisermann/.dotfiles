# Data Models and Migrations

Source-of-truth choices, derived fields, sync mechanisms, and rollout shape. Sam is especially sensitive to designs that can drift silently because two representations of the same concept are allowed to evolve independently.

## Source of Truth and Drift Risk

**What to look for:**

- A new derived field introduced without a durable mechanism that guarantees it stays in sync with the original field.
- Parallel fields where the types do not force both writes to happen together.
- Trigger-backed synchronization that only covers some write paths.
- Migrations that add a second representation of the same concept without a clear long-term ownership story.

**Severity:** Critical when the design can silently drift in production. Warning when the sync story exists but still looks partial.

**Corpus examples:**

- _"there would be nothing stopping someone forgetting that roleMap also exists and just writing to roles. The types wouldn't force you to also update that field, so there's always the risk that they become out of sync"_ (domain #1243)
- _"With triggers we write it once and can ensure they stay in sync"_ (domain #1243)
- _"I'll do both, so it will write it when setting `roles` but then also the trigger will be there to guarantee it's in sync"_ (domain #1243)

## Migration Proportionality

**What to look for:**

- Multi-stage backward-compatibility work proposed for a change with only one simple consumer.
- Single-step field swaps attempted when the model has multiple consumers or a complex migration path.
- PRs that remove an old field before the paired consumer change is ready to land.
- Schema changes that are safe only if another PR merges almost immediately.

**Severity:** Warning when the migration strategy does not match the actual blast radius. Info when the reviewer is making a scope-vs-safety tradeoff explicit.

**Corpus examples:**

- _"This is only in use by engine right now and so it's very simple to swap over"_ (domain #1219)
- _"I won't merge this until the corresponding engine PR is ready to be merged in, and then we effectively merge them both within a couple minutes of each other"_ (domain #1219)
- _"If there were more usages, or it was a complex transition, then I agree it makes sense to do a multi-stage migration"_ (domain #1219)

## Anti-Patterns

1. **Dual source of truth** - Two writable fields representing the same concept without hard guarantees of sync.
2. **Partial sync coverage** - Trigger or write-path updates that miss some mutations.
3. **Over-engineered migration for a local change** - Adding staged compatibility work when usage is narrow and coordination is easy.
4. **Under-engineered migration for a broad change** - Direct swaps on widely used fields without staged rollout.
