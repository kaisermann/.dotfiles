---
name: spoke-ai-skill-writing
description: Write and edit portable agent skill packages (SKILL.md). Use when creating, editing, or reviewing skill packages for any harness.
---

Write or review portable `SKILL.md` packages and their bundled agent-facing support files.

Skill authoring rules and checklist: `references/skill-authoring.md`
Harness compatibility and discovery paths: `references/harness-reference.md`
Upstream documentation links: `references/sources.md`

## When to Use

- Creating a new skill package
- Editing or reviewing an existing skill package
- Checking whether a skill is routing clearly and staying portable across harnesses

## Workflow

1. Read `references/skill-authoring.md`.
2. If loader behavior or portability matters, check `references/harness-reference.md`.
3. Keep `SKILL.md` limited to trigger, workflow, guardrails, and bundled-file routing.
4. Move deeper detail into `references/`, `assets/`, or `scripts/`.
5. Validate with the checklist in `references/skill-authoring.md`.

## Guardrails

- Opening lines must make clear what the skill is useful for and when it should be applied.
- Treat `description` as the primary routing decision. It should tell the agent what kind of task this skill owns, not just the general domain.
- Keep `SKILL.md` short. Delete lines that do not change routing, execution, or constraints.
- Do not duplicate content between `SKILL.md` and bundled references. `SKILL.md` routes; bundled files hold the detail.
- Make the skill's usefulness and trigger legible near the top. Do not rely on frontmatter alone once the file is loaded.
- In this repo, skill packages are agent-facing. If a workflow needs human-facing documentation, link to the canonical doc in `content/` or `docs/` instead of bundling a second copy inside the skill package.
- Skills and instruction files (AGENTS.md) solve different problems. For instruction file guidance, load `spoke-ai-instruction-writing` instead.
- Review `SKILL.md` with the skill-writing spec first. Judge routing clarity, trigger clarity, scanability, and execution usefulness before applying any human-document prose preferences.
