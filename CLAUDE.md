# Claude Code Knowledge Base

Personal knowledge base at `/Users/yash/Desktop/Obsidian/Prompts/Claude/`.
Lessons, patterns, and skills that compound over time.

## Routing - read this first, it decides what else applies

**If the working directory is an Eris project** - it has a `MASTER.md` and `SOLVER.md` at its root,
or a `base/INDEX.md` - then **the handbook there governs entirely and nothing below applies.** Read
your role file and stop. Do not load the rules, the repo layout, or the knowledge index from this
page; they are about maintaining this KB, not about solving a challenge, and one of them (the KB
Contract's order to retrieve before building) directly contradicts the handbook's regime schedule.

That schedule exists because of a measurement: with the base loaded we finished 1st on all three GPU
boards and 0 for 3 on CPU, and a friend using no base beat our best CPU attempt on the same
challenge. Whatever is in this file, it does not get to overrule that.

**Otherwise** - any other project, or KB work itself - the rules below apply, loaded on demand.

## Rules & Behavior

Read `docs/working-rules.md` before non-trivial work in a non-Eris project, and always before
changing anything in this KB. It carries the working discipline, the KB contract (retrieve before
you build; capture the moment a durable fact appears) and the terseness default.

## Repo Layout · Knowledge Index · Skill Routing

- `docs/repo-overview.md` - what lives where, how skills are activated and distributed
- `knowledge/INDEX.md` - keyword -> domain file; read it when a task matches a keyword
- `docs/skill-routing.md` - how the two routing tracks work

<!-- Nothing on this page is @imported any more. It was ~14 KB in every session, and in an Eris
session none of it was relevant: 8.9 KB of working-rules with zero mentions of Eris, plus a repo
layout and a keyword index for a different knowledge base. Always-loaded context is the scarcest
thing a session has and every byte competes with the work. These files load on demand instead, which
costs one read when they are needed and nothing when they are not.

knowledge-architecture.md + project-lifecycle.md remain on-demand via INDEX.md as before. -->
