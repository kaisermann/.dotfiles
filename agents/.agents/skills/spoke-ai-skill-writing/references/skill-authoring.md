# Skill Authoring Reference

Full reference for writing portable, self-contained skill packages that work across agent harnesses.

Verified against OpenCode v1.3.13, Claude Code v2.1.88, Hermes Agent v0.6.0 plus public docs, and Copilot CLI public documentation (March-April 2026). Re-verify if any harness changes its skill loader.

For repo-level instruction files, see the `spoke-ai-instruction-writing` skill instead. Skills and instruction files solve different problems and should be authored separately.

## Frontmatter

The portable frontmatter fields:

```yaml
---
name: my-skill-name
description: What the skill does and when the agent should use it. Under 250 chars.
---
```

`name` and `description` are required by OpenCode, Hermes, and Copilot CLI. Claude Code only requires `description` but respects `name` for slash-command matching.

### Constraints

- **`description` max: 250 characters.** Claude Code truncates at 250 chars in skill listings. Other harnesses allow more (Hermes: 1024), but 250 is the safe cross-harness ceiling.
- **`name` max: 64 characters.** Hermes enforces this cap. Use lowercase with hyphens.
- **`description` is the routing field.** All harnesses use it to decide when to load a skill. Front-load the key trigger words. Frame it as a task, not a category label.

Good: `"Cross-repository knowledge for domain rules, architecture, and conventions. Use when the task needs durable context beyond the current repository."`

Bad: `"Knowledge base consumer skill."`

### Harness-Specific Frontmatter

These fields are useful but not portable. Use them deliberately when you need the behavior.

**Claude Code:** `allowed-tools`, `paths` (conditional activation on file patterns), `user-invocable`, `disable-model-invocation`, `context`, `agent`, `effort`, `shell`, `argument-hint`, `arguments`

**Copilot CLI:** `allowed-tools`, `license`

**Hermes:** `version`, `license`, `platforms` (per-platform filtering), `prerequisites.env_vars`, `prerequisites.commands`, `metadata.hermes.tags`, `metadata.hermes.related_skills`, `metadata.hermes.requires_tools`, `metadata.hermes.fallback_for_tools`

Unknown frontmatter fields are silently ignored by all harnesses.

## Package Layout

A skill is a directory with a required `SKILL.md` and optional bundled resources.

```text
my-skill/
  SKILL.md
  scripts/        # executable helpers the skill runs
  references/     # extra docs the skill reads on demand
  assets/         # templates, schemas, static resources
```

All harnesses auto-discover files in the skill directory. Reference bundled files from `SKILL.md` with relative paths from the skill root: `scripts/task.sh`, `references/usage.md`.

The execution form varies by file type, not by harness: `sh scripts/task.sh`, `python scripts/extract.py`, or a plain file reference in prose. Instructions should not depend on a fixed external path when the helper lives inside the skill package.

When a skill produces structured or repeatable outputs, bundle the output shape as a file in `assets/` or `references/` — an example output, a schema, or a fill-in template constrains the agent more reliably than prose descriptions.

## Skill Dependency Declaration

If a skill composes other skills, say so near the top of `SKILL.md` in one or two short prose lines.

```md
Requires `skill-a`.
Use `skill-b` or `skill-c` only when the task needs them.
```

Rules:

- Use skill names only. Do not list scripts, tools, env vars, or external services here.
- Omit dependency prose entirely when the skill does not compose other skills.
- A dependency is another skill the workflow tells the agent to load or rely on, not a general cross-reference.
- Keep the dependency prose close to the top so composition is obvious during routing.

## SKILL.md Scope

`SKILL.md` is the routing and execution layer:

- what the skill does
- when it should load
- the main workflow steps
- which bundled files to read or run

Longer reference material lives in `references/` or `assets/`, not in `SKILL.md`. Keep `SKILL.md` under ~500 lines to preserve context efficiency.

Keep references one level deep from `SKILL.md`. Avoid chains where `SKILL.md` points to a file that points to another file that finally contains the real instructions.

## Skill Package Model

Skills designed for reuse should follow these conventions:

1. **Skills are self-contained packages.** Workflow scripts, templates, reference docs, and static data live inside the skill directory.

2. **Runtime is bundled.** Skills do not depend on external repo paths for execution. External paths appear only when that external resource is the skill's actual target (e.g., a skill that updates a knowledge base reads that knowledge base's directory).

3. **Validation lives in the skill package.** Auth and environment checks can live in the skill's `scripts/` directory, but they are package internals unless the workflow truly needs a standalone diagnostic command.

4. **Task scripts own preflight.** If a skill has an executable entrypoint, that script should run its own preflight checks internally instead of making the agent call a validator as a separate first step.

5. **Validators are local by default.** Duplicate small validators per skill rather than sharing across packages.

6. **Shared helpers stay inside the package.** When one skill has multiple scripts that share code, the shared code lives in the same package (e.g., `scripts/_common.sh`).

7. **Repo-root scripts are maintainer utilities.** If skills live in a repo that also has root-level scripts, those scripts are for repo maintenance, not skill runtime. Installed skills should not call them.

8. **Do not duplicate composed-skill validation.** If a skill composes another skill, let the composed skill validate its own auth and prerequisites instead of re-checking them in the caller.

9. **Capability checks are not always gates.** For orchestration skills with multiple fallback paths, missing tools should often degrade the available workflow rather than block the skill entirely. Reserve hard-stop validators for requirements that are truly mandatory.

## Authoring Rules

### Content and Routing

1. **Put both function and trigger in `description`.** Say what the skill provides and what situations should cause it to load.

2. **Keep `description` under 250 characters.** Front-load key trigger words.

3. **Use unique, literal, lowercase-hyphenated names.** Prevents collision and aids slash-command matching.

4. **Keep `name` under 64 characters.**

5. **Avoid overlap between related skills.** Each skill should have a distinct trigger surface. Two skills that serve the same domain need clearly different triggers so the model never hesitates about which to load.

### Structure and Portability

6. **Use progressive disclosure.** `SKILL.md` is the routing layer. Point to bundled `references/`, `assets/`, or `scripts/` for detail.

7. **Use relative paths from the skill root.** `scripts/task.sh`, not absolute home-directory paths.

8. **Anchor external resource paths once.** When a skill's target resource lives at a fixed location (e.g. a knowledge base repo at `~/.spoke-knowledge/`), mention the full path once in the opening sentence as a parenthetical anchor, then use bare relative paths (`content/...`, `docs/...`) everywhere else. Do not repeat the absolute path on every reference, and do not use blanket "all paths below are relative to" claims — the agent resolves paths from context.

9. **Use harness-specific frontmatter deliberately.** Fields like Claude Code's `paths:` or Hermes's `platforms:` are useful, but don't add them by accident. They are silently ignored by other harnesses, which is fine, but they can create false expectations if you forget they're not portable.

10. **Avoid redundant top-level titles in `SKILL.md`.** Frontmatter already names the skill; a leading H1 that repeats the skill name usually adds no routing or execution value.

### Workflow Quality

11. **Match instruction precision to task fragility.** Exact script commands for risky workflows, looser instructions when multiple approaches are safe.

12. **Prefer verifiable workflows.** Fragile tasks get explicit validate/fix/retry loops and scripts with clear error messages.

13. **Assume the model is smart.** Add domain-specific context and sharp constraints it lacks, not generic explanation it already knows. For dual-audience docs that also serve non-technical readers, domain-specific reasoning that an LLM already knows may still earn its place.

14. **Script examples distinguish file reference from execution form.** When a SKILL.md mentions a script, make it clear whether the model should read it for context or execute it. Use `scripts/foo.sh` for reference, `sh scripts/foo.sh` for execution.

15. **Scope sub-agent permissions explicitly.** When dispatching agents for research or audit, state whether they may write. Default assumption for information-gathering tasks is read-only.

16. **Declare composed skills explicitly.** If a skill depends on other skills, name them near the top in short prose. Skip dependency prose entirely when there are no composed-skill dependencies.

17. **Avoid self-referential phrasing.** Prefer direct instructions over wording like "this skill" unless the distinction is necessary.

18. **Do not force templates by default.** Bundled templates and handoff formats should be optional unless the workflow truly requires a rigid output shape.

19. **Keep validator details out of the agent path.** In `SKILL.md`, route the agent through the task script or core workflow. Mention standalone validators only when the skill genuinely needs a manual diagnostic command.

## Validation Checklist

Run through this after writing or editing a skill.

### Package Structure

- [ ] Skill directory is self-contained (no external runtime dependencies)
- [ ] SKILL.md references bundled files with relative paths from the skill root
- [ ] External resource paths (e.g. a KB repo) are anchored once in the opening, then referenced with bare relative paths
- [ ] No reusable workflow depends on external paths for incidental helpers
- [ ] If an external path is referenced, it is the actual target resource of the skill
- [ ] Reference files are one level deep from SKILL.md (no reference chains)
- [ ] Structured or repeatable outputs have a bundled shape file (example, schema, or template)

### Description

- [ ] `description` says both what the skill does and when to use it
- [ ] `description` stays under 250 characters
- [ ] Key trigger words are front-loaded in the description
- [ ] No overlap with other skills' trigger surfaces

### SKILL.md Quality

- [ ] SKILL.md stays under ~500 lines
- [ ] Action-oriented: the agent executes this, not studies it
- [ ] No redundant H1 that just repeats the skill name
- [ ] If the skill composes other skills, that dependency is named near the top in short prose
- [ ] If dependency prose is present, it lists only skill-to-skill dependencies
- [ ] No unnecessary self-referential phrasing like "this skill"
- [ ] Script examples distinguish file reference from execution form
- [ ] If the skill has an executable entrypoint, that task script owns any preflight validation internally
- [ ] Prerequisites are checked explicitly (validators, env checks)
- [ ] Validators only hard-stop on truly mandatory requirements
- [ ] SKILL.md uses the task script or core workflow as the default path and does not expose validator internals unless manual diagnosis is genuinely part of the skill
- [ ] Composed skills do not duplicate another skill's auth or prerequisite checks
- [ ] Risky workflows use exact commands and validation loops
- [ ] Assumes the model is smart: adds domain constraints, not generic explanation
- [ ] Templates or handoff formats are optional unless the workflow truly requires a fixed output shape

### Naming and Portability

- [ ] Name is unique, literal, lowercase-hyphenated
- [ ] Name is under 64 characters
- [ ] Harness-specific frontmatter fields used deliberately, not by default
