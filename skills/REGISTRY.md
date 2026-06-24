# Skill Registry

Single source of truth for skill activation state + the description-budget
ledger. Not @imported (zero session cost). Update this whenever you activate
or deactivate a skill. Reconcile against disk with the snippet at the bottom.

**Model:** vendor broadly (dormant on disk = 0 tokens) → activate narrowly
(each active skill's `description:` loads every turn against a ~8,000-char
shared budget) → bodies load only on fire.

## Active (symlinked into BOTH ~/.claude-personal/skills and ~/.claude-work/skills)

Measured 2026-06-25. Description chars are the per-turn cost.

| Skill | Chars | Source | Trigger |
|-------|------:|--------|---------|
| graphify | 355 | custom | any codebase/architecture question; `/graphify` |
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
| optimize-for-gpu | 735 | vendor:scientific | GPU/CUDA acceleration |
| shap | 501 | vendor:scientific | model explainability |
| pufferlib | 409 | vendor:scientific | high-perf RL |
| scikit-learn | 381 | vendor:scientific | classical ML |
| stable-baselines3 | 382 | vendor:scientific | standard RL |
| timesfm-forecasting | 345 | vendor:scientific | zero-shot time-series forecast |
| statsmodels | 327 | vendor:scientific | statistical models |
| pytorch-lightning | 303 | vendor:scientific | deep-learning training |
| transformers | 293 | vendor:scientific | HF Transformers |
| torch-geometric | 292 | vendor:scientific | graph neural nets |
| umap-learn | 187 | vendor:scientific | dimensionality reduction |
| pymc | 175 | vendor:scientific | Bayesian modeling |

**Budget ledger:** 23 active · **6,984 / 8,000 chars** · headroom **1,016**.
Soft-warn at 6,500 (passed — be selective); hard stop at 8,000. Before
activating a skill, add its description chars here and refuse if the new
total would exceed 8,000.

## Dormant pools (on disk, 0 tokens — activate by symlinking into BOTH dirs)

- **vendor:agent-verifier** (4): verify-quality, verify-patterns,
  verify-language, verification. → `vendor/agent-verifier/skills/`
- **vendor:agent-skills** (21 of 24): doubt-driven-development,
  planning-and-task-breakdown, spec-driven-development,
  source-driven-development, test-driven-development,
  incremental-implementation, context-engineering, idea-refine,
  documentation-and-adrs, api-and-interface-design, frontend-ui-engineering,
  performance-optimization, code-review-and-quality, code-simplification,
  security-and-hardening, git-workflow-and-versioning, using-agent-skills,
  ci-cd-and-automation, observability-and-instrumentation,
  shipping-and-launch, deprecation-and-migration,
  browser-testing-with-devtools. → `vendor/agent-skills/skills/`
- **vendor:anthropics** (1): webapp-testing (Playwright UI testing; its
  `with_server.py` is a shell=True runner — feed only your own commands).
  → `vendor/anthropics-skills/skills/`
- **vendor:scientific** (135): browse `vendor/scientific-agent-skills/skills/`.

## Do-not-activate without care (overlap or risk)

- `code-review-and-quality` (overlaps code-review), `code-simplification`
  (overlaps /simplify + compress), `security-and-hardening` (overlaps
  /security-review + verify-security), `git-workflow-and-versioning`
  (overlaps commit-messages; fires on every code change),
  `using-agent-skills` (its session-start.sh hook is the only auto-runner in
  that repo — never wire it).
- **NEVER wire** `agent-skills` `hooks/simplify-ignore.sh` into settings.json
  — mutates source files in place with a gitignored sole backup (data-loss).

## Activation procedure

1. Check headroom in the ledger above (refuse if new total > 8,000).
2. `ln -sfn <KB>/vendor/<repo>/skills/<name> ~/.claude-personal/skills/<name>`
   and repeat for `~/.claude-work/skills/<name>` (BOTH dirs).
3. Add the row here; bump the ledger total.

## Reconcile registry vs disk

```sh
for cfg in ~/.claude-personal ~/.claude-work; do
  echo "== $cfg =="; ls "$cfg/skills"
done   # both lists must match this registry's Active section
```
