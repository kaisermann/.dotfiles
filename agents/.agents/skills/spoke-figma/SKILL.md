---
name: spoke-figma
description: Explore Figma files, inspect nodes, read comments, and export design images via the bundled wrapper. Use when implementation work depends on design structure, measurements, or visual references.
---

Use the bundled Figma wrapper for design inspection, comment lookup, and image export workflows.

Use the bundled wrapper at `scripts/figma.sh`.

If the wrapper fails, stop and tell the user what is missing.

Expected token in `~/.spoke-env`:

```bash
FIGMA_TOKEN=your_token_here
```

The wrapper also requires `jq`, `curl`, and macOS `sips`.

## Common Commands

```bash
# List pages using the bundled wrapper
sh scripts/figma.sh page list "https://www.figma.com/design/ABC123/Feature-Name"

# Explore a page to find sections, frames, and candidate node IDs
sh scripts/figma.sh page show "$URL" "designs"

# Inspect exact specs for one or more nodes
sh scripts/figma.sh node show "$URL" "152:12183"
sh scripts/figma.sh node show "$URL" "152:12181,152:12182,152:12183"

# Export a node image for visual review
sh scripts/figma.sh node export "$URL" "307:9277"

# Read file comments
sh scripts/figma.sh comment list "$URL"
```

## Typical Workflow

1. Use `page list` to find the relevant page.
2. Use `page show` to explore the design and find node IDs.
3. Use `node export` when you need a visual reference.
4. Use `node show` when you need exact spacing, color, typography, or sizing details.

## When To Use

- implementation depends on design structure or exact specs
- you need semantic colors, spacing, radius, or typography from Figma
- you need a PNG export for visual comparison
- you need to inspect comments on a Figma file

## Important Behavior

- `node show` works best on individual components, not entire screens
- `node export` saves images to `${TMPDIR:-/tmp}/spoke-figma/YYYY-MM-DD/` and returns the file path only
- the wrapper ships a bundled token lookup file at `scripts/figma-tokens.json` for semantic design token resolution
- production-ready work is often on pages named `design` or `designs`; exploratory pages are usually less reliable

## Failure Handling

- if the wrapper fails before the request: report the missing token or tool requirement surfaced by the wrapper
- if the API says unauthorized: tell the user to refresh `FIGMA_TOKEN` in `~/.spoke-env`
- if export output is too large: inspect smaller child nodes instead of retrying the whole screen export
- if a page or node is not found: verify the file URL and node ID format before retrying

## See Also

- `~/.spoke-knowledge/content/company/_reference/internal-tools.md` — internal tooling reference
