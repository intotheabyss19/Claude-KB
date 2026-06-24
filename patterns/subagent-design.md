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

## When to Reach for Subagents (Decomposition Playbook)

**The default is solo.** A subagent or workflow only earns its token cost
when the work is big or benefits from independence. Reach for them when:

- **Breadth** — the answer needs sweeping many files/sources. Fan out
  read-only investigators; keep the conclusion, not the file dumps.
- **Confidence** — a finding should be checked by a skeptic before you
  trust it. Spawn adversarial reviewers (verify before you commit).
- **Scale beyond one context** — a migration/audit/sweep too big for one
  window. Pipeline over the work-list.
- **Diverse perspectives** — a design or artifact improves from N
  independent angles. Draft → multi-lens critique → synthesize.

**Stay solo when:** a single-fact lookup, a small bounded edit, a
conversational turn, or anything where orchestration overhead exceeds the
work. Don't fan out to look busy.

### Which tool
- **Agent tool** — one-off subagent for a self-contained sub-task (a search,
  a review, a build). Ad-hoc, model-driven delegation.
- **Workflow tool** — deterministic multi-stage orchestration (loops,
  fan-out, pipeline) where control flow should be code, not model whim. Use
  when you need N stages, barriers, or loop-until-done.

### Orchestration shapes (each proven in this KB's own build)
- **Fan-out + synthesize** — N parallel workers on independent slices → one
  merger (e.g. multi-lens repo/security analysis).
- **Pipeline** — each item flows through stages independently, no barrier.
  Default for multi-stage per-item work.
- **Draft → critique → synthesize** — one drafts, M critics from distinct
  lenses, one integrates. Beats one-shot for design/authoring.
- **Adversarial verify** — skeptics prompted to refute a finding; keep it
  only if it survives. Kills plausible-but-wrong.
- **Loop-until-dry** — keep spawning finders until K rounds surface nothing
  new (unknown-size discovery).

### Cost discipline
Subagents multiply tokens — each stage × each agent. Scale the fleet to the
task: a quick check = 1–2 agents; "be thorough / audit this" = larger pool +
an adversarial pass. Always prefer a conclusion returned over raw context
pulled into the parent. Design each spawned agent per the roles below.

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
