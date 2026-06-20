# Pattern: Skill Authoring for Knowledge-Base Systems

Design patterns for creating skills (markdown files loaded by description
match) that work with Claude Code and similar agent systems.

Attribution:
  Patterns synthesized from:
  - github.com/JuliusBrussee/caveman — skill structure, SKILL.md files
  - github.com/JuliusBrussee/caveman-code — docs/reference/skills.md
  Both MIT (c) 2026 Julius Brussee

---

## Skill File Structure

```
skills/<name>/
├── SKILL.md        # LLM-facing prompt body (loaded on match)
└── README.md       # Human-facing docs (never loaded into context)
```

Key insight: separate the LLM prompt (SKILL.md) from human docs (README.md).
Different audiences, different optimization targets.

## Frontmatter

```yaml
---
name: "skill-name"
description: >
  One-paragraph description. This is what the model sees EVERY turn to
  decide whether to load the full body. Keep it specific — sloppy
  descriptions cause false matches. Include trigger phrases.
---
```

The model sees descriptions in every turn (cheap — descriptions are short).
The full body loads only when the description matches the turn's intent.

## Design Principles

### 1. Description-Match Triggers

Be specific about when a skill fires:
- List exact trigger phrases: "review this PR", "code review", "review the diff"
- List slash commands: `/review`
- List concept triggers: "security", "audit", "OWASP"

### 2. Auto-Clarity Exceptions

Every terse/compressed skill should define when to EXIT compressed mode:
- Security warnings (full explanation needed)
- Irreversible actions (confirmation must be unambiguous)
- User confusion (repeated questions, clarification requests)
- Technical ambiguity (compression creates misread risk)

This is the most important pattern — compression without escape hatches
creates real harm.

### 3. Output Contracts

Skills that produce structured output should define the exact format:
```
L<line>: <emoji> <severity>: <problem>. <fix>.
```
or:
```
<path:line> — `<symbol>` — <≤6 word note>
```

Structured output = parseable by other tools + predictable for users.

### 4. Scope Boundaries

Every skill should state what it does NOT do:
- "Reviews only — does not write the code fix"
- "Only generates the commit message. Does not run `git commit`"
- "Read-only. Refuses to suggest fixes."

Clear boundaries prevent scope creep in agent behavior.

### 5. Refusal Patterns

Define what happens when the skill can't or shouldn't act:
```
3+ files → "too-big. split: <n one-line tasks>."
Spec ambiguous → "ambiguous. ask: <one question>."
```

Structured refusals > silent failures or hallucinated answers.

## Anti-Patterns

- **Long skill bodies as defaults** — descriptions match cheaply, but sloppy
  descriptions cause false matches. Be specific.
- **Skills doing what hooks should do** — skills are model-invoked; deterministic
  invariants belong in hooks (pre/post tool-use guards).
- **Skills as long workflows** — for multi-step pipelines, use a recipe/plan
  instead of a single long skill.
- **Merging LLM prompt and human docs** — different audiences need different
  optimization. SKILL.md = dense for the model. README.md = readable for humans.
