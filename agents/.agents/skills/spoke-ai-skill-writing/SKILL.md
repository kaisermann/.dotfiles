---
name: spoke-ai-skill-writing
description: Write and edit portable agent skill packages (SKILL.md). Use when creating, editing, or reviewing skill packages for any harness.
---

How to write portable, self-contained skill packages for Spoke repositories and personal use.

Skill authoring rules and checklist: `references/skill-authoring.md`
Harness compatibility and discovery paths: `references/harness-reference.md`
Upstream documentation links: `references/sources.md`

## Writing a New Skill

1. **Define the trigger surface.** What task or situation loads this skill? What does it give the agent that it lacks? Which existing skills might overlap, and how is this one distinct?

2. **Write the description.** Draft `description` frontmatter. Must include both function and trigger. Must stay under 250 chars. Front-load key trigger words.

3. **Write SKILL.md.** Structure it as:
   - Skill dependencies (short prose near the top, only when composing other skills)
   - When to use (if not obvious from the description)
   - Prerequisites (what must exist)
   - Workflow steps (the main procedure)
   - Guardrails (constraints, common mistakes)

4. **Bundle supporting files.** Move reference material, lookup tables, and validation scripts into subdirectories. Reference bundled files with relative paths from the skill root. When the skill produces structured outputs, bundle the output shape as a file rather than describing it in prose.

5. **Validate.** Run through the checklist in `references/skill-authoring.md`.

## Editing an Existing Skill

1. Check `description` stays under 250 chars.
2. Verify bundled file references still resolve (relative paths from skill root).
3. Run through the checklist in `references/skill-authoring.md`.

## Quick Reference

```yaml
---
name: my-skill-name
description: {What it does + when to use it. Under 250 chars.}
---
```

```text
my-skill/
  SKILL.md          # routing + execution instructions
  scripts/          # executable helpers the skill runs
  references/       # extra docs the skill reads on demand
  assets/           # templates, schemas, static resources
```

SKILL.md is the routing and execution layer. Keep it under ~500 lines. Longer reference material goes in `references/` or `assets/`.

## Guardrails

- Assume the model is smart. Add domain-specific constraints it lacks, not generic explanation.
- Do not duplicate content between a skill's SKILL.md and its reference files. SKILL.md routes; references hold the detail.
- No redundant H1 in SKILL.md that repeats the skill name. Frontmatter already names it.
- Avoid self-referential phrasing ("this skill does...") unless the distinction is necessary.
- Templates and handoff formats should be optional unless the workflow truly requires a fixed output shape.
- Skills and instruction files (AGENTS.md) solve different problems. For instruction file guidance, load `spoke-ai-instruction-writing` instead.
