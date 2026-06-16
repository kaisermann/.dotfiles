---
name: diagnose
description: "Root-cause debugging protocol. Use when a bug resists a quick fix - regressions, flaky/intermittent, layout 'lands then shifts', a fix that won't land after 2+ tries, or 'going in circles'. Isolate by toggle/bisect first. Not for routine bugs."
---

# Diagnose — root-cause debugging for bugs that resist the obvious fix

The trap this skill breaks: **measuring or patching the symptom instead of isolating its cause.** Measuring how far something is off, at ever-higher resolution, never tells you *what* moves it. The cure is almost always cheap and almost always skipped under pressure — find which single thing causes the bug, *then* change that.

Reach for this EARLY. One isolation test costs minutes; a guess-and-patch loop costs hours.

## The protocol

Work top to bottom. Most bugs fall out by step 2.

### 1. Reproduce on a clean baseline
Revert your in-progress edits / stashes / hacks and confirm the bug still happens without them. Otherwise you may chase your own noise, or "fix" something that was never the cause. If it reproduces clean, you have a stable target. If it *doesn't*, your changes are involved — so bisect *those*.

### 2. Isolate the cause by bisection — before any measuring or patching
Binary-search for the cause: remove / toggle / disable / comment out parts — one element, prop, style, flag, or commit at a time — until the symptom flips on and off. The thing whose presence toggles the symptom **is** the cause (or one hop from it).

- For a **regression**, bisect history: `git bisect`, or broad content search `git log -S'<string>' -G'<regex>' --all`. Content search follows file moves / renames / decomposition; a per-file `git log` silently misses code that was split or moved.
- A live toggle in the running app (DevTools, a temporary flag) is usually faster than reasoning about the code.

This is the step people skip under pressure. Don't. One decisive toggle beats fifty measurements.

### 3. Classify: static or dynamic?
If the bug appears in one state but not another with the **same inputs** — "measure ≠ settle", "lands then shifts", flicker, flaky, passes-then-fails, works-in-isolation-breaks-in-app — it is **dynamic**: something *changes, mounts, loads, or races between the two states*. Find that thing (what renders / fetches / animates / observes after the first state).

A **static** change cannot fix a dynamic difference — it shifts *both* states equally and leaves the gap intact. If you catch yourself applying a static fix to a "sometimes" bug, stop: you're treating a timing / lifecycle problem as a value / layout problem, and it will never hold.

### 4. Trust your instrument before its readings
Before you believe a measurement, prove the tool isn't lying. Paused or throttled rAF in a hidden tab, transformed / zoomed coordinates, stale caches, a contaminated or resized environment, a frozen animation frame — all return confident, wrong numbers that spawn entire false hypotheses. Neutralize or cross-check the instrument first (a transform-immune read, a known reference value, a second tool). Bad data manufactures wrong theories faster than you can kill them.

### 5. Confirm the cause, then fix
Before editing the real fix, prove the cause: toggle it live and watch the symptom appear and disappear. *Then* write the change. Make **one falsifiable change at a time** — never two speculative fixes on two unknowns; they mask each other and make the system unfalsifiable.

## Stop-loss — the circuit breaker

You're allowed to be wrong; you're not allowed to keep doing the wrong thing. Trip the breaker when any of these is true:

- ~3 fixes have failed on the same symptom,
- you're editing the same file again with no real progress,
- a redirect lands ("running in circles", "this smells", repeated or forceful user pushback).

When it trips: **revert to a clean state, write down the single contradiction you can't currently explain, and change *method*** — go to step 2 (isolate), bisect the regression, or fan out independent subagents from different angles. Do not try the same approach harder. A forceful user redirect is a signal to *switch methods*, not to push harder. "Step back" means *do this* — not say it.

## Before you start

Query stored learnings for the area — past gotchas and retro notes (`bd query "type=decision AND label=retro AND label=<domain>" --all`, plus any project memory files). The note that saves the hour usually already exists; read it before the first measurement, not the tenth.

## diagnose vs `step-back`

- **`step-back`** — an ambiguous *design / product / architecture* problem with many possible shapes; you need a calm overview before choosing a direction.
- **`diagnose`** (this) — a concrete *bug* that resists fixing; you need to find a cause, not explore a space.

## Worked example — the shape to copy

A card "landed then shifted" on entry. Eight hours went into measuring the shift's magnitude and patching CSS. The cause was found in two minutes by step 2: toggling one element's `float` off made the shift vanish. Step 3 then explained the timing (that element mounted *after* the position was measured — dynamic, so no static CSS could ever fix it), and step 4 was why the early readings were garbage (a paused-rAF tab returning frozen transforms). Run the protocol first and it's a one-hour bug. Isolate before you measure.
