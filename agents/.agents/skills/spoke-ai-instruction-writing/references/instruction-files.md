# Instruction File Reference

How to write and maintain repo-level agent instruction files (AGENTS.md) in Spoke repositories.

## Purpose

Spoke repositories use `AGENTS.md` as the canonical shared agent instruction file. Tool-specific files like `CLAUDE.md` import or extend it when needed.

The file should orient readers quickly: what this repo is, where to find docs, and what to watch out for. Nothing more.

## Principles

- **Lean over comprehensive.** If it is in `docs/`, do not repeat it in the instruction file.
- **Route, don't teach.** The instruction file is a router to the right doc, not a tutorial.
- **No cross-repository duplication.** Domain context, product descriptions, shared patterns, and process docs belong in the knowledge base, not in each repo's instruction file.
- **Route shared code rules to the knowledge base.** If a coding rule also applies in sibling repos, point to the knowledge base instead of restating it locally.
- **Repo-specific only.** If changing the content requires updating only one repo, it can live here. If it spans repositories, it belongs in the knowledge base.
- **Retrieval-first.** Write for retrieval and scanability. Short sections, explicit headings, and direct task routing help both agents and humans.
- **Prefer deletion over compression.** If a sentence does not route, constrain, or warn, cut it instead of rewriting it into softer filler.
- **Use the right spec for the audience.** `AGENTS.md` is an agent-facing instruction file, not a human doc. Review it with agent-writing rules first, not knowledge-base or human-document prose rules.
- **Keep file classes separate.** In this repo, `skills/` are agent-facing packages. Human-facing documentation belongs in `content/` or `docs/`; agent instruction files should link to those docs instead of duplicating or rebundling them.

## Required Sections

### 1. One-liner description

First line, no heading. What this repo is and its tech stack in one sentence. Must stand alone in previews and make sense to a reader opening the file cold.

### 2. Spoke Knowledge Base

Two-liner. Presence-based: if the knowledge base exists, use it. No setup instructions, no prompting if it is absent.

```markdown
## Spoke Knowledge Base

If `~/.spoke-knowledge/` exists, load the `spoke-knowledge` skill for cross-repository context (domain, products, architecture, shared patterns).
```

Use this section to route shared coding constraints too, not just product or architecture context.

### 3. Find the right doc

Section titled `## Find the right doc`. A Markdown list that routes common tasks to the right `docs/` file. Every repo with a `docs/` directory should have this.

```markdown
## Find the right doc

- Create or modify an endpoint? -> docs/creating-endpoints.md
- Run tests or write new tests? -> docs/testing.md
```

Rules:
- Each leaf points to a file in `docs/` or a README in the repo
- No external links or knowledge base references here; this is for repository-local routing
- Order by frequency: most common tasks first
- Phrase entries as task-to-doc mappings, not vague categories
- Do not add entries that route back to the instruction file itself

### 4. Gotchas

Section titled `## Gotchas`. Short bullet list of non-obvious constraints that are hard to discover from code alone: naming mismatches, validation quirks, cross-repository coupling, implicit limits.

Keep each gotcha to one line. If it needs explanation, it belongs in a doc.

### 5. Do not

Section titled `## Do not`. Hard constraints: files not to touch, patterns to avoid, things that break production.

## Optional Sections

The 5 required sections establish the routing skeleton. Most repos also need sections for content from the Include list (see Content Guidance below) that does not fit into the required sections. Common additions:

- **Build and test commands** — how to build, lint, type-check, and run tests
- **Architecture** — key directories, data flow, module boundaries (keep brief; link to `docs/` for detail)
- **Conventions** — naming, file placement, import patterns, error handling specific to this repo
- **Apps table** — workspace names and what they do (useful for monorepos with many apps)
- **Security considerations** — auth patterns, data handling constraints, access boundaries

Add these only when they carry real repo-specific value. Omit sections with nothing to say.

## Monorepos and Nested Files

For large monorepos with distinct subprojects, place a nested `AGENTS.md` inside each package or app directory. Agents automatically read the nearest file in the directory tree, so the closest one takes precedence.

The root `AGENTS.md` covers repo-wide concerns: overall purpose, shared commands, cross-cutting conventions, and the knowledge base routing section. Each nested file adds only what is specific to that subproject: local build commands, testing quirks, file placement rules, gotchas unique to that package.

Rules:
- Do not duplicate root-level content in nested files. A nested AGENTS.md supplements the root, not replaces it.
- Each nested file still follows the same required sections pattern, but sections with nothing repo-local to add can be omitted.
- Keep nested files especially lean — they add to the root context, not replace it.

## Keep vs Route

**Keep in AGENTS.md:**

- Local commands and task runners
- Wrapper commands (document the wrapper rather than teaching readers to run preflight commands separately)
- Workspace names, package filters, and path aliases specific to this repo
- File placement rules that are only true here
- Deployment, environment, and CI behavior unique to this repo
- Gotchas tied to this repo's wiring, naming mismatches, or local tooling

**Route to the knowledge base instead:**

- Cross-repo architecture and data-flow patterns
- Shared package ownership or client usage rules
- Migration and compatibility rules that apply across repos
- Testing philosophy or conventions shared by multiple repos
- Naming rules or product-surface constraints used across Spoke repos

## Anti-patterns

- Copying domain context (products, entities, concepts) into the instruction file
- Duplicating content from `docs/` files
- Telling the reader to start with or read the instruction file itself
- Listing shared coding conventions that should be routed through the knowledge base instead
- Style guides, PR workflow, or commit conventions (these belong in shared knowledge base docs or repo docs, not in the instruction file)
- Long prose sections explaining architecture (write a doc in `docs/` and link to it)
- Template sections with no content
- Giant repo prompts that mix overview, domain lore, workflow, commands, and style rules into one hard-to-scan document
- Headings like `Notes`, `Context`, or `Overview` that do not help a skimming reader find the right section
- Rewriting the file to satisfy human-document style preferences while making task routing or constraint clarity worse
- Pulling human-facing documentation into agent-only files instead of linking to the canonical doc
- Keeping summary prose that repeats the heading or linked doc without adding a new constraint

## Layered Model

Agent configuration uses three layers, from general to tool-specific:

```text
repo-root/
  AGENTS.md                 # Main instructions (all tools)
  CLAUDE.md                 # Imports AGENTS.md for Claude Code
  .agents/                  # Portable structured content
    skills/
  .claude/                  # Tool-specific (symlinks + exclusive features)
    skills/
      my-skill -> ../../.agents/skills/my-skill
```

| Layer            | Location        | Purpose                                                            |
| ---------------- | --------------- | ------------------------------------------------------------------ |
| Instructions     | `AGENTS.md`     | Repo overview, commands, conventions, architecture. Read by all.   |
| Portable content | `.agents/`      | Skills and rules shared across tools. Canonical source.            |
| Tool-specific    | `.claude/` etc. | Symlinks to `.agents/` plus features with no generic equivalent.   |

### File Placement Rule

If the content can be expressed as plain Markdown and consumed by multiple tools, it goes in `.agents/`. If it requires a tool-specific format or feature, it stays in that tool's directory.

### Claude Code Bridge

Since Claude Code does not read `AGENTS.md`, repos must provide a `CLAUDE.md` that imports it:

```markdown
@AGENTS.md

<!-- Claude-specific instructions below -->
```

Do not symlink `CLAUDE.md` to `AGENTS.md` — that prevents adding Claude-specific instructions.

### Tool-Specific Features

These features have no generic equivalent and must stay in their tool's directory:

| Feature             | Tool        | Location                      |
| ------------------- | ----------- | ----------------------------- |
| Slash commands      | Claude Code | `.claude/commands/`           |
| Lifecycle hooks     | Claude Code | `.claude/hooks/`              |
| Output styles       | Claude Code | `.claude/output-styles/`      |
| Agent definitions   | Claude Code | `.claude/agents/`             |
| Permission settings | Claude Code | `.claude/settings.json`       |
| Local user settings | Claude Code | `.claude/settings.local.json` |

## Instruction File Support

| Tool         | `AGENTS.md` | `CLAUDE.md` | `.github/copilot-instructions.md` | Notes                                                              |
| ------------ | :---------: | :---------: | :-------------------------------: | ------------------------------------------------------------------ |
| Copilot      |     Yes     |     Yes     |                Yes                | Reads nearest `AGENTS.md` in directory tree. Also reads `GEMINI.md`. |
| Claude Code  |      No     |     Yes     |                No                 | Reads `CLAUDE.md` and `.claude/` directory.                        |
| OpenCode     |     Yes     |  Fallback   |                No                 | `AGENTS.md` first; `CLAUDE.md` only if no `AGENTS.md`.            |
| Cursor       |     Yes     |      No     |                No                 | Also reads `.cursor/rules/` and `.cursorrules`.                    |
| Windsurf     |     Yes     |      No     |                No                 | Also reads `.windsurfrules`.                                       |
| Aider        | Configurable|      No     |                No                 | Set in `.aider.conf.yml`.                                          |
| Gemini CLI   | Configurable|      No     |                No                 | Set in `.gemini/settings.json`. Also reads `GEMINI.md`.            |

## AGENTS.md Content Guidance

### Include

1. Project overview — what the repo is, its role in the system
2. Tech stack — languages, frameworks, key libraries
3. Build and test commands — how to build, run tests, lint, type-check
4. Architecture — key directories, data flow, module boundaries
5. Conventions — naming, file placement, import patterns, error handling
6. Environment — required env vars (names only, not values), external services
7. Common pitfalls — things agents frequently get wrong in this codebase
8. Security considerations — auth patterns, data handling constraints, access boundaries
9. Commit and PR guidelines — if repo-specific (route to KB if shared across repos)

When a code task depends on shared Spoke rules rather than repo-local detail, route to the knowledge base.

### Exclude

- Secrets or credentials
- Ephemeral instructions (PR-specific guidance, temporary workarounds)
- Verbose API documentation (link to external docs instead)
- Tool-specific syntax (keep AGENTS.md as plain Markdown)
- Bloated domain primers (route to the knowledge base)
- Shared coding conventions copied locally (route to KB if the rule spans repos)
- User-specific role hints committed for everyone
- Narrative setup that hides the rule (put the actionable constraint first)
- Self-referential routing

## Validation After Structural Changes

When a change affects repo structure, path layout, setup flow, or packaged skill layout:

1. Run the repo's validators plus any relevant syntax, build, or test commands.
2. Search for stale paths, old vocabulary, and outdated model terms.
3. Cross-check every affected surface: README.md, AGENTS.md, CLAUDE.md, helper skills, validators, templates, contributor docs.
4. Verify resulting artifacts, not just command success.
5. Use the local checkout as the install source when validating branch-local changes.

## .gitignore Rules

Commit these:
- `AGENTS.md`, `CLAUDE.md`, `.agents/`, `.claude/settings.json`, `.claude/skills/`, `.claude/commands/`

Gitignore these:
- `.claude/settings.local.json`, `.aider*`, `.cursorignore`
