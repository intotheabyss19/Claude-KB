# Claude Code Knowledge Base

Personal knowledge base for Claude Code. Lessons learned, reusable
patterns, and custom skills that compound over time.

## What This Is

Every time a hard problem gets solved after real struggle, a lesson gets
written down so the mistake never repeats. This repo also hosts custom
skills (commit messages, code review, prose compression) and architecture
patterns (skill authoring, subagent design).

## How It Works

- **CLAUDE.md** is symlinked into `~/.claude/`, making it auto-loaded
  by Claude Code in every session, in every project.
- **skills/** folders are individually symlinked into `~/.claude/skills/`,
  making them available as slash commands everywhere.
- **output-styles/** contains user-togglable output styles (e.g., caveman/terse mode).
- **knowledge/** and **patterns/** are read directly from this repo via
  absolute paths referenced in CLAUDE.md — not symlinked.

## Structure

```
├── CLAUDE.md              — entry point (symlinked to ~/.claude/)
├── docs/                  — reference docs imported by CLAUDE.md
├── output-styles/         — user-togglable output styles
│   └── caveman.md         — terse/compressed chat output (default-on)
├── skills/                — custom skills (symlinked to ~/.claude/skills/)
│   ├── compress/          — regex-based prose compression
│   ├── commit-messages/   — conventional commit generation
│   ├── code-review/       — terse one-line-per-finding reviews
│   └── review-knowledge-base/ — monthly KB health check
├── patterns/              — architecture/design how-to
└── knowledge/             — task-specific lessons learned
```

## Attribution

Skills and patterns extracted from:
- [caveman](https://github.com/JuliusBrussee/caveman) — MIT (c) 2026 Julius Brussee
- [caveman-code](https://github.com/JuliusBrussee/caveman-code) — MIT (c) 2026 Julius Brussee
