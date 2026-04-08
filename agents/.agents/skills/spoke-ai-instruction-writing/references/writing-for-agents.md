# Writing Instructions for AI Agents

Principles for writing durable, effective text that instructs AI agents. Applies to AGENTS.md files, role snippets, briefings, custom instructions, and any other persistent agent-facing content.

These patterns come from repeated instruction-writing and review work. They are not universal prompting tips; they are for durable instruction files that persist across sessions and shape agent behavior over time.

## Repo Surfaces

In `~/.spoke-knowledge`, the audience boundary is mostly structural.

- `content/` contains durable knowledge docs read by both people and agents.
- `skills/`, `briefings/`, and persistent instruction files such as `AGENTS.md` are agent-facing.

Review `AGENTS.md`, `CLAUDE.md`, briefings, and other agent instruction files with the agent-writing rules in this package first, not with knowledge-base or human-document prose specs.

Some qualities help both audiences: directness, concrete wording, and low ambiguity. Agent files are still judged first by whether they help the model choose and execute the right behavior.

## How Agents Consume Instructions

Instructions land in the agent's context window alongside the user's request, tool outputs, and conversation history. They compete for attention with everything else.

- **Retrieval, not study.** Agents scan instructions to find what is relevant to the current task. They do not read top-to-bottom like documentation. Front-load the actionable content.
- **Position matters.** Content near the start of an instruction file gets stronger attention weighting. Put the most important constraints first.
- **Repetition is a signal.** If a constraint appears multiple times across different instruction sources (AGENTS.md, skill, briefing), agents treat it as higher priority. Use this deliberately — repeat critical rules, not filler.
- **Context is finite.** Every line of instruction text costs context budget. Instructions that load 500 lines of generic guidance leave less room for the actual task. Be lean.

## Framing Principles

### Cut anything that does not change behavior

Agent files are routing and constraint layers. Keep lines that change what the agent should do, avoid, or read next. Delete scene-setting, repeated summaries, and explanations that do not change execution.

### Constrain, don't explain

Agents already know how to code, write, and reason. What they lack is domain-specific context: your naming conventions, your architecture boundaries, your deployment constraints, your product rules.

Bad: "When writing TypeScript, use interfaces to define object shapes. Interfaces are preferred over type aliases because they support declaration merging."

Good: "Use interfaces for all API response shapes. Type aliases are fine for unions and utility types."

The first teaches TypeScript. The second constrains behavior in this specific codebase.

### Prescribe what matters, leave the rest open

Not every instruction needs to be a hard rule. Match precision to consequence:

- **Hard constraints** for things that break production, violate security, or cause irreversible harm. Use direct imperative: "Do not", "Always", "Never".
- **Strong defaults** for conventions that matter but have safe escape hatches. Frame as: "Prefer X over Y", "Default to X unless..."
- **Soft guidance** for stylistic preferences. Frame as: "When possible", "Consider".

Agents follow the instruction hierarchy: hard constraint > strong default > soft guidance. If everything is framed as a hard constraint, the agent cannot distinguish between "this will break prod" and "we prefer this style."

### Lead with the rule, follow with the reason

Put the actionable constraint first. If context is needed, add it after.

Bad: "Because our API gateway has a 30-second timeout and some of our background jobs take longer than that, you should never make synchronous API calls to background job endpoints."

Good: "Never make synchronous calls to background job endpoints. The API gateway times out at 30 seconds; use the async job polling pattern instead."

The rule comes first. The reason follows for readers who need it. Agents can act on the rule even if context gets truncated.

### Use task framing, not category framing

Instructions work best when they describe what the agent should do in a situation, not what a topic is about.

Bad:
```
## Authentication
Our auth system uses JWT tokens with refresh rotation...
```

Good:
```
## Working with authentication
- All API routes require the `withAuth` middleware
- Never store tokens in localStorage; use httpOnly cookies
- Refresh tokens are rotated on use; do not cache them
```

The first describes the system. The second tells the agent what to do when it encounters auth code.

## Structure Patterns

### Short sections with explicit headings

Agents scan headings to locate relevant instructions. Make headings specific and task-oriented.

Bad headings: `Notes`, `Context`, `Overview`, `Important`, `Misc`
Good headings: `Working with authentication`, `Database migration rules`, `Build and test commands`

### One concern per section

Each section should cover one topic. When a section mixes file placement rules, testing conventions, and deployment gotchas, the agent may miss the relevant constraint for its current task.

### Flat over nested

Prefer flat section lists over deeply nested hierarchies. Agents navigate flat lists faster than multi-level outlines. Reserve nesting for content that genuinely has parent-child relationships (e.g., a section listing sub-packages with per-package rules).

### Route, don't repeat

When detail exists in another document, point to it instead of duplicating it. Instruction files are routers.

```markdown
- Create or modify an endpoint? -> docs/creating-endpoints.md
- Run tests? -> docs/testing.md
```

Duplication across instruction files creates drift. When the source changes, the copies become wrong.

## Common Failure Modes

### Teaching what the model knows

Explaining how TypeScript generics work, what REST APIs are, or how git branching works. The model knows. Add what it doesn't: your team's specific conventions, your system's specific constraints.

### Narrative burying rules

Wrapping actionable constraints in paragraphs of context, history, and rationale. The rule gets lost. Lead with the constraint; add context after if needed.

### Padding agent files

Adding summary prose that repeats the heading, examples that do not teach a new edge, or explanation that does not change routing or execution.

### Reviewing agent files with human-doc rubrics

Applying documentation-style or prose-authenticity checks as the main evaluation lens for agent instruction files. This often produces the wrong edits: reducing trigger clarity, removing useful repetition, or pushing instruction files toward human-friendly prose instead of agent-usable constraints.

### Mixing concerns into monoliths

Combining project overview, domain lore, coding conventions, deployment steps, and PR workflow into one giant document with no clear sections. Agents struggle to extract the relevant subset for any given task.

### Over-constraining

Making every preference a hard rule. When everything is mandatory, the agent cannot distinguish critical safety constraints from mild style preferences. Reserve hard language ("Never", "Do not", "Always") for things that actually matter.

### Under-specifying the unusual

Documenting the happy path but not the edge cases. Agents follow instructions well for common tasks but go off-script for unusual situations. If there are gotchas, non-obvious constraints, or cases where the intuitive approach is wrong, spell them out.

### Stale instructions

Instructions that describe how the system used to work. Stale constraints are worse than no constraints — the agent actively follows wrong guidance. When the system changes, update the instructions or remove them.

## Instruction Types and Where They Live

Different instruction types serve different purposes. Knowing which type you're writing helps structure it correctly.

| Type | Purpose | Lifespan | Example location |
|------|---------|----------|-----------------|
| Repo instructions | Orient agents to a codebase | Durable, repo-scoped | `AGENTS.md` |
| Role snippets | Shape agent behavior for a role | Durable, cross-repo | `~/AGENTS.md`, briefings |
| Skill instructions | Guide a specific workflow | Durable, portable | `SKILL.md` |
| Custom instructions | User-specific preferences | Durable, personal | Tool settings |
| PR/task instructions | One-off task context | Ephemeral | PR description, comments |

Durable instructions should never contain ephemeral content (PR-specific workarounds, temporary flags, time-limited rules). Ephemeral instructions belong in the conversation or task context, not in files that persist across sessions.
