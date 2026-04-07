---
name: spoke-knowledge-pr
description: Open a git PR for a Spoke knowledge base correction, durable addition, or revision. Use when verified KB docs are wrong, missing, outdated, or incomplete.
---

When you have verified knowledge to correct, add, or revise in the Spoke Knowledge Base (`~/.spoke-knowledge/`), follow this process to open a PR.

## Prerequisites

If `gh` is not installed or not authenticated, **stop and notify the user**. Do not attempt to work around this.

Run `bash scripts/validate.sh` before first use to verify `gh` is installed, authenticated, and has the required `repo` scope.

Verify the knowledge base repo exists:

```bash
ls ~/.spoke-knowledge/.git
```

If it doesn't exist, ask the user to clone it:
```
git clone git@github.com:getcircuit/knowledge.git ~/.spoke-knowledge
```

## When to Propose an Update

- You discovered a **fact that contradicts** existing knowledge base content
- You learned something about the **architecture, domain, or tech stack** that isn't documented
- Existing knowledge base content is **outdated** or **incomplete**

Do NOT propose updates for:
- Temporary/transient information (build failures, current branch state)
- Information specific to a single user's environment
- Speculative or unverified claims — only document what you've confirmed
- **Feature-specific or project-specific knowledge** — the knowledge base is for structural, architectural, and domain knowledge that's stable and broadly useful
- **Repository-specific implementation notes** that belong in that repository's `docs/`, `README.md`, or `AGENTS.md`

## Update Types

### Correction
The existing knowledge base document is wrong. Edit the document directly, fix what's wrong, and open a PR explaining what was incorrect and why.

### Addition
New knowledge that doesn't exist yet. Create a new document in the appropriate area directory under `content/`.

### Revision
Existing document is outdated or incomplete. Edit in place.

## Step-by-Step Process

### 1. Determine the scope

| If the knowledge is about... | Scope | Directory |
|---|---|---|
| Company culture, org, processes | company | `content/company/_index.md` |
| Domain models, business rules, products | business | `content/business/_index.md` |
| Design workflows, Figma organization, design-system conventions | design | `content/design/_index.md` |
| Architecture, tech stack, platform patterns | engineering | `content/engineering/_index.md` |
| Cross-repository conventions, repository catalog | engineering | `content/engineering/_index.md` |
| Infra, deployment, observability, runtime debugging | engineering | `content/engineering/infra/_index.md` |

### 2. Create a branch

```bash
git -C ~/.spoke-knowledge checkout main
git -C ~/.spoke-knowledge pull origin main
git -C ~/.spoke-knowledge checkout -b content/{scope}/{brief-slug}
```

Example: `content/engineering/auth-token-ttl-is-24h`

### 3. Write or edit the document

For new documents under `content/`, load `spoke-documentation-writing` and follow `docs/knowledge-base-writing-spec.md`.

Create the file in the appropriate `_{category}/` subfolder under `content/{scope}/` with minimal frontmatter:

```markdown
---
scope: engineering
description: One sentence saying what the document covers.
---

# Clear, Factual Title

Write the body directly. Add `## Contents` only when the document is long enough to need it.
```

Place the file in the `_{category}/` subfolder that matches the dominant document mode:

- `_reference/` — rules, specs, definitions, contracts, catalogs
- `_explanation/` — why, tradeoffs, conceptual models, architectural reasoning
- `_how-to/` — task-oriented steps with a clear success condition
- `_tutorial/` — guided learning flow for a beginner (rare in this KB)

Create the `_{category}/` subfolder if it does not exist yet.

For corrections and revisions, edit in place. Keep the body aligned with the current writing rules rather than forcing an older section template.

### 4. Keep the metadata minimal

- Keep frontmatter retrieval-oriented: `scope` and `description` for files under `content/`.
- The document's `_{category}/` subfolder declares its Diataxis type — do not duplicate this in frontmatter.
- Do not add governance metadata that duplicates the file path or git history.

### 5. Commit and open a PR

Review the worktree first and stage only the intended files with explicit paths. Do not use `git add .` in a dirty tree.

```bash
git -C ~/.spoke-knowledge status --short
git -C ~/.spoke-knowledge add content/{scope}/_reference/example.md docs/how-this-works.md
git -C ~/.spoke-knowledge commit -m "knowledge({scope}): {brief description}"
git -C ~/.spoke-knowledge push origin content/{scope}/{brief-slug}
gh pr create \
  --repo getcircuit/knowledge \
  --head content/{scope}/{brief-slug} \
  --title "knowledge({scope}): {brief description}" \
  --body "## Proposed Knowledge Update

**Scope:** {scope}
**Type:** {addition | correction | revision}

### What
{Brief description of the knowledge being added or corrected}

### Why
{Context — what task led to this discovery, what evidence supports it}
" \
  --label "ai-proposed"
```

### 6. Return to main

After pushing and creating the PR, switch back to main:

```bash
git -C ~/.spoke-knowledge checkout main
```

Do NOT pull — the PR hasn't been merged yet.

### 7. Report to the user

After opening the PR, report the PR URL and note that it needs human review before it takes effect.

## File Naming Conventions

- Use kebab-case: `auth-token-ttl.md`, `firestore-reactive-architecture.md`
