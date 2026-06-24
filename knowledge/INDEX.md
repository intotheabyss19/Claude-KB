# Knowledge Index

Keyword map pointing to domain files in `knowledge/` and `patterns/`.
Claude reads this to find relevant lessons before solving a problem.
Update this file when adding new domain files or lessons.

## How to Use

When working on a task, scan keywords below. On match, read the linked
file. Always mention to the user that a KB entry was found.

## Domain Map

<!-- Add entries as domain files are created. Format:
- keyword1, keyword2, keyword3 → knowledge/domain.md
- keyword4, keyword5 → patterns/pattern.md
-->

- graphify, knowledge graph, map codebase, code graph, GRAPH_REPORT, unfamiliar codebase, project map → knowledge/tooling.md
- eris, shipd, challenge, public.zip, setup_challenge, dataset/public, submission.csv, benchmark challenge → knowledge/eris.md

## Patterns (cross-domain)

- skill, SKILL.md, description, frontmatter → patterns/skill-authoring.md
- subagent, multi-agent, investigator, builder, reviewer → patterns/subagent-design.md
- memory, consolidation, episodic, semantic → patterns/memory-consolidation.md
