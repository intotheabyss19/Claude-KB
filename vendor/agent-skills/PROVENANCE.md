# Provenance — agent-skills (addyosmani)

Third-party skills, vendored as a **plain copy of `skills/` only**.

- **Source:** https://github.com/addyosmani/agent-skills
- **Pinned commit:** `e0d2e437477d0767ae8453d4754f6945001b4ed5`
- **License:** see `LICENSE` (MIT)
- **Vendored on:** 2026-06-25

## What's here / what's deliberately NOT

Copied: the 24 `skills/` (pure-markdown engineering guides + their
references). **Excluded on purpose:** the repo's `hooks/`, `commands/`,
`agents/`, top-level `scripts/`, and `plugin.json`.

**Security reason for excluding hooks:** `hooks/simplify-ignore.sh` is a live
hook that mutates source files in place, keeping the only copy of "hidden"
code in a gitignored cache — a real data-loss path. `session-start.sh` would
inject a meta-skill into every session (standing token cost). Vendoring
markdown skills alone auto-runs **nothing**. Never copy any hook JSON into
settings.json.

## Active subset

`interview-me`, `debugging-and-error-recovery` (symlinked into both config
dirs). All other 22 are dormant — see `skills/REGISTRY.md` for the list and
which overlap existing skills.

## To update

Re-copy `skills/` from upstream (skills only, never hooks), bump the pinned
commit above.
