---
name: spoke-ai-instruction-writing
description: Write effective instructions for AI agents — AGENTS.md files, role snippets, briefings, custom instructions. Use when writing or reviewing any durable agent-facing text.
---

Write or review durable agent-facing instruction files such as `AGENTS.md`, `CLAUDE.md`, briefings, and custom instructions.

General principles for writing agent instructions: `references/writing-for-agents.md`
AGENTS.md spec, structure, and content guidance: `references/instruction-files.md`
Upstream documentation links: `references/sources.md`

## When to Use

- Writing or editing an `AGENTS.md` or `CLAUDE.md` file
- Writing role snippets, briefings, or custom instructions for agents
- Reviewing any durable text meant to instruct an AI agent
- Deciding what belongs in an instruction file vs a skill vs a knowledge doc

## Workflow

1. Read `references/writing-for-agents.md`.
2. If you are editing `AGENTS.md`, also read `references/instruction-files.md`.
3. Keep the file focused on routing, constraints, and non-obvious repo guidance. Link out for detail.

## Guardrails

- Keep instruction files short. Delete any sentence that does not change routing, constraints, or execution.
- Review instruction files with this spec first, not with human-document prose rules.
- For `SKILL.md` packages, use `spoke-ai-skill-writing` instead.
- No template sections with no content. Every section earns its place.
