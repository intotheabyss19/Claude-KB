# Claude Code Knowledge Base

A personal, compounding knowledge base for [Claude Code](https://docs.claude.com/en/docs/claude-code). Hard-won lessons, reusable patterns, custom skills, and output styles — loaded automatically into every Claude Code session via selective symlinks.

## Why This Exists

Every time a non-obvious problem gets solved after real struggle, a lesson gets written down so the same mistake never repeats. Over time, this builds a second brain that makes every future session smarter — Claude reads prior lessons before solving similar problems.

## How It Works

```
~/.claude/
├── CLAUDE.md → symlink → this repo's CLAUDE.md (loaded every session)
└── skills/
    ├── compress/          → symlink
    ├── commit-messages/   → symlink
    ├── code-review/       → symlink
    └── review-knowledge-base/ → symlink
```

**CLAUDE.md** is the entry point. It uses `@path/to/file` imports to pull in docs, rules, and the output style — keeping itself lean while giving Claude access to everything.

**skills/** are individually symlinked so they show up as slash commands (`/compress`, `/commit-messages`, etc.) in every project.

**knowledge/**, **patterns/**, and **docs/** are NOT symlinked. CLAUDE.md references them via absolute paths, so Claude reads them directly from this repo. This avoids cluttering `~/.claude/` while keeping everything accessible.

## Repository Structure

```
Claude/
├── CLAUDE.md                          # Entry point (@imports everything below)
│
├── docs/                              # Reference docs imported by CLAUDE.md
│   ├── working-rules.md              # Behavioral rules (Karpathy's 4 principles, adapted)
│   ├── repo-overview.md              # Repo structure and distribution model
│   ├── skill-routing.md              # How skills and knowledge get matched to tasks
│   ├── knowledge-architecture.md     # How lessons are stored, structured, and found
│   └── project-lifecycle.md          # /project command design (pending)
│
├── output-styles/                     # User-facing output style definitions
│   └── caveman.md                    # Terse/compressed output (always-on)
│
├── skills/                            # Custom skills (symlinked to ~/.claude/skills/)
│   ├── compress/                     # Regex-based prose compression
│   │   ├── SKILL.md                  # Skill definition
│   │   ├── prose-compressor.js       # Standalone compressor (~40% reduction)
│   │   └── compression-rules.md     # Full ruleset reference
│   ├── commit-messages/              # Conventional commit generation
│   │   └── SKILL.md
│   ├── code-review/                  # Terse one-line-per-finding reviews
│   │   └── SKILL.md
│   └── review-knowledge-base/        # Monthly KB health check (manual-only)
│       └── SKILL.md
│
├── patterns/                          # Generalized design approaches (rare writes)
│   ├── skill-authoring.md            # How to write good SKILL.md files
│   ├── subagent-design.md            # Token-efficient multi-agent patterns
│   └── memory-consolidation.md       # Episodic → semantic knowledge extraction
│
└── knowledge/                         # Task-specific lessons learned (frequent writes)
    └── README.md                     # Placeholder — lessons accumulate here over time
```

## Features

### Caveman Output Style

Always-on terse mode for chat replies. Drops articles, filler, pleasantries, and hedging to save tokens and keep context windows useful longer.

**Auto-clarity exceptions** — these always get full, proper English regardless of terse mode:
- Code generation, diffs, and file writes
- Commit messages and PR descriptions
- Security warnings
- Irreversible action confirmations
- Ambiguous situations
- New knowledge-base lesson authoring

Say "talk normally" to temporarily disable. "Go terse" to re-enable.

### Skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| **compress** | `/compress`, "compress this file" | Deterministic regex-based prose compression. ~40% token reduction. No LLM calls, no network. Pure computation. |
| **commit-messages** | `/commit-messages`, generating commits | Conventional commit format. Imperative mood, ≤72 chars, why-over-what. |
| **code-review** | `/code-review`, "review this PR" | One line per finding: `L<line>: <severity>: <problem>. <fix>.` Severity emojis, no throat-clearing. |
| **review-knowledge-base** | `/review-knowledge-base` (manual only) | Reads all knowledge/ and patterns/, flags staleness, contradictions, and consolidation candidates. Never auto-applies changes. |

### Working Rules

Adapted from [Karpathy's CLAUDE.md](https://github.com/karpathy/dotfiles), extended for a system that maintains its own knowledge base:

1. **Think Before Coding** — State assumptions. Surface tradeoffs. Check for existing KB lessons before writing new ones.
2. **Simplicity First** — Minimum code. No speculative features. Lessons should be skimmable in 10 seconds.
3. **Surgical Changes** — Touch only what you must. Don't "improve" adjacent lessons while fixing one.
4. **Goal-Driven Execution** — Define success criteria. Loop until verified.

Includes guidance on when a struggle is worth writing up (non-obvious fix, crossed tool boundaries, 2+ failed approaches, surprising root cause) and when it's not (obvious from error message, one-off config, well-documented elsewhere).

### Knowledge Architecture

Lessons are grouped by domain in single files (`knowledge/docker.md`, `knowledge/auth.md`, etc.). Each file has a TOC and uses structured terse format:

```markdown
### Buildkit cache miss on multi-stage builds

**Context:** Docker multi-stage build in CI
**Problem:** Cache invalidated every run — COPY . before package install
**Fix:** COPY package*.json first, RUN install, then COPY rest
```

**File size limits:**
- < 500 lines: no concern
- 500–1000: fine with TOC
- 1000–1500: flag for review
- \> 1500: split into sub-domain files

CLAUDE.md contains a keyword map that points Claude to the right domain file. Splitting is always user-initiated — Claude flags but never auto-splits.

### Patterns

Generalized, reusable design approaches — promoted from knowledge/ when a lesson recurs across multiple domains:

- **Skill Authoring** — File structure, frontmatter, description budgets, auto-clarity exceptions, refusal patterns
- **Subagent Design** — Three-role taxonomy (investigator/builder/reviewer), token-efficient output contracts, model routing by role
- **Memory Consolidation** — Episodic → semantic knowledge extraction (design pattern, not yet implemented as automation)

### Prose Compressor

Standalone Node.js tool at `skills/compress/prose-compressor.js`. No dependencies.

```js
const { compress } = require('./skills/compress/prose-compressor');
compress('I would just like to basically explain the function.');
// → { compressed: 'I would like to explain function.', before: 52, after: 37 }
```

Preserves code blocks, inline code, URLs, paths, identifiers, and version numbers byte-for-byte. See `compression-rules.md` for the full ruleset.

## Distribution Model

| What | Where | Symlinked? | Why |
|------|-------|-----------|-----|
| CLAUDE.md | `~/.claude/CLAUDE.md` | Yes | Must be in `~/.claude/` for auto-loading |
| skills/* | `~/.claude/skills/*` | Yes (individual) | Must be in `~/.claude/skills/` for slash commands |
| output-styles/ | This repo | No | @imported by CLAUDE.md |
| docs/ | This repo | No | @imported by CLAUDE.md |
| knowledge/ | This repo | No | Read via absolute path from CLAUDE.md |
| patterns/ | This repo | No | Read via absolute path from CLAUDE.md |

## Setup

```bash
# Clone the repo
git clone <your-remote> ~/Desktop/Obsidian/Prompts/Claude

# Symlink CLAUDE.md
ln -s ~/Desktop/Obsidian/Prompts/Claude/CLAUDE.md ~/.claude/CLAUDE.md

# Symlink skills
mkdir -p ~/.claude/skills
ln -s ~/Desktop/Obsidian/Prompts/Claude/skills/compress ~/.claude/skills/compress
ln -s ~/Desktop/Obsidian/Prompts/Claude/skills/commit-messages ~/.claude/skills/commit-messages
ln -s ~/Desktop/Obsidian/Prompts/Claude/skills/code-review ~/.claude/skills/code-review
ln -s ~/Desktop/Obsidian/Prompts/Claude/skills/review-knowledge-base ~/.claude/skills/review-knowledge-base
```

## Attribution

Skills and patterns extracted and adapted from:
- [caveman](https://github.com/JuliusBrussee/caveman) — MIT (c) 2026 Julius Brussee
- [caveman-code](https://github.com/JuliusBrussee/caveman-code) — MIT (c) 2026 Julius Brussee
- [Karpathy's CLAUDE.md](https://github.com/karpathy/dotfiles) — working rules foundation

## License

Personal knowledge base. Not intended for distribution.
