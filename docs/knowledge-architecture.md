# Knowledge Architecture

How lessons are stored, structured, and found in `knowledge/`.

---

## File Organization: Domain Files

Lessons are grouped by domain in single files: `knowledge/docker.md`,
`knowledge/auth.md`, `knowledge/monorepo.md`, etc. Each domain file
contains multiple lessons as headed sections.

**Do not create one-file-per-lesson.** Fewer, larger files are cheaper
to access (one Read call vs. many) and easier to browse.

### When to split

- **Soft limit:** 1000 lines — flag in next `/review-knowledge-base` run
- **Hard limit:** 1500 lines — split needed
- **Splitting is user-initiated only.** Claude flags but never auto-splits.
  User inspects and decides how to divide the domain.
- When splitting, break into sub-domains: `docker-builds.md`,
  `docker-networking.md`, etc. Keep files flat in `knowledge/` (no
  subfolders unless the user decides otherwise).

## Lesson Format: Structured Terse

Each lesson is a `###` section within its domain file. Use terse style
throughout, but **Problem and Fix fields must be unambiguous standalone**
— clear enough that someone reading them 6 months later without the
original conversation context can understand and apply them.

```markdown
### Buildkit cache miss on multi-stage builds

**Context:** Docker multi-stage build in CI
**Problem:** Cache invalidated every run — COPY . before package install
  copies everything, busting layer cache on any source change
**Fix:** COPY package*.json first, RUN install, then COPY rest —
  standard layer ordering. Deps layer cached until lockfile changes.
```

### Fields

- **Context** — terse. What you were doing, what tools/stack involved.
- **Problem** — must be clear standalone. What went wrong and why.
- **Fix** — must be clear standalone. What worked and why it works.

Optional fields (add only when valuable):
- **Source:** link to docs/issue/PR that confirmed fix
- **See also:** cross-reference to related lessons

## Table of Contents

Every domain file has a TOC at the top listing all lesson headings.
Maintain it when adding lessons (append a line). Format:

```markdown
# Docker

## Contents
- Buildkit cache miss on multi-stage builds
- Compose DNS resolution between services
- Multi-platform builds with QEMU
```

## How Claude Finds Lessons

1. `knowledge/INDEX.md` contains a keyword map (@imported by CLAUDE.md)
2. Keyword match → Read the domain file
3. Scan TOC or headings → find relevant lesson
4. **Always mention** to user that a KB entry was found
5. Apply if relevant; confirm with user before any KB modifications

## Modifying the Knowledge Base

**Always confirm with user first.** Never auto-edit, auto-merge, or
auto-delete knowledge-base content. This applies to adding new lessons,
updating existing ones, merging files, and any structural changes.

## Relationship to patterns/

`knowledge/` = specific lessons from specific struggles (frequent writes).
`patterns/` = generalized, reusable design approaches (rare writes).

A lesson that recurs across multiple domains and generalizes well is a
candidate for promotion to `patterns/`. This is surfaced during
`/review-knowledge-base` runs, not done automatically.

## Memory Consolidation

The `patterns/memory-consolidation.md` pattern describes how episodic
observations could be clustered into semantic facts. For this knowledge
base, the simplified version is: the structured terse format (context/
problem/fix) IS the consolidation — it forces you to extract the
semantic lesson at write time rather than dumping raw observations.
No separate consolidation pass is needed unless the KB grows large enough
to warrant automated clustering.
