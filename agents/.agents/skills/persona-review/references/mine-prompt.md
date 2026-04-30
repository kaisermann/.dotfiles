# Mining a Review Profile

Repeatable process for extracting a code reviewer's attention patterns from their GitHub review history and distilling them into durable profile documents.

This process was developed while building the `kaisermann` profile. It can be reused for any Spoke reviewer.

## Prerequisites

- GitHub CLI (`gh`) authenticated with access to the target repos.
- Target repos list (e.g., `getcircuit/domain`, `getcircuit/web-packages`, `getcircuit/backend-services`, `getcircuit/web-apps`).
- Target reviewer's GitHub username.
- Access to Spoke convention docs in `~/.spoke-knowledge/content/engineering/`.

## Phase 1: Corpus Collection

### 1a. Inventory reviewed PRs

For each repo, get the list of PRs where the reviewer left comments:

```bash
gh api --paginate "repos/{owner}/{repo}/pulls?state=all&per_page=100" \
  --jq '.[] | select(.user.login != "{reviewer}") | "#\(.number) \(.title)"' \
  | head -200
```

Then filter to PRs where the reviewer actually left substantive comments (not just approvals):

```bash
gh api "repos/{owner}/{repo}/pulls/{number}/comments" \
  --jq '.[] | select(.user.login == "{reviewer}") | .body' \
  | head -5
```

### 1b. Sample strategy

Extract in waves with exclusion lists to avoid re-analyzing the same PRs:

1. **Wave 1 (24 PRs):** Deep sample across all repos. ~6 per repo, mixed sizes and types. Read every comment carefully to identify initial patterns.
2. **Wave 2 (100 PRs):** Broader sample excluding Wave 1. Focus on confirming/disconfirming Wave 1 patterns and finding new ones.
3. **Wave 3 (300 PRs):** Exhaustive pass excluding Waves 1 and 2. Focus on edge cases, rare patterns, and reinforcement of existing patterns.

### 1c. Extraction per PR

For each PR, extract all review comments (both inline and review-level):

```bash
# Inline comments
gh api "repos/{owner}/{repo}/pulls/{number}/comments" \
  --jq '.[] | select(.user.login == "{reviewer}") | "- **\(.path)**: \(.body)"'

# Review-level comments
gh api "repos/{owner}/{repo}/pulls/{number}/reviews" \
  --jq '.[] | select(.user.login == "{reviewer}" and .body != "") | .body'
```

Record the PR number, title, and substantive comments. Skip PRs where the reviewer only left approval with no inline comments.

## Phase 2: Pattern Synthesis

After each wave, synthesize the raw comments into **durable abstractions**. The goal is to identify recurring attention patterns, not to catalog individual review comments.

### Synthesis questions

For each comment or cluster of comments, ask:

1. **Is this a one-off observation or a recurring pattern?** Only recurring patterns go into the profile.
2. **Can this be generalized one step back?** "Don't use `in` queries with >30 items" generalizes to "Firestore query limit awareness."
3. **Does this reinforce an existing pattern or introduce a new one?** Track frequency to determine weight.
4. **What severity would the reviewer assign?** Is this blocking, should-fix, or consider?
5. **What's the actionable instruction for an agent?** "What to look for in a diff" format.

### Pattern categories

Group findings into these dimensions (adjust based on the reviewer's actual focus):

- **Patterns and Abstractions** — Do they track shared utilities? Do they flag reinvention?
- **Naming and Types** — How precise are their naming expectations?
- **Structure and Scope** — Do they enforce colocation? Package boundaries?
- **Data and Infrastructure** — Firestore, query patterns, SDK boundaries?
- **Frontend/Framework Patterns** — React/Svelte-specific review patterns?
- **Test Quality** — Test factories, mock hygiene, test level appropriateness?
- **Code Quality** — Comments, error handling, logging?

Not every reviewer will have strong opinions in every category. Weight the profile toward where the reviewer actually focuses.

## Phase 3: Profile Document Construction

### Folder structure

```
review-profiles/
  {username}/
    overview.md                 # Attention model, calibration, depth scaling, convention anchors
    patterns-and-abstractions.md
    naming-types-api.md
    structure-and-scope.md
    data-and-firestore.md       # or domain-appropriate name
    frontend-patterns.md        # or framework-appropriate name
    test-and-quality.md
```

### Overview doc requirements

The overview doc should contain:

1. **Corpus size and source** — How many PRs were analyzed, from which repos.
2. **Attention model** — The core questions the reviewer asks (3-7 questions).
3. **Domain document routing table** — When to load each domain doc.
4. **Feedback calibration** — Severity mapping and what NOT to flag.
5. **Review depth scaling** — How depth varies by PR type.
6. **Convention anchors** — Which Spoke convention docs support which dimensions.
7. **Decomposition guidance** — How to map the profile to sub-agents.

### Domain doc requirements

Each domain doc should contain:

1. **What to look for in a diff** — Concrete, scannable list.
2. **Severity guidance** — When to flag as critical/warning/info.
3. **Corpus examples** — Direct quotes from actual reviews with PR references.
4. **Anti-patterns** — Numbered list of specific patterns to flag.

### Writing principles

- **Prescribe, don't explain.** These are agent-facing instructions. Lead with what to do, not why the reviewer thinks a certain way.
- **Corpus examples are evidence.** Every pattern should have at least one direct quote from an actual review. These ground the agent's behavior in real examples.
- **Weight matches frequency.** If the reviewer flags something in 30% of reviews, it gets more space than something flagged in 2%.
- **Name specific abstractions.** "Consider existing utilities" is useless. "Use `refSelectors()` instead of manual `doc()` calls" is actionable.
- **Severity is calibration.** If the reviewer wouldn't block a PR for something, it shouldn't be "critical" in the profile.

## Phase 4: Validation

After writing the profile, validate it against a fresh set of PRs not used in the extraction:

1. Pick 5-10 PRs the reviewer recently reviewed.
2. Run the profile against those PRs mentally or via the actual reviewer agent.
3. Check: Would the profile catch the same things the reviewer caught?
4. Check: Would the profile flag things the reviewer wouldn't care about? (False positive rate.)
5. Iterate on the profile based on validation findings.

## Maintenance

Profiles should be updated when:

- The reviewer's focus shifts (new patterns emerge, old patterns fade).
- Spoke conventions change (new tooling, deprecated patterns, new packages).
- The team's codebase evolves (new repos, new frameworks, architectural changes).

A good cadence: re-mine 50-100 recent PRs every 6 months and diff against the existing profile.
