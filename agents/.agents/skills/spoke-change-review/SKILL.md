---
name: spoke-change-review
description: Author-side self-review of code changes before requesting PR review. Use when the author wants to assess blast radius, convention compliance, and merge readiness of their own diff.
---

Pre-submission self-review from the author's perspective. Analyzes the current diff for risk, convention compliance, scope containment, and merge readiness.

Use `spoke-knowledge` when reviewing conventions or architecture patterns.

## When To Use

- Before marking a draft PR as ready for review
- After finishing implementation, to catch issues before a reviewer sees them
- When asked to self-review, check blast radius, or assess merge readiness of a set of changes

## When Not To Use

- Reviewing someone else's PR: use `spoke-pr` review mode instead
- Writing or rewriting PR descriptions: use `spoke-pr` create mode instead
- Addressing reviewer feedback: use `spoke-pr` address-feedback mode instead

## Workflow

Read `references/self-review-analysis.md` for the full procedure.

The short version:

1. **Gather the diff** — collect the full set of changes (staged, unstaged, committed-not-pushed)
2. **Scope check** — verify every changed file relates to the task intent
3. **Risk assessment** — classify the change's blast radius using risk signals from the knowledge base
4. **Convention scan** — check for pattern violations, reinvented abstractions, and AI-generated code quality issues
5. **Merge readiness** — verify tests, types, rollback path, and remaining work
6. **Report** — present findings organized by severity, with specific file and line references

## Guardrails

- This is the author's self-review, not a substitute for peer review. The goal is to catch what the author can catch before consuming a reviewer's time.
- Do not invent issues. If the code looks correct and well-structured, say so.
- Severity matters: separate blocking issues from suggestions. Use MUST / SHOULD / CONSIDER to signal importance.
- Always check for scope drift. Unintended changes are the most common source of hidden blast radius.
- Read the repository's `AGENTS.md` and local conventions before flagging pattern violations. What looks non-idiomatic globally may be correct locally.
