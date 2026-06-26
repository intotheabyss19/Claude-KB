# Skill Registry

Single source of truth for skill activation state + the description-budget
ledger. Not @imported (zero session cost). Update this whenever you activate or
deactivate a skill. Reconcile against disk with the snippet at the bottom.

**Model:** vendor broadly (dormant on disk = 0 tokens) → activate narrowly (each
active skill's `description:` loads every turn against a ~8,000-char shared
budget) → bodies load only on fire. A skill used in only one project goes
**project-level** (symlinked into `<project>/.claude/skills/`) so it costs 0 in
every other session.

## Global active (symlinked into BOTH ~/.claude-personal/skills and ~/.claude-work/skills)

Measured 2026-06-25. Description chars = per-turn cost in EVERY session.

| Skill | Chars | Source | Trigger |
|-------|------:|--------|---------|
| graphify | 355 | external¹ | any codebase/architecture question; `/graphify` |
| code-review | 176 | custom | review a diff/PR for bugs + quality |
| commit-messages | 131 | custom | write a commit message |
| compress | 136 | custom | shrink/compress a markdown/KB file (no LLM) |
| project | 169 | custom | "save this lesson" / capture a project lesson |
| review-knowledge-base | 175 | custom | "review the knowledge base" |
| learn-kb | 199 | custom | `/learn-kb`; a newcomer asks "what is this / how do I use it" |
| verify-security | 260 | vendor:agent-verifier | whole-repo secret/dep/injection scan |
| interview-me | 485 | vendor:agent-skills | underspecified ask; "interview me" |
| debugging-and-error-recovery | 249 | vendor:agent-skills | systematic root-cause debugging |
| skill-creator | 319 | vendor:anthropics | create/edit/eval a skill |
| spec-driven-development | 202 | vendor:agent-skills | spec-first; new project/feature or vague requirements |

**Global budget ledger:** 12 active · **2,856 / 8,000 chars** · headroom **5,144**.
Shell `rg`/`jq` reference lives in `knowledge/shell.md` (INDEX-routed, 0 budget),
not as a skill — reference, not a procedure.
¹ `graphify` is installed separately (`~/.claude/skills/graphify`), NOT in this
repo — `setup.sh` does not recreate it. Counted in the live budget because its
description loads when present; exclude it (−355) for the repo-reproducible set.
Soft-warn at 6,500; hard stop at 8,000. Before activating globally, add the
description chars here; refuse if the new total would exceed 8,000.

## Project-active: ~/Projects/Eris (symlinked into Eris/.claude/skills/)

Load ONLY inside `~/Projects/Eris/` — 0 cost in every other session. The ML
stack + the ML-research playbook live here (Eris is the only ML project). All
symlinks point at the global KB (`vendor/…` + `skills/ml-challenge`).

`ml-challenge`, `scikit-learn`, `transformers`, `pytorch-lightning`,
`torch-geometric`, `stable-baselines3`, `pufferlib`, `shap`, `umap-learn`,
`statsmodels`, `pymc`, `optimize-for-gpu`, `timesfm-forecasting` (13).

## Dormant pools (on disk, 0 tokens — activate by symlinking)

- **vendor:agent-verifier** (4): verify-quality, verify-patterns,
  verify-language, verification. → `vendor/agent-verifier/skills/`
- **vendor:agent-skills** (21 of 24): doubt-driven-development,
  planning-and-task-breakdown, source-driven-development,
  test-driven-development, incremental-implementation, context-engineering,
  idea-refine, documentation-and-adrs, api-and-interface-design,
  frontend-ui-engineering, performance-optimization, code-review-and-quality,
  code-simplification, security-and-hardening, git-workflow-and-versioning,
  using-agent-skills, ci-cd-and-automation, observability-and-instrumentation,
  shipping-and-launch, deprecation-and-migration, browser-testing-with-devtools.
  → `vendor/agent-skills/skills/`
- **vendor:anthropics** (1): webapp-testing (Playwright UI testing; its
  `with_server.py` is a shell=True runner — feed only your own commands).
  → `vendor/anthropics-skills/skills/`
- **vendor:scientific** (135 dormant; 12 are Eris project-active above): browse
  `vendor/scientific-agent-skills/skills/`.

## Do-not-activate without care (overlap or risk)

- `code-review-and-quality` (overlaps code-review), `code-simplification`
  (overlaps /simplify + compress), `security-and-hardening` (overlaps
  /security-review + verify-security), `git-workflow-and-versioning` (overlaps
  commit-messages; fires on every code change), `using-agent-skills` (its
  session-start.sh hook is the only auto-runner in that repo — never wire it).
- **NEVER wire** `agent-skills` `hooks/simplify-ignore.sh` into settings.json —
  mutates source files in place with a gitignored sole backup (data-loss).

## Activation procedure

1. **Global** skill: check headroom in the ledger; `ln -sfn
   <KB>/vendor/<repo>/skills/<name>` into BOTH `~/.claude-personal/skills/` and
   `~/.claude-work/skills/`; add the row above; bump the ledger; if vendored,
   add to `setup.sh` `VENDOR_ACTIVE`.
2. **Project-only** skill: `ln -sfn <KB>/…/<name> <project>/.claude/skills/<name>`
   instead (0 global cost); record it under a Project-active section here.

## Reconcile registry vs disk

```sh
for cfg in ~/.claude-personal ~/.claude-work; do echo "== $cfg =="; ls "$cfg/skills"; done
ls ~/Projects/Eris/.claude/skills   # project-active set
```
