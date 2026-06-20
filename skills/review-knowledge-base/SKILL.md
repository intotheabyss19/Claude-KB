# Skill: Review Knowledge Base

Manual-only skill for periodic health checks of the knowledge base.
Invoked explicitly by the user (e.g., "review the knowledge base" or
`/review-knowledge-base`). Intended for roughly monthly use.

NOT auto-routed — never fire this on description match alone.

---

## When Invoked

Read through `knowledge/` and `patterns/` in this repo, then produce
a structured report covering:

### 1. Accumulation Summary

- Count of files in knowledge/ and patterns/
- List what's been added or modified since the last review (use git log
  if available, otherwise report everything as "first review")
- Group by topic/domain if there are enough entries to cluster

### 2. Staleness Check

For each file, assess:
- Does this still apply? (Tool versions change, APIs deprecate)
- Is the advice still correct given current best practices?
- Flag anything that references specific versions, dates, or tools
  that may have changed

### 3. Contradiction Detection

Look for:
- Two lessons that give conflicting advice for the same situation
- A lesson that contradicts a pattern (or vice versa)
- A lesson that contradicts working-rules.md or CLAUDE.md guidance

### 4. Consolidation Candidates

Identify:
- Multiple knowledge/ lessons that cover the same domain and could be
  merged into one
- A recurring lesson in knowledge/ that's general enough to promote
  to a pattern in patterns/
- Patterns that have become too specific and should demote to knowledge/

### 5. Local Project Lessons

If `.claude/knowledge/` exists in the current working directory, also
scan it for:
- Lessons general enough to promote to global `knowledge/`
- Skip any lesson marked `local-only: true`
- For each promotion candidate, state what would need to be generalized

### 6. Structural Issues

Check:
- Any files missing attribution headers
- Any files that are too long (>100 lines of prose — suggest splitting
  or compressing)
- Any files that duplicate content from official docs (should be a link
  instead)
- Naming/organization consistency

## Output Format

Present findings as a structured report with clear section headers.
For each actionable finding, state:
- **What:** the specific issue
- **Where:** file path(s)
- **Suggestion:** proposed action

## Important Constraints

- **Read-only.** This skill produces suggestions. It never auto-applies
  changes. Every proposed edit requires user approval.
- **No CLAUDE.md/docs/ edits without approval.** If CLAUDE.md or docs/
  files need updating based on findings, propose the specific changes
  and wait for confirmation.
- **Preserve attribution.** Never suggest removing attribution headers
  from files that have them.
