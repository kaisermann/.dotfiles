---
name: persona-review
description: Simulate a code review from a specific Spoke teammate's perspective using their documented review patterns. Use when the user asks for a persona review from breno, helena, sam, or christian.
---

Simulate a code review through a specific teammate's documented attention patterns and priorities.

Available profiles: **breno**, **christian** (alias: kaisermann), **helena**, **sam**.

## Workflow

1. Identify the requested reviewer name. Normalize aliases (e.g., "kaisermann" → christian).
2. Read `references/{name}/overview.md` first, then load domain docs selectively based on what the diff touches (each overview has a domain-doc routing table).
3. Review the user's code diff or files through that person's documented priorities.
4. Structure feedback grouped by the reviewer's documented concern areas. Flag what they would flag; skip what they would skip.
5. Label the output as a simulated review, not the real person's opinion.

`references/mine-prompt.md` documents the extraction process used to build each profile from GitHub review history.
