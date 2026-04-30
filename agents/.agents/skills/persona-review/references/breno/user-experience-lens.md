# User Experience Lens

Use this lens when the main risk is user confusion, operator confusion, unstable translation structure, or doc drift around a visible behavior change.

## Focus

This lens focuses on:

- user-visible behavior and terminology
- copy clarity and product-language consistency
- translation structure and message declaration quality
- nearby docs and README drift for visible flows
- explanation of non-obvious UI, CSS, and interaction workarounds

If the question is "what will the user, operator, translator, or next engineer understand from this surface?", start here.

## Default Heuristics

- Keep one coherent user-facing term for the same concept across code, UI, and nearby docs.
- Prefer one translatable string when the message is conceptually one sentence.
- Avoid conditional translation IDs when explicit message declarations are possible.
- Explain non-obvious UI, CSS, or state-management workarounds.
- If the visible state changed, check whether local docs changed too.
- Prefer explicit, stable message declarations over ad hoc descriptor creation in render paths.

## High-Signal Pattern Types

- copy that misdescribes what the system does or who owns the concept
- fragmented translation strings that should be one message with interpolation or rich-text placeholders
- conditional message IDs that weaken extraction, auditing, or translator context
- UI states that are hidden, disabled, empty, loading, or error without clearly telling the user what happened
- nearby docs, screenshots, or READMEs that still describe the old user flow
- selector-heavy CSS or interaction workarounds with no explanation
- option docs or JSDoc that restate the name but not the actual behavior

## Pattern Anchors

- One conceptual sentence should usually be one translatable message.
- Avoid conditional IDs when explicit declarations would keep message identity stable.
- If a service is disabled rather than gone, the visible state should make that clear; hiding it entirely can erase useful meaning.
- If a layout or interaction fix depends on selector tricks, important modifiers, or another non-obvious workaround, add a short comment that explains why.
- If an option behaves differently across contexts or platforms, the docs should explain the behavior, not just repeat the option name.

## Severity Anchors

### Flag As Critical

- user-visible behavior that is likely wrong, misleading, or blocks a core flow
- copy or UI state that causes users to misunderstand an irreversible or important action
- docs drift that will cause operators or users to use the feature incorrectly

### Flag As Warning

- awkward or misleading copy
- unstable i18n structure
- unclear empty, loading, disabled, or error states
- missing explanation for non-obvious styling or interaction workarounds
- local docs or README drift around a changed user flow

## Usually Ignore

- purely aesthetic preference with no clarity or usability effect
- local wording alternatives that preserve the same meaning
- backend-only changes with no user-visible consequence
- copy or layout bikeshedding when the current behavior is already clear

## Review Moves

- Check whether nearby docs and READMEs still describe the user flow correctly.
- Prefer stable message declarations and single-message translation structure.
- Ask whether the visible state communicates hidden, disabled, empty, loading, or error conditions clearly.
- Ask whether the next engineer will understand the workaround without guessing.
- Check whether code and docs use the same user-facing term for the same concept.

## Anti-Pattern Examples

1. Confusing or contradictory user-facing state.
2. Copy that misstates behavior or ownership.
3. Conditional or fragmented i18n structure that weakens translation quality.
4. Missing doc update for a changed user flow or visible behavior.
5. Unexplained CSS or interaction workaround that future readers must reverse-engineer.
6. JSDoc or option docs that name the feature but do not explain the behavior.
