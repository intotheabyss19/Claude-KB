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
│   ├── working-rules.md   — behavioral rules + terse output defaults
│   ├── skill-routing.md   — how skills get matched (pending design)
│   ├── knowledge-architecture.md — lesson storage design (pending design)
│   └── project-lifecycle.md      — /project command design (pending design)
├── output-styles/         — user-togglable output styles
│   └── caveman.md         — terse/compressed chat output (default-on)
├── skills/                — custom skills (symlinked into ~/.claude/skills/)
│   ├── compress/          — regex-based prose compression
│   ├── commit-messages/   — conventional commit generation
│   ├── code-review/       — terse one-line-per-finding reviews
│   └── review-knowledge-base/ — monthly KB health check
├── patterns/              — architecture/design how-to (rare writes)
│   ├── skill-authoring.md
│   ├── subagent-design.md
│   └── memory-consolidation.md
└── knowledge/             — task-specific lessons learned (frequent writes)
```

## Distribution

CLAUDE.md and individual skill folders are symlinked into `~/.claude/`.
This makes them available in every Claude Code session, in every project.
knowledge/, patterns/, and docs/ are NOT symlinked — CLAUDE.md references
this repo's absolute path so Claude reads them directly.

## Git

Every update is a reviewable commit. No silent mutations. Git history
is the only undo mechanism (no separate backup system).
