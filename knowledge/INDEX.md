# Knowledge Index

Keyword map pointing to domain files in `knowledge/` and `patterns/`.
Claude reads this to find relevant lessons before solving a problem.
Update this file when adding new domain files or lessons.

## How to Use

When working on a task, scan keywords below. On match, read the linked
file. Always mention to the user that a KB entry was found.

## Domain Map

> Format: `keyword1, keyword2 → knowledge/domain.md`. One line per domain file.
> Query-time graph requests ("map a codebase") are owned by the graphify
> *skill*, not this map — INDEX only routes the install/config gotcha below.

- graphify install, graphify setup, CLAUDE_CONFIG_DIR, graphify-out gitignore, "do not graph the KB", graphify update → knowledge/tooling.md
- eris, shipd, challenge, public.zip, setup_challenge, dataset/public, submission.csv, benchmark challenge → knowledge/eris.md

## Patterns (cross-domain)

- skill, SKILL.md, description, frontmatter → patterns/skill-authoring.md
- subagent, multi-agent, investigator, builder, reviewer, decompose, fan out, orchestrate, parallel agents, when to use subagents, workflow shapes → patterns/subagent-design.md
- memory, consolidation, episodic, semantic → patterns/memory-consolidation.md

## Docs (on-demand reference — not auto-loaded)

- lesson format, domain file, TOC, split limit, how to store a lesson, knowledge architecture → docs/knowledge-architecture.md
- capture a project lesson, promote to global, local-only lesson, /project lifecycle → docs/project-lifecycle.md
