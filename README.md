# Claude Code Knowledge Base

A personal, compounding knowledge base for [Claude Code](https://docs.claude.com/en/docs/claude-code):
behavioral rules, reusable patterns, and a curated set of skills, loaded
automatically into every session.

> Authoritative structure + activation details live in
> **[`docs/repo-overview.md`](docs/repo-overview.md)**, and the live skill set +
> token-budget ledger in **[`skills/REGISTRY.md`](skills/REGISTRY.md)**. This
> README is a lean overview that points there, to avoid drifting out of date.

## What's inside

- **`docs/`** — behavioral rules (always loaded) + reference manuals (loaded on
  demand via `knowledge/INDEX.md`).
- **`skills/`** — custom skills + `REGISTRY.md`, the single source of truth for
  which skills are **active** vs **dormant**, with a description-budget ledger.
- **`vendor/`** — third-party skill packs (the K-Dense scientific-skills
  submodule + plain-copied packs), each with its own `PROVENANCE.md` carrying
  the source, pinned commit, license, and a pre-install security review.
- **`patterns/`** — generalized, reusable design how-to.
- **`knowledge/`** — task-specific lessons; `INDEX.md` is the keyword map,
  `_inbox.md` an append-only capture lane.
- **`setup.sh`** installer · **`hooks/kb-autopush.sh`** auto-sync Stop-hook.

## Model: vendor broadly, activate narrowly

Skills sit on disk at zero token cost until **activated** — symlinked into the
Claude config dir(s). Only active skills spend the shared ~8,000-char
description budget each turn; everything else stays dormant. A skill used in
only one project is activated **project-level** (`<project>/.claude/skills/`) so
it costs nothing elsewhere. See `skills/REGISTRY.md` for the active set + budget.

> This KB activates into `~/.claude-personal/` and `~/.claude-work/` (kept
> separate), **not** the vanilla `~/.claude/`.

## Use / share

Clone with submodules and run the installer:

```sh
git clone --recurse-submodules <remote> Claude-KB
cd Claude-KB && ./setup.sh        # symlinks the active skill set into ~/.claude
```

Then open Claude Code and type **`/learn-kb`** for a gentle, one-lesson-at-a-time
intro. `setup.sh` installs the *skill* layer (not the machine-specific
rules/knowledge layer — skills work without it).

## Attribution & licenses

- This repository is licensed under **GPL-3.0** (see [`LICENSE`](LICENSE)).
- **Vendored skill packs retain their own licenses** (mostly MIT) — see each
  `vendor/<pack>/PROVENANCE.md`.
- Output-style + subagent patterns adapted from
  [caveman](https://github.com/JuliusBrussee/caveman) /
  [caveman-code](https://github.com/JuliusBrussee/caveman-code)
  (MIT © 2026 Julius Brussee); working-rules foundation from
  [Karpathy's dotfiles](https://github.com/karpathy/dotfiles).
