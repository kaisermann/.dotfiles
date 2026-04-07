# Harness Compatibility Reference

Skill discovery paths and constraints across agent harnesses.

Last verified: April 2026.

## Skill Discovery Paths

All harnesses discover skills from `SKILL.md` files in conventional directories. The portable locations that work everywhere:

**Personal skills** (shared across projects):
- `~/.agents/skills/<skill-name>/SKILL.md`
- `~/.claude/skills/<skill-name>/SKILL.md`

**Project skills** (workspace-scoped):
- `.agents/skills/<skill-name>/SKILL.md`
- `.claude/skills/<skill-name>/SKILL.md`

Harness-specific locations also work but are not portable:
- Copilot CLI: `.github/skills/`, `~/.copilot/skills/`
- OpenCode: `.opencode/{skill,skills}/`, `config.skills.paths`, `config.skills.urls` (remote registries)
- Hermes: `~/.hermes/skills/`, bundled `/skills/`, `/optional-skills/`
- Claude Code: managed/policy paths, bundled skills, plugin-provided skills

On invocation, the full `SKILL.md` body and bundled directory contents are injected into the agent's context. Hermes is the exception: it uses progressive 3-tier disclosure (list > full SKILL.md > specific bundled file) instead of injecting everything at once.

## Harness Constraints

| Constraint               | OpenCode         | Claude Code     | Hermes          | Copilot CLI |
| ------------------------ | ---------------- | --------------- | --------------- | ----------- |
| `name` required          | yes              | no              | yes (max 64)    | yes         |
| `description` required   | yes              | yes             | yes             | yes         |
| Description char budget  | no cap           | 250 in listings | 1024            | no cap      |
| Conditional activation   | no               | `paths:`        | `platforms:`, prerequisites | no |
| Context injection        | full SKILL.md    | full SKILL.md   | 3-tier progressive | full SKILL.md + directory |
| Remote registries        | `config.skills.urls` | no         | no              | no          |
