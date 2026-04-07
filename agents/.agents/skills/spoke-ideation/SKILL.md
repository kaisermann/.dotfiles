---
name: spoke-ideation
description: Structure exploratory thinking for ambiguous problems, project framing, solution shaping, and tradeoff analysis. Use when the path is unclear, the problem is still being defined, or you need to compare directions before deciding.
---

Structured exploration for problems, projects, and decisions at Spoke (`~/.spoke-knowledge/`).

Use `spoke-knowledge` when rotations need company context. Use `spoke-ask` when rotations need historical decisions that are not in the knowledge base.

## The cognitive model

An idea seen from one angle is a guess. The same idea seen from five angles starts to reveal its actual shape — which parts are load-bearing, which are decoration, which are missing entirely.

Rotation means projecting the same idea through different frames. Each projection highlights some structure and hides other structure. The thinking happens in the space between projections — the contradictions, the gaps, the surprising overlaps.

This is not brainstorming (generating many ideas) or evaluation (scoring one idea). It is structured exploration: taking one idea and discovering its real structure by looking at it from enough angles that the shape becomes clear.

## When to use

- Framing a project before writing the 1-pager
- Exploring a problem space before designing
- Thinking through architecture before coding
- Evaluating tradeoffs before committing to a direction
- Reframing when stuck — rotating to find an angle that unsticks the thinking

## When not to use

- The problem is well-understood and the path is clear — just do it
- The task is implementation of an already-scoped decision
- A single perspective is sufficient (bug fix, typo, routine maintenance)

Rotation adds value when the problem has hidden structure. If the shape is already visible, rotation is overhead.

## The technique

### Start with a frame

State the idea, problem, or decision in one sentence. This is a hypothesis, not a commitment — the frame often changes as you rotate.

### Choose axes that would change the shape

An axis is a perspective that might reveal structure the current frame hides. The test for a good axis: would looking from here change what I think the problem is? If the answer is obviously no, skip it. Three to five axes is usually enough.

Where to find axes at Spoke:

- **Role perspectives** — read the per-role docs under `content/company/roles/_reference/`. Each role sees different priorities, constraints, and failure modes. A backend engineer sees system boundaries; a support specialist sees confusion points; a PM sees scope.
- **Product surfaces** — read `content/business/_reference/product-overview.md` for the product landscape. A feature that is simple on one surface may be complex or irrelevant on another.
- **Organizational shape** — read `content/company/_reference/how-we-work.md`. Async-first communication, project-first delivery, small cross-functional teams — these constrain what solutions are practical.
- **Time horizons** — what is the smallest first version that delivers value, what is explicitly deferred, what constraints does this create for the future.
- **Custom axes** — not every problem fits standard frames. Technical tradeoffs, market positioning, risk dimensions, migration constraints. Create the axis the problem needs.

### Rotate

Project the idea through each axis. For each one, describe what the idea looks like from that perspective, what matters most from here, and — critically — what is invisible from here. The invisible parts are the highest-value output: they tell you what the next rotation should look for.

Keep each projection concise. The value is in the contrast between projections, not in the depth of any single one.

### React to what the rotations reveal

After each rotation, adjust:

- If two projections contradict each other, that contradiction is a real tradeoff — name it.
- If something shows up in every projection, it is load-bearing.
- If something only matters from one angle, it might be a nice-to-have rather than a requirement.

The frame you started with may turn out to be wrong. If rotations keep revealing structure outside the original frame, re-frame and rotate again.

### Recognize when to stop

Stop rotating when:

- The same structure keeps appearing from new angles — diminishing returns
- Contradictions have been identified and named, even if not yet resolved
- The boundary is clear — you can articulate what the idea is and what it is not
- You know what to do next, even if "next" is another round with different axes

The output is clarity, not a document. That clarity might lead to writing a 1-pager, scoping a first version, opening a design exploration, drafting an RFC, or killing the idea. Propose the next action based on what the rotations revealed.
