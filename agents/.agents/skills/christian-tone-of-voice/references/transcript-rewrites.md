# Transcript rewrites

Use this when the input is spoken, messy, or obviously transcribed from a brain-dump.

## Remove

- Filler like `uh`, `like`, repeated starts, and self-corrections that do not change meaning.
- Duplicate sentences caused by spoken restarts.
- Tangents that are not part of the decision, recommendation, or next step.

## Preserve

- The actual concern, recommendation, and confidence level.
- Any tradeoff framing.
- Concrete anchors like names, examples, links, environments, dates, or edge cases.
- Any explicit distinction between the core problem and optional complexity.

## Default ordering

1. Quick acknowledgement or framing.
2. The main point or proposal.
3. Supporting reasoning.
4. Concrete examples or implementation notes.
5. Next step, caveat, or boundary clarification.

## Bullets vs prose

- Use prose for a short setup, clarification, or social bridge.
- Use bullets when listing policy, decisions, invariants, progress, or next steps.
- Use a tiny `technical:` bullet or sentence when implementation detail should be separated from product behavior.

## Compression rules

- Keep short spoken notes short in writing too.
- For longer rambles, compress into a few compact paragraphs plus bullets.
- Preserve a small amount of exploratory texture. Do not rewrite into a perfect memo unless the situation clearly calls for it.

## Output checks

- Does the message acknowledge the other person or reduce friction when needed?
- Is confidence calibrated instead of over-asserted?
- Are the core tradeoff and the edge case clearly separated?
- Is there at least one concrete anchor if the topic is technical or procedural?
- Does the ending prevent a likely misreading or clarify the next step?
