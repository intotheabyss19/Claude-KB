# Pattern: Memory Consolidation (Episodic → Semantic)

> **OPEN DEPENDENCY:** This pattern is referenced by
> `docs/knowledge-architecture.md`, which is pending design. The
> consolidation mechanism described here has NOT been implemented — it's
> a design pattern to inform the knowledge-architecture decision, not a
> working system. Whether/how much of this gets built vs. simplified to
> "just well-organized markdown" is an open question.

A pattern for turning raw session observations into reusable semantic
knowledge. This is what makes memory systems feel "smart" — not just
recall, but generalization.

Attribution:
  Pattern from: github.com/JuliusBrussee/caveman-code — docs/reference/memory.md
  License: MIT (c) 2026 Julius Brussee

---

## The Problem

Most agent memory systems store raw observations ("user said X", "tool
failed on Y", "file Z was edited"). Over time this becomes a pile of
episodic noise. Searching it returns too many low-value hits.

## The Pattern

Periodically cluster recent observations by topic, run a cheap model
(haiku-class) to extract semantic facts, write them back with provenance
links to the source observations.

```
Episodic observations (raw):
  obs_1: "biome.json with deprecated lint key caused failure"
  obs_2: "renamed lint key to linter in biome.json"
  obs_3: "also removed legacy formatter block"

        ↓ consolidation pass ↓

Semantic fact (derived):
  kind: lesson
  context: "applying biome config to TypeScript monorepo"
  fail: "biome.json with deprecated lint key"
  fix: "rename to linter, drop the legacy formatter block"
  provenance: [obs_1, obs_2, obs_3]
```

## When to Run

- **On-demand:** user invokes consolidation
- **Periodic:** scheduled review (e.g., monthly via /review-knowledge-base)
- **Auto-trigger:** when a tool call fails twice and then succeeds,
  the sequence (context + fail + fix) is a lesson worth extracting

## Auto-Trigger Learning

The most valuable automatic pattern: when a tool call fails N times and
then succeeds, the sequence (context + fail + fix) is a lesson worth
extracting. This happens at the agent runtime level, not the memory layer.

```yaml
kind: lesson
context: "applying eslint-config-cave to a TypeScript monorepo"
fail: "biome.json with deprecated lint key"
fix: "rename to linter, drop the legacy formatter block"
provenance: [obs_id_1, obs_id_2, obs_id_3]
```

## Design Rules

1. **Cheap model for extraction.** Consolidation is mechanical — use the
   cheapest model that can follow a template.

2. **Provenance is mandatory.** Every semantic fact must link back to its
   source observations. This lets you verify and lets the user trace why
   the system "knows" something.

3. **Compress the output.** Semantic facts stored in terse style take
   ~50% fewer tokens on future retrieval. Compound savings over time.

4. **Don't consolidate too eagerly.** Wait for enough observations to
   cluster meaningfully. Running on every observation adds cost without
   value.

5. **Privacy boundary.** Anything between `<private>` and `</private>`
   tags should be redacted before storage. Never consolidate private
   content into semantic facts.

## What This Is Not

This is a design pattern, not a complete memory system. A full
implementation needs: storage, search, the consolidation pass described
here, and injection logic. The consolidation pass is the part most
systems skip.
