# Boundary Lens

Use this lens when the main risk is duplicate abstraction, wrong ownership, wrong placement, or dependency direction drift.

## Focus

This lens focuses on:

- reuse vs reinvention
- module seams and ownership boundaries
- file and package placement
- dependency direction
- whether a new abstraction earns its existence
- minimizing the surface area passed between units

If the question is "should this helper, hook, wrapper, or module exist here at all?", start here.

## Default Heuristics

- Prefer an existing shared helper, hook, builder, selector, or package abstraction when one already fits.
- Keep code local until reuse is real.
- Treat import direction and placement as architecture, not style.
- Pass only the dependencies actually needed.
- A new abstraction must remove real complexity, not just move it.
- When suggesting reuse, name the existing abstraction and where it lives.

## High-Signal Pattern Types

- a new helper that overlaps with an existing query constructor, selector, URL builder, hook, or test utility
- a hook, wrapper, or context that only forwards one primitive call
- app-specific behavior pushed into a shared package because it felt reusable
- a less-specific module importing from a more-specific page, route, or feature
- a function receiving an entire object or context when it only uses two fields
- a barrel or re-export layer that hides real ownership and creates confusing dependency paths
- a file placed in `hooks/`, `utils/`, or a shared package even though its behavior is feature-local

## Pattern Anchors

- Reuse existing selectors, query builders, shared hooks, or other established abstractions instead of rebuilding them locally.
- If a feature only needs one small transformation, one Dispatch-specific mapping, or one local adapter, a new abstraction may be worse than a small local implementation.
- Keep page-local contexts and single-use components near their consumers instead of promoting them upward too early.
- A module inside a generic package should not quietly absorb product- or app-specific behavior.
- If a file lives in `hooks/` but is not actually a hook, the placement is misleading even if the code works.

## Severity Anchors

### Flag As Critical

- dependency direction that breaks a core architectural boundary
- abstraction changes that create unsafe ownership confusion between systems or packages
- shared modules that centralize the wrong responsibility and are likely to spread incorrect structure quickly

### Flag As Warning

- reinvention of an existing helper or package-level pattern
- wrappers, hooks, or contexts that add indirection without reducing complexity
- misleading module placement or naming
- overly broad inputs that increase coupling
- app-specific code placed in a shared package without a strong reason

## Usually Ignore

- local decomposition that improves readability without widening the surface area
- small helper extraction when the ownership and dependency shape stay clean
- benign structure preferences that do not change maintenance cost meaningfully
- abstraction alternatives when the submitted code already follows an established local pattern

## Review Moves

- Search for an existing abstraction before endorsing a new one.
- Ask whether the code lives too high, too low, or in the wrong package.
- Ask whether the wrapper, hook, or context earns its existence.
- Check whether import direction reflects the ownership model.
- Prefer explicit ownership and narrow dependencies over structural convenience.

## Anti-Pattern Examples

1. New abstraction with no new capability.
2. Cross-boundary import that reverses ownership.
3. Shared-package addition that should remain app-local.
4. Helper or hook whose name and placement imply the wrong abstraction.
5. Broad dependency passing that couples the callee to unrelated state.
6. Structural cleanup that hides control flow or true ownership.
