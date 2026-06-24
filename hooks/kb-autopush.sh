#!/usr/bin/env bash
# kb-autopush.sh — Stop-hook: push any unpushed commits on the Claude-KB main.
#
# PUSH-ONLY. It never stages, commits, fetches, or merges — it only pushes
# commits that already exist locally (so curated history stays intact). It is a
# silent no-op when there is nothing to push, the repo is missing, not on main,
# or offline. It never blocks the session (always exits 0).
#
# Wired as a Stop hook in ~/.claude-*/settings.json. Push uses the repo's own
# core.sshCommand (the scoped deploy key).

set -uo pipefail

# KB root = parent of this script's hooks/ dir (no hardcoded home path)
KB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)" || exit 0

[ -d "$KB/.git" ] || exit 0

branch="$(git -C "$KB" symbolic-ref --short HEAD 2>/dev/null || echo '')"
[ "$branch" = "main" ] || exit 0

# count local commits not yet on origin/main (uses last-known ref; no network)
ahead="$(git -C "$KB" rev-list --count origin/main..HEAD 2>/dev/null || echo 0)"
[ "${ahead:-0}" -gt 0 ] 2>/dev/null || exit 0

# push; non-interactive (never prompt → never hang session exit), swallow all
# output and any failure (offline, non-fast-forward, passphrase/host-key, etc.).
# ssh hardening (BatchMode, ConnectTimeout) lives in the repo's core.sshCommand.
GIT_TERMINAL_PROMPT=0 git -C "$KB" push origin main >/dev/null 2>&1 || true
exit 0
