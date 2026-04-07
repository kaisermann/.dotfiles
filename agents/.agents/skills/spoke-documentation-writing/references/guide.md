---
description: Canonical writing rules for technical documentation: tone, structure, and anti-patterns. General standard — not specific to any one documentation system.
---

# Documentation Writing Guide

## Audience

Write for two readers: agents working with limited context, and people onboarding, switching domains, or checking a rule quickly. Either reader should be able to land on one section and understand the rule without reading from the top.

## Core Principle

**Declarative state over narrative history.** Describe what is true now and what rules apply, not how things evolved. Include historical reasoning only when it is itself a durable constraint.

**Concrete clarity over abstraction.** A useful doc names the real tool, path, system, package, dashboard, or process. If a reader still has to guess where something lives or what surface to use, the doc is not done yet.

## Retrieval-First

Organize docs for retrieval first. Explicit structure usually reinforces human readability: headings, definitions before explanation, self-contained sections, and clear boundaries.

When there is tension, prefer explicit structure over clever compression:

- a retrieved chunk should make sense without hidden setup from earlier paragraphs
- a human skimming headings should be able to find the right section quickly
- the first lines of a section should state the rule or fact before supporting detail
- brevity is good only when it does not force the reader to infer missing context

## Document Structure

### Required elements

1. **Frontmatter** — YAML metadata block
2. **Title** — `# Title` as the first heading
3. **Contents** — TOC for any doc over ~60 lines
4. **Body** — the actual content

### Optional but encouraged

- **Rules at a Glance** — a bullet list of non-negotiable rules near the top, before detailed explanation. Lets readers and agents grab enforcement rules without reading the full doc.
- **Definition / Use When** — a short opening sentence or mini-section stating what the thing is and when this doc matters.
- **See Also** — cross-references to related docs at the end.

### TOC format

Use a `## Contents` section with markdown links to headings. Keep it flat — one level of nesting max:

```markdown
## Contents

- [Context](#context)
- [The Rules](#the-rules)
- [Gotchas](#gotchas)
- [See Also](#see-also)
```

## Frontmatter

Use the frontmatter schema required by the documentation system you are editing.

Rules:
- Keep frontmatter minimal and retrieval-oriented
- Do not add metadata unless it changes retrieval behavior. Path, title, and git history already cover identity and provenance.
- When a repository or doc set defines specific frontmatter fields, follow that local spec rather than inventing a general schema here.

## Writing Rules

Write concisely, naturally, and directly. Cut filler and flourish, but keep enough connective tissue that the document still reads cleanly to a human.

### Be declarative, not narrative

Bad: "In October 2025, the company decided to rename from X to Y after acquiring the domain."
Good: "Y is the current name. Code still references `X` in many places due to naming inertia."

### Be concrete — name the things

Bad: "Use the shared helper for updates."
Good: "Use `updateDocument` from `@org/firestore-kit` for updates."

Bad: "the deployment dashboard"
Good: "ArgoCD at `https://argocd.example.com/`"

If an official tool or process exists, name it directly.

### Make metadata retrieval-oriented

Bad: vague metadata that only restates the title or category
Good: metadata that helps a reader or agent decide whether the doc is relevant in listings, previews, or routing flows

### State consequences and enforcement, not just guidelines

Bad: "You should use ref selectors for paths."
Good: "Use ref selectors for all Firestore paths. Bypassing them causes path drift across repositories, inconsistent construction, and missing coverage when new models are introduced."

### Lead with the answer

Start sections with the rule, fact, or boundary. Put background after that.

Bad: "Spoke has used several different patterns here, and over time we found that..."
Good: "Put repository-specific implementation steps in repository-local docs, not in the knowledge base."

This helps humans scan faster and helps retrieval return useful opening lines.

### Put definitions before explanation

Do not assume the reader already knows the term you are using.

Bad: starting with implications of a concept before naming what the concept is
Good: "A page bundle is the page-local data orchestration module. Use it to..."

If a term is important enough to anchor a rule, define it before expanding on why it exists.

### Make headings stand alone

Headings should describe the content of the section without relying on the parent section for meaning.

Bad: `## Notes`, `## More`, `## Details`
Good: `## Repository-Local Docs vs Knowledge Base`, `## When To Promote Code To A Package`

Agents may retrieve a section by heading alone. Humans often navigate by heading scan.

### Use examples as support, not as hidden law

Examples should clarify a rule, not replace it.

Bad: one project-specific example with no stated rule.
Good: "Put reusable configuration on the document that owns the setting. For example, `Settings.requiredFields` stores submission rules."

Rules:

- state the general rule first
- label examples as representative when they are not universal
- do not write examples in a way that implies the exact shape is permanent
- if the example is the only evidence, say what it supports and stop there

### Keep examples and scope aligned

Do not use domain-specific examples in a cross-domain doc unless they are clearly labeled as examples and illuminate a durable rule.

If the document keeps depending on one domain's vocabulary, that is usually a sign it should become a domain-scoped doc instead.

### Do not describe the filing cabinet

Do not explain the repository structure, folder choice, or where the doc lives unless the document is actually about repository structure or routing.

Bad: opening a content doc by talking about the folder it lives in.
Good: open with the subject itself.

### Keep the tone adult and useful

Direct does not mean snarky, parental, or theatrical. Write like a sharp coworker explaining a durable rule calmly.

Bad: phrasing that scolds the reader or adds attitude instead of information.
Good: precise statements about what matters, why it matters, and what to do.

### Synthesize research into declarative guidance

Investigation is often necessary to write a good doc, but the finished document should not read like research notes.

Bad: "Across the PRs we reviewed, this kept repeating" or "the common posture seems to be"
Good: "Use a migration when old documents must behave like new ones immediately."

If you needed a long investigation to reach the rule, keep that investigation out of the final doc unless the reasoning is itself a durable constraint.

### Cut marketing prose

No value-proposition copy, capability lists, launch narratives, or positioning language. State what the product or system does in 1-3 sentences.

### Cut redundancy

If something is already well-documented elsewhere, point to it instead of duplicating.

### Prefer concrete process over abstract placeholders

Do not hide an official workflow behind generic language.

Bad: "Route the issue through the appropriate support workflow."
Good: "Keep the customer conversation in Intercom and open a bug thread when the issue needs engineering investigation."

Bad: "Check the relevant launch surfaces."
Good: "Check the project thread, the shipped-project thread, and the explainer Loom before answering customer-facing questions about the release."

If a doc cannot yet name the real process, tool, or destination, it usually needs more research before it is ready.

### Keep sections scannable

- Short paragraphs (2-4 sentences)
- Bullet lists for enumerable items
- Tables for structured comparisons
- Code blocks for package names, paths, and commands
- Bold for key terms on first use

### Avoid time-sensitive claims

Bad: "Package Tracker is currently paused from development (as of March 2026)."
Good: "Package Tracker: paused from active development."

If something is likely to change, say so directly in the body instead of relying on metadata that will drift.

## Anti-Patterns

- **History-as-content**: timeline narratives, "how we got here" sections, changelog-style evolution stories. Cut to declarative state.
- **Research-memo tone**: "what kept repeating," "the common posture," "what we found," or project-by-project narration. Convert findings into rules, constraints, or checklists.
- **Human-only narrative flow**: sections that only make sense if read top to bottom from the start. Each section should stand on its own.
- **Marketing language**: "public value proposition," "effortless route planning," capability bullet lists. State what it does plainly.
- **Agent-only compression**: terse notes that save tokens by omitting definitions or consequences a human reader would need.
- **Vague references**: "the shared helper," "the types package," "the relevant repository." Name the exact package, function, or repository.
- **Duplicated content**: same information in two docs. Pick one canonical location, cross-reference from the other.
- **Mermaid diagrams and heavy visual elements**: they waste tokens for agent readers and are hard to maintain. Use text trees or tables instead.
- **Prose-heavy sections with no enforcement**: if a section doesn't tell the reader what to do or what not to do, it's probably noise. Cut it or add a rule.
- **Governance-heavy frontmatter**: metadata that duplicates the file path, title, or git history. Keep only fields that improve retrieval.
- **Examples as accidental policy**: one domain-specific example presented as if it were a universal rule. State the rule, then give the example.

### AI prose anti-patterns

These patterns are strong signals of AI-generated text. They appear frequently in model output and rarely in human-written technical documentation.

- **Binary contrast / negative parallelism**: "It's not X. It's Y." or "Not because X. Because Y." State Y directly. Drop the negation.
  Bad: "The problem isn't the config. It's the deploy pipeline."
  Good: "The deploy pipeline drops environment overrides during the build step."

- **Dramatic fragmentation**: sentence fragments stacked for manufactured emphasis. Complete the sentences.
  Bad: "Latency. That's it. That's the constraint."
  Good: "The constraint is latency: P95 response time must stay under 200ms."

- **Self-posed rhetorical questions**: "The result? Devastating." or "The worst part? Nobody checked." Make the point directly.
  Bad: "What happens when the cache expires? Chaos."
  Good: "When the cache expires, every request hits Firestore until the background job repopulates it."

- **Bold-first bullets**: every list item opening with a bolded keyword. Use bold for key terms inline, not as a list-formatting device.
  Bad: "**Security**: env-based config with…  **Performance**: lazy loading of…"
  Good: plain list items; bold a term only when defining it for the first time.

- **False agency**: inanimate things performing human actions. Name the person or team.
  Bad: "The migration handles edge cases gracefully."
  Good: "The migration script skips documents missing the `orgId` field and logs them for manual review."

- **Throat-clearing openers**: "Here's the thing:", "Let's break this down", "Let's unpack this." Start with the content.

- **Filler transitions**: "It's worth noting", "Importantly", "Interestingly", "Notably." Delete them. The sentence after the filler is the actual point.

- **Superficial participle phrases**: trailing "-ing" clauses that signal importance without saying anything. "…highlighting its role in the ecosystem" or "…reflecting broader architectural trends." Either make a specific claim or delete.

- **Fractal summaries**: announcing what you will say, saying it, then summarizing what you said. State it once.

- **One-point dilution**: restating the same argument in multiple ways across the document. State the point, support it, move on.

- **Invented concept labels**: made-up compound terms treated as established ("the deploy paradox", "config drift syndrome"). If the concept needs a name, define it. Otherwise describe it in plain language.

- **Filler adverbs**: "deeply", "truly", "fundamentally", "inherently", "remarkably", "quietly", "genuinely." Cut them. Precision adverbs like "explicitly", "currently", or "previously" are fine when they carry real meaning.

- **Em dashes**: avoid them. Use a comma, period, colon, or parenthetical instead. Em dashes are one of the strongest AI formatting tells — models reach for them constantly. A rare one in informal writing is tolerable, but zero is the target for documentation.

- **"Serves as" and friends**: replacing "is" with "serves as", "stands as", "represents", or "marks." Use the simple verb.

- **Grandiose stakes inflation**: inflating a narrow technical point to civilizational significance. Scale claims to match the actual stakes of the system or decision.

## Checklist Before Committing

- [ ] Frontmatter is minimal and retrieval-oriented
- [ ] Any required metadata is minimal and improves retrieval
- [ ] TOC present if doc is over ~60 lines
- [ ] No marketing prose, no timeline narratives
- [ ] No research-memo tone or project-by-project narration
- [ ] Concrete names used (packages, functions, tools) — not vague references
- [ ] Rules state consequences, not just suggestions
- [ ] Examples are clearly representative and do not silently stand in for universal rules
- [ ] No content duplicated from another doc
- [ ] No AI prose anti-patterns (binary contrasts, dramatic fragments, bold-first bullets, throat-clearing, filler adverbs, false agency, em dashes)
- [ ] Cross-references and URLs verified to exist
