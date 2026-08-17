# Repo Overview

Personal Claude Code KB at `/Users/yash/Desktop/Obsidian/Prompts/Claude/`:
lessons, patterns, and skills that compound over time.

## Structure

`ls` the repo for the layout. What it does not show: `docs/` splits into always-loaded
(working-rules, skill-routing, repo-overview) and INDEX-routed on-demand
(knowledge-architecture, project-lifecycle); `vendor/` holds third-party skills with provenance
and security review in each `<pack>/PROVENANCE.md`; `knowledge/_inbox.md` is the append-only
capture lane, `patterns/` is rare-write.

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
