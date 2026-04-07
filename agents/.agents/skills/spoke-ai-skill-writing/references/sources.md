# Upstream Documentation Sources

Public documentation for the Agent Skills ecosystem, organized by harness.

Last verified: April 2026.

## Agent Skills Specification

The open standard that all harnesses build on.

- [Specification](https://agentskills.io/specification) — frontmatter schema, package layout, progressive disclosure model
- [Quickstart](https://agentskills.io/skill-creation/quickstart)
- [Best Practices](https://agentskills.io/skill-creation/best-practices)
- [Optimizing Descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- [Using Scripts](https://agentskills.io/skill-creation/using-scripts)
- [Evaluating Skills](https://agentskills.io/skill-creation/evaluating-skills)
- [What Are Skills](https://agentskills.io/what-are-skills)
- [Client Implementation Guide](https://agentskills.io/client-implementation/adding-skills-support) — for harness authors adding skill support

## Claude Code

Extends the spec with `user-invocable`, `context`, `paths`, `hooks`, `shell`, `model`, `effort`, and other Claude-specific fields.

- [Skills](https://code.claude.com/docs/en/skills) — discovery, frontmatter, bundled files, permissions, slash invocation, string substitutions, dynamic context

## OpenCode

Follows the spec. Discovery walks from cwd to git worktree root for project paths.

- [Skills](https://opencode.ai/docs/skills) — scan paths, frontmatter, permissions, per-agent overrides

## GitHub Copilot

Supports skills in cloud agent, CLI, and VS Code agent mode.

- [About Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) — overview, project and personal scan paths
- [Creating Skills (general)](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills) — frontmatter, skills vs custom instructions
- [Creating Skills (CLI)](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills) — CLI-specific commands, slash invocation, `allowed-tools`
- [Customization Cheat Sheet](https://docs.github.com/en/copilot/reference/customization-cheat-sheet) — quick reference for all customization types
- [Comparing CLI Features](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/comparing-cli-features) — skills, tools, hooks, agents, plugins

## Hermes Agent

Hermes documents discovery, slash commands, progressive disclosure, `SKILL.md` format, external skill directories, and the skills hub.

- [Skills System](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills/) — discovery, slash commands, progressive disclosure, `SKILL.md` format, external skill directories, skill hub
- [CLI Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) — `hermes skills` commands and related workflow
- [GitHub Repository](https://github.com/NousResearch/hermes-agent) — source of truth for implementation details when behavior and docs diverge
