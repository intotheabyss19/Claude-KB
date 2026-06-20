# Pattern: Token-Efficient Subagent Design

Design patterns for subagents that minimize token consumption while
preserving output quality. Applicable to any multi-agent system.

Attribution:
  Patterns synthesized from:
  - github.com/JuliusBrussee/caveman — agents/cavecrew-*.md
  - github.com/JuliusBrussee/caveman-code — docs/reference/subagents.md
  Both MIT (c) 2026 Julius Brussee

---

## Core Principle

Subagents that speak terse consume ~60% fewer tokens than vanilla agents.
This means the PARENT's context lasts longer — the subagent's compressed
summary takes less space when injected back.

## Three-Role Taxonomy

### Investigator (Read-Only Locator)

Purpose: Find things. Report locations. Stop.
Tools: Read, Grep, Glob, Bash (read-only)
Model: Cheapest available (haiku-class)

Output contract:
```
<path:line> — `<symbol>` — <≤6 word note>
```

Group with one-word headers when 3+ rows: `Defs:` / `Refs:` / `Callers:` / `Tests:`
Zero hits → `No match.`
Last line → totals: `2 defs, 5 refs.`

Key constraints:
- Never suggest fixes (that's builder's job)
- Never edit files
- Never design solutions

### Builder (Surgical Editor)

Purpose: Make small, bounded edits. 1-2 files max.
Tools: Read, Edit, Write, Grep, Glob
Model: Mid-range

Output contract (receipt):
```
<path:line-range> — <change ≤10 words>.
verified: <re-read OK | mismatch @ path:line>.
```

Key constraints:
- Hard refuse 3+ file scope → "too-big. split: <n tasks>."
- No new abstractions, no drive-by refactors
- Always read before edit, re-read after edit
- No shell access (can't push, delete, or run tests)

### Reviewer (Diff/File Auditor)

Purpose: Read diffs/files, produce findings.
Tools: Read, Grep, Bash (git diff/log only)
Model: Cheapest available (haiku-class)

Output contract:
```
path/file.ts:42: 🔴 bug: <problem>. <fix>.
totals: 1🔴 1🟡 1❓
```

Key constraints:
- Review only what's in front of you — no "while we're here"
- No big-refactor proposals
- Formatting nits skipped unless they change meaning
- Security findings get full English explanation, then resume terse

## Design Rules

1. **Constrain tools explicitly.** An investigator with Edit access will
   try to fix things. Remove the temptation.

2. **Structured refusals over silent failures.** When scope is exceeded,
   the subagent should name the problem and suggest the right agent:
   `Read-only. Spawn builder.`

3. **Receipt-style output.** The parent needs to verify, not re-read.
   Receipts are cheaper than full transcripts.

4. **Auto-clarity for security.** Every terse agent must drop to plain
   English for security warnings. This is non-negotiable.

5. **Model routing by role.** Investigators and reviewers are mechanical —
   use the cheapest model. Builders need judgment — use mid-range.
   Architects/planners need reasoning — use frontier.
