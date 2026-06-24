# Repo Overview

Personal Claude Code KB at `/home/ysh/Desktop/Obsidian/Prompts/Claude/`:
lessons, patterns, and skills that compound over time.

## Structure
```
Claude/
├── CLAUDE.md     — entry point; @imports the always-loaded docs
├── docs/         — working-rules.md + skill-routing.md + repo-overview.md are
│                   always loaded; knowledge-architecture.md + project-lifecycle.md
│                   load on demand via INDEX
├── skills/       — custom skills + REGISTRY.md (active/dormant set + budget ledger)
├── vendor/       — third-party skills: scientific-agent-skills (submodule);
│                   agent-verifier, agent-skills, anthropics-skills, skills-catalog
│                   (plain copies). Provenance + security review in each
│                   <pack>/PROVENANCE.md
├── patterns/     — reusable design how-to (rare writes)
├── knowledge/    — task-specific lessons; INDEX.md = keyword map; _inbox.md =
│                   append-only capture lane
├── hooks/        — kb-autopush.sh (auto-sync Stop-hook)
└── setup.sh      — installer for sharing the KB
```

## Distribution & activation
- Source of truth is this repo. `CLAUDE.md` + each ACTIVE skill folder are
  symlinked into BOTH `~/.claude-work/` and `~/.claude-personal/` (NOT
  `~/.claude/`, kept vanilla). `docs/`, `knowledge/`, `patterns/` are read by
  absolute path, not symlinked.
- **Active vs dormant:** only symlinked skills cost description budget every
  turn; everything else sits on disk at 0 tokens. **Vendor broadly, activate
  narrowly.** Full activation procedure + char ledger: `skills/REGISTRY.md`.
- Submodule update: `git submodule update --remote vendor/scientific-agent-skills`.

## Sharing
Skill files are committed but activation + the submodule are machine-specific.
A friend clones with submodules and runs the installer:
```sh
git clone --recurse-submodules git@github.com:intotheabyss19/Claude-KB.git
cd Claude-KB && ./setup.sh        # symlinks active skills into ~/.claude
```
`setup.sh` keeps its `VENDOR_ACTIVE` list in sync with `skills/REGISTRY.md`;
`/learn-kb` onboards newcomers. The rules/knowledge layer isn't installed
(machine-specific paths) — skills work without it.

## Git
Every update is a focused, reviewable commit; git history is the only undo.
Auto-sync: the `kb-autopush` Stop-hook pushes unpushed `main` (push-only, deploy key).
