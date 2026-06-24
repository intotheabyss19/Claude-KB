# Skill Routing

Two routing tracks, both auto-loaded so they work every session.

## Skills (auto-fire on description match)
The harness shows every ACTIVE skill's `description` each turn and loads its
full SKILL.md body only on intent match (slash commands work too). The active
set, per-skill triggers, and the shared **~8,000-char description budget** live
in `skills/REGISTRY.md` — the single source of truth, not hand-listed here (so
the doc can't drift from disk). Keep descriptions specific to avoid false
matches; body length doesn't affect the budget.

## Knowledge & patterns (INDEX keyword map)
`knowledge/` + `patterns/` are NOT description-routed. `knowledge/INDEX.md` is a
keyword→file map, `@imported` every session (0 description budget). On a keyword
match: read the file, briefly mention the KB entry was found, apply if relevant.
Update INDEX when adding a domain file.

Modifying KB content (add/remove/change) → follow **"Before Changing the KB"**
in `working-rules.md` (always loaded).
