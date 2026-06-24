# Repo Overview

Personal Claude Code knowledge base. Single source of truth for lessons
learned, reusable patterns, and custom skills. Compounds over time — every
hard-won solution gets written down so the mistake never repeats.

## Location

This repo lives at `/home/ysh/Desktop/Obsidian/Prompts/Claude/`.
Claude Code picks it up globally via selective symlinks into `~/.claude/`.

## Structure

```
Claude/
├── CLAUDE.md              — lean entry point, @imports docs/*
├── docs/                  — imported reference docs
│   ├── repo-overview.md   — this file
│   ├── working-rules.md   — behavioral rules + caveman output style
│   ├── skill-routing.md   — how skills get matched
│   ├── knowledge-architecture.md — lesson storage design
│   └── project-lifecycle.md      — /project command design (pending design)
├── skills/                — custom skills (symlinked into work/personal dirs)
│   ├── REGISTRY.md        — single source of truth: active set + budget ledger
│   ├── compress/          — regex-based prose compression
│   ├── commit-messages/   — conventional commit generation
│   ├── code-review/       — terse one-line-per-finding reviews
│   ├── project/           — project-local lesson capture + promotion
│   ├── review-knowledge-base/ — monthly KB health check
│   └── learn-kb/          — friendly one-lesson-at-a-time onboarding for newcomers
├── vendor/                — third-party skills (submodules + plain copies)
│   ├── scientific-agent-skills/ — K-Dense-AI sci skills (147; MIT submodule)
│   ├── agent-verifier/    — Aurite-ai verify-* skills (5; MIT plain copy)
│   ├── agent-skills/      — addyosmani eng skills (24; MIT; skills only, no hooks)
│   ├── anthropics-skills/ — skill-creator + webapp-testing (official)
│   └── skills-catalog/    — obviousworks README (reference index, not skills)
├── patterns/              — architecture/design how-to (rare writes)
│   ├── skill-authoring.md
│   ├── subagent-design.md
│   └── memory-consolidation.md
└── knowledge/             — task-specific lessons learned (frequent writes)
```

## Distribution

CLAUDE.md and individual skill folders are symlinked into the harness
config dirs `~/.claude-work/` and `~/.claude-personal/` (NOT `~/.claude/`).
This makes them available in every Claude Code session, in every project.

`~/.claude/` is deliberately kept vanilla — no KB symlinks. Only
`~/.claude-work/` and `~/.claude-personal/` connect to this KB. If you
ever notice `~/.claude/` has no CLAUDE.md or skills/ symlinks, that is
correct and intended, not a broken setup.

knowledge/, patterns/, and docs/ are NOT symlinked — CLAUDE.md references
this repo's absolute path so Claude reads them directly.

## Vendored Scientific Skills

`vendor/scientific-agent-skills/` is the K-Dense-AI scientific-agent-skills
repo, added as a git submodule (MIT licensed). It holds 147 skills across
bio, chem, quantum, stats, and AI/ML. The submodule is the browsable
LIBRARY — its skills are NOT all active.

**Active subset (auto-fire):** only a curated set is symlinked into
`~/.claude-work/skills/` and `~/.claude-personal/skills/`, to stay under
the ~8k-char shared skill-description budget. Currently the ~12 core AI/ML
skills: scikit-learn, transformers, pytorch-lightning, torch-geometric,
stable-baselines3, pufferlib, shap, umap-learn, statsmodels, pymc,
optimize-for-gpu, timesfm-forecasting.

**To activate another skill:** symlink it into BOTH config dirs, e.g.
`ln -sfn <KB>/vendor/scientific-agent-skills/skills/<name> ~/.claude-work/skills/<name>`
(repeat for `~/.claude-personal/skills/`). Watch the description budget —
each added skill spends from the shared ~8k chars. Deactivate by removing
the symlinks (the library copy stays).

**To update the library:** `git submodule update --remote vendor/scientific-agent-skills`
then commit the bumped pointer.

## Vendored Agent-Verifier

`vendor/agent-verifier/` is the Aurite-ai agent-verifier skill set, vendored
as a **plain copy** (not a submodule — the upstream repo is 6.5 MB of mostly
a demo GIF, vs 48 KB of actual skills). MIT licensed. Holds 5 skills;
provenance + security review in `vendor/agent-verifier/PROVENANCE.md`.

**Active subset:** only `verify-security` is symlinked into both config dirs
(read-only static scan for secrets, unpinned deps, injection, info leakage,
insecure defaults). The other four (`verify-quality`, `verify-patterns`,
`verify-language`, `verification`) are dormant on disk at zero token cost —
activate with the same `ln -sfn` pattern as the scientific skills.

**To update:** re-copy `skills/` from upstream (see PROVENANCE.md), bump the
pinned commit, re-apply any local description tuning.

## Skill Registry

`skills/REGISTRY.md` is the single source of truth for which skills are
**active** (symlinked, costing description budget every turn) vs **dormant**
(on disk, zero tokens), with a measured char-count ledger against the ~8,000
budget. Consult and update it on every activation/deactivation. It is NOT
@imported, so it costs nothing at session time.

## Git

Every update is a reviewable commit. No silent mutations. Git history
is the only undo mechanism (no separate backup system).
