# Naming and API Shape

Naming should match the established product language, and exported surfaces should describe the behavior they actually represent. Sam flags terminology drift quickly because it creates low-grade confusion across schema, backend, and product surfaces.

## Naming Consistency

**What to look for:**

- Renames that make an established domain term less accurate or less general.
- New field names that diverge from the wording already used in adjacent models, UI, or project docs.
- Action names that are vague about what sync or side effect they represent.
- Response field renames where the new name changes what the count or value actually means.
- Names that are technically inherited from another type but still confusing in the new context.

**Severity:** Warning when the name is misleading or causes cross-layer inconsistency. Info when the name is merely a bit awkward.

**Corpus examples:**

- _"Not sure if I like this name though, so if you have any other suggestions plz lemme know"_ (domain #1243)
- _"This action name is slightly vague, with the intention that we can also add the member -> user sync in here too given how similarly it behaves"_ (backend-services #3292)
- _"why did we rename it from `paymentOnDelivery` to `cashOnDelivery` ... I think it would be clearer if we just called it payment everywhere"_ (domain #1226)
- _"This is now the count of deliveries not the count of pickups, hence the rename"_ (domain #1219)

## API Shape and Forward-Looking Surface Design

**What to look for:**

- API additions that obviously need a nearby filtering or shaping capability to stay coherent.
- New surface area that hard-codes current assumptions instead of leaving room for the next likely use case.
- Request or response types that force consumers to reinterpret fields because names and semantics no longer line up.

**Severity:** Info for future-facing suggestions. Warning when the current shape is already awkward for callers.

**Corpus examples:**

- _"Not directly related to this PR but I assume we'll want to add some filtering options for startsAt like we have for plans"_ (backend-services #3262)

## Anti-Patterns

1. **Terminology drift** - Introducing a new name that conflicts with the established product term.
2. **Inherited but confusing names** - Keeping a borrowed field name even when it is misleading in the new model.
3. **Vague action names** - Trigger/action identifiers that hide what is actually being synchronized.
4. **Semantic rename mismatch** - Renaming a field without making the new semantics obvious to callers.
