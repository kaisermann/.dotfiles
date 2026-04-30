# State Transitions and Edge Cases

Small boolean checks often hide the real product behavior. Sam pays close attention to whether a condition actually matches the transitions users can trigger in the app.

## Current-State Assumptions

**What to look for:**

- Checks against legacy state flags that are no longer written.
- Conditions that assume only one path exists between statuses.
- Trigger predicates that observe one field but miss another field that can change independently.
- Logic that handles the nominal flow but not the quick action or shortcut users actually take.

**Severity:** Critical when the condition can miss a real production transition. Warning when the state assumption is stale or incomplete.

**Corpus examples:**

- _"We don't set `optimizing` anymore"_ (backend-services #3258)
- _"Technically it's possible for `succeeded` to change without `attempted` changing. If the driver marks it as failed then they can swipe on the item in the list to change it straight to delivered without first changing it to unattempted, which seems like this check would miss"_ (backend-services #3279)

## Linked-Behavior Edge Cases

**What to look for:**

- Consolidated or linked-stop flows where selected and unselected children behave differently.
- Response payloads that drop data still needed to decide which warning or copy path to show.
- Counts that change meaning across related workflows but keep the same name.

**Severity:** Warning when the UI or handler would make the wrong decision for part of the flow. Info when the response is intentionally carrying extra state for wording or UX branching.

**Corpus examples:**

- _"We're removing the option of including the unselected pickups, so we don't need this info now. We just warn the user it will break the link"_ (domain #1219)
- _"The dialog changes wording depending on whether some of the deliveries are selected or all of them are missing, so we need that info returned"_ (domain #1219)

## Anti-Patterns

1. **Stale status checks** - Guarding on a field that is no longer part of the current workflow.
2. **Single-path transition logic** - Assuming users can only move through states one way.
3. **Dropped branching data** - Removing response fields that still drive valid UX or workflow decisions.
4. **Semantic count reuse** - Reusing a count field name after the counted thing changed.
