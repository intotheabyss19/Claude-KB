# Project Lifecycle

How project-specific lessons are captured, stored locally, and optionally
promoted to the global knowledge base.

---

## Overview

`/project` is a skill invoked inside a specific project's folder. It
captures lessons from that project's struggles in a LOCAL location first.
Promotion to the global `knowledge/` repo happens later — either manually
or via `/review-knowledge-base`.

## Local Storage

Lessons live at `.claude/knowledge/` inside each project's own repo.

```
my-project/
├── .claude/
│   └── knowledge/
│       ├── docker.md
│       └── auth.md
├── src/
└── ...
```

This keeps lessons co-located with the project they came from. They
travel with the project's git history and are invisible to other projects.

### Git Tracking

On first `/project` run in a new project, Claude asks:

> "Should .claude/knowledge/ be gitignored or committed in this project?"

- **Gitignored:** private to your machine, won't clutter the repo or
  leak internal notes to collaborators.
- **Committed:** travels with the repo, available to collaborators and
  future you on other machines.

No global default — the user decides per project based on context.

## Lesson Capture (The Interview)

When `/project` is invoked after solving a hard problem, Claude uses
a minimal interview:

1. Claude summarizes the struggle it observed (context/problem/fix)
   using the structured terse format from `docs/knowledge-architecture.md`
2. Presents the draft and asks: "Save to .claude/knowledge/<domain>.md?
   [y/n/edit]"
3. If yes: appends to the domain file (or creates it), updates the TOC
4. If edit: user modifies the draft, then saves
5. If no: discarded, nothing written

Claude does NOT ask frequency, complexity, or threshold questions. The
user already knows whether the lesson matters. The "when worth writing
up" criteria in `docs/working-rules.md` guide Claude's judgment on
whether to even suggest a lesson — but the user can always override
in either direction.

### When Claude Suggests a Lesson

Claude should proactively suggest running `/project` when it observes:

- 2+ failed approaches before finding a fix
- A root cause that was surprising
- A problem that crossed tool/library boundaries
- The user explicitly saying "that was painful" or similar

The suggestion is always just a suggestion. Never auto-write.

## Promotion to Global

Two paths, both require user approval:

### Manual Promotion

User says "promote this to global" (or "move this to the global KB").
Claude:

1. Reads the local lesson
2. Identifies the right global domain file in `knowledge/`
3. Proposes the addition (may need to generalize project-specific
   details)
4. On approval: adds to global `knowledge/<domain>.md`, updates
   `knowledge/INDEX.md` if a new domain file was created
5. Optionally removes the local copy or marks it as promoted

### Via /review-knowledge-base

When `/review-knowledge-base` is run, it also scans `.claude/knowledge/`
in the current project directory (if it exists). For each local lesson,
it assesses whether the lesson is general enough to promote and includes
promotion candidates in its report. User approves or declines each.

## Local-Only Lessons

Some lessons are permanently project-specific and never worth promoting
(e.g., "this client's API uses nonstandard auth headers").

Mark these with a `local-only: true` field in the lesson:

```markdown
### Client API uses nonstandard auth headers

**local-only:** true
**Context:** Integration with Acme Corp API
**Problem:** Standard Bearer token rejected — API expects X-Acme-Token
**Fix:** Custom header in API client config, not Authorization header
```

`/review-knowledge-base` skips any lesson marked `local-only: true`
when suggesting promotions. The lesson stays local forever, which is
the correct outcome.

## Lesson Format

Local lessons use the same structured terse format as global lessons
(see `docs/knowledge-architecture.md`):

```markdown
### <Title>

**Context:** <what you were doing>
**Problem:** <what went wrong and why>
**Fix:** <what worked and why>
```

Optional fields: `local-only: true`, `Source:`, `See also:`

Domain files in `.claude/knowledge/` follow the same TOC + heading
structure as global `knowledge/` files.
