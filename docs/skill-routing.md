# Skill Routing

How Claude decides which skill or knowledge-base entry to load.

---

## Skills (auto-fire on description match)

Skills in `skills/` use standard Claude Code routing: the model sees
each skill's description every turn and loads the full SKILL.md body
when the description matches the user's intent. All skills auto-fire
on match — no explicit invocation required (though slash commands work
too).

Current skills and their triggers:
- **compress** — prose compression, token reduction, shrink a file
- **commit-messages** — generating commit messages, conventional commits
- **code-review** — reviewing diffs, PRs, code review
- **review-knowledge-base** — "review the knowledge base", monthly health check

### Description budget

All skill descriptions share ~8,000 chars. Keep descriptions specific
to avoid false matches. The full SKILL.md body only loads on match,
so body length doesn't affect the budget.

## Knowledge & Patterns (keyword hints in CLAUDE.md)

Knowledge-base files (`knowledge/`, `patterns/`) are NOT routed via
the skill description system. Instead, CLAUDE.md contains a keyword
map — a short section listing topic keywords that point to relevant
knowledge files.

When Claude sees a keyword match while working on a task:
1. Read the relevant knowledge/pattern file
2. **Always mention briefly** that a KB entry was found
3. Apply the lesson if relevant

This costs zero description budget (CLAUDE.md is loaded separately).
The keyword map must be updated manually when new knowledge files are
added.

### Example keyword map (in CLAUDE.md)

```
## Knowledge Map
- docker, containers → knowledge/docker.md
- auth, JWT, sessions → knowledge/auth-patterns.md
- monorepo, workspaces → knowledge/monorepo.md
```

## Modifying the Knowledge Base

**Always confirm with the user before modifying any file in knowledge/
or patterns/.** Claude should never auto-edit, auto-merge, or auto-delete
knowledge-base content. Propose the change, state what and why, wait
for approval.

This applies to:
- Adding new lessons
- Updating existing lessons
- Merging or consolidating files
- Promoting knowledge/ entries to patterns/
- Any structural changes
