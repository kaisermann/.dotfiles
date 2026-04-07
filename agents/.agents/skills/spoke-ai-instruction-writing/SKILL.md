---
name: spoke-ai-instruction-writing
description: Write effective instructions for AI agents — AGENTS.md files, role snippets, briefings, custom instructions. Use when writing or reviewing any durable agent-facing text.
---

How to write durable, effective instructions for AI agents. Covers both general instruction-writing principles and the AGENTS.md repo-level format.

General principles for writing agent instructions: `references/writing-for-agents.md`
AGENTS.md spec, structure, and content guidance: `references/instruction-files.md`
Upstream documentation links: `references/sources.md`

## When to Use

- Writing or editing an `AGENTS.md` or `CLAUDE.md` file
- Writing role snippets, briefings, or custom instructions for agents
- Reviewing any durable text meant to instruct an AI agent
- Deciding what belongs in an instruction file vs a skill vs a knowledge doc

For general principles on wording, structure, and common failure modes, read `references/writing-for-agents.md`.

## Writing or Reviewing AGENTS.md

Read `references/instruction-files.md` for the full spec. The key principles:

- **Lean over comprehensive.** If it is in `docs/`, do not repeat it.
- **Route, don't teach.** The instruction file is a router to the right doc, not a tutorial.
- **Repo-specific only.** If a rule spans repositories, it belongs in the knowledge base.

Required sections in every AGENTS.md:

1. One-liner description (first line, no heading)
2. Spoke Knowledge Base routing (presence-based two-liner)
3. Find the right doc (task-to-doc mappings pointing to `docs/`)
4. Gotchas (one-line non-obvious constraints)
5. Do not (hard constraints)

## Monorepos

For monorepos, place nested `AGENTS.md` files in subprojects. The nearest file takes precedence. See `references/instruction-files.md` for rules.

## Keep vs Route

Keep in AGENTS.md: local commands, workspace names, file placement rules, deployment behavior, repo-specific gotchas.

Route to the knowledge base: cross-repo architecture, shared package rules, migration rules, testing philosophy, naming rules that span repos.

## Claude Code Bridge

Claude Code does not read `AGENTS.md`. Repos must provide a `CLAUDE.md` with `@AGENTS.md` import. See `references/instruction-files.md` for the pattern.

## Guardrails

- Instruction files and skill packages solve different problems. For skill authoring guidance, load `spoke-ai-skill-writing` instead.
- Read `references/writing-for-agents.md` before writing any instruction content. The patterns apply to AGENTS.md, briefings, role snippets, and custom instructions equally.
- No template sections with no content. Every section earns its place.
