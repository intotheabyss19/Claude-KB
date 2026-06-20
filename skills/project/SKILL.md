# Skill: Project

Capture project-specific lessons from hard problems into local
`.claude/knowledge/` inside the current project. Invoked after a
struggle to draft a lesson for the user to approve.

Triggers: `/project`, "save this lesson", "capture this",
"that was painful — write it down"

---

## First Run in a New Project

If `.claude/knowledge/` doesn't exist in the current project directory:

1. Create `.claude/knowledge/`
2. Ask: "Should .claude/knowledge/ be gitignored or committed in this
   project?" — then add to `.gitignore` or not based on answer
3. Proceed to lesson capture below

## Lesson Capture

1. Summarize the struggle just observed using structured terse format:

```markdown
### <Short descriptive title>

**Context:** <what you were doing, tools/stack involved>
**Problem:** <what went wrong and why — must be clear standalone>
**Fix:** <what worked and why — must be clear standalone>
```

2. Present the draft and ask:
   "Save to `.claude/knowledge/<domain>.md`? [y/n/edit]"

3. On **yes**: append to the domain file, update TOC. Create the file
   if it doesn't exist.
4. On **edit**: user modifies, then save.
5. On **no**: discard silently.

## When to Suggest This Skill

Proactively suggest "/project" when you observe:
- 2+ failed approaches before a fix
- A surprising root cause
- A problem crossing tool/library boundaries
- User frustration signals ("that was painful", "finally", etc.)

Suggestion only. Never auto-write lessons.

## Promotion

When user says "promote this to global" or "move to global KB":

1. Read the local lesson
2. Identify the right global domain file in
   `/home/ysh/Desktop/Obsidian/Prompts/Claude/knowledge/`
3. Propose the addition (generalize project-specific details if needed)
4. On approval: add to global `knowledge/<domain>.md`, update
   `knowledge/INDEX.md` if new domain file was created
5. Ask whether to remove the local copy or keep it

## Local-Only Marking

If user says the lesson is project-specific and never worth promoting,
add `**local-only:** true` to the lesson. `/review-knowledge-base`
will skip it for promotion suggestions.

## Boundaries

- Never auto-write lessons without user approval
- Never modify global `knowledge/` without explicit promotion request
- Never delete local lessons without asking
- Always use the structured terse format from `docs/knowledge-architecture.md`
- Auto-clarity exception: draft lessons in full clarity, not compressed
