# Provenance — anthropics-skills

Two skills vendored from Anthropic's official skills repo.

- **Source:** https://github.com/anthropics/skills
- **Pinned commit:** `57546260929473d4e0d1c1bb75297be2fdfa1949`
- **License:** per `THIRD_PARTY_NOTICES.md` + each skill's own `LICENSE.txt`
- **Vendored on:** 2026-06-25

## What's here

| Skill | Status | Notes |
|-------|--------|-------|
| `skill-creator` | **ACTIVE** | create/edit/eval skills; ships `scripts/`, `agents/`, `eval-viewer/` |
| `webapp-testing` | dormant | Playwright UI testing |

## Script-safety notes (all MANUAL-run; never auto-wired)

- `skill-creator/scripts/*` are authoring tools you invoke by hand. Several
  (`run_eval.py`, `improve_description.py`, `run_loop.py`) shell out to the
  `claude` CLI and strip the `CLAUDECODE` env var to allow nesting, passing
  the rest of the environment (incl. API keys) to the child. Fine when you
  run them; **never put them in a hook/auto-runner.**
- `eval-viewer/generate_review.py` `_kill_port()` SIGTERMs PIDs on a port
  before binding (default 3117); binds 127.0.0.1 only. Manual-run only.
- `webapp-testing/scripts/with_server.py` runs `subprocess.Popen(cmd,
  shell=True)` — a generic command runner. Safe only with your own local
  commands. (Latent bug: child stdout/stderr piped but never drained → can
  deadlock on a verbose server.)

## To update

Re-copy the two skill dirs from upstream `skills/`, bump the pinned commit.
