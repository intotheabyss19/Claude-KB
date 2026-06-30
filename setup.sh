#!/usr/bin/env bash
# setup.sh — one-time installer for this Claude-KB knowledge base.
#
# Run it once after cloning. It makes the ACTIVE skills available to Claude
# Code on this machine by (1) pulling the scientific-agent-skills submodule and
# (2) symlinking the active skill set into your Claude config dir.
#
# It does NOT install the behavioral rules / knowledge docs (those use
# machine-specific paths) — skills work without them. Ask the KB owner if you
# want the full rules layer too.
#
# Usage:
#   ./setup.sh                        # install into ~/.claude (the default)
#   ./setup.sh --config ~/.claude-personal --config ~/.claude-work
#   ./setup.sh --dry-run              # print what it would do; change nothing
#
# Safe to re-run. Only manages symlinks it creates; never deletes your files.

set -euo pipefail

usage() { sed -n '2,21p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'; }

# --- the clone root = this script's own directory ---
KB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY=0
CONFIG_DIRS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --config)  [ $# -ge 2 ] || { echo "error: --config needs a path" >&2; exit 2; }
               CONFIG_DIRS+=("$2"); shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument '$1' (try --help)" >&2; exit 2 ;;
  esac
done
[ ${#CONFIG_DIRS[@]} -gt 0 ] || CONFIG_DIRS=("$HOME/.claude")

# sanity: are we actually in the KB clone?
if [ ! -f "$KB_DIR/skills/REGISTRY.md" ]; then
  echo "error: this does not look like the Claude-KB clone: $KB_DIR" >&2
  exit 1
fi

say() { printf '%s\n' "$*"; }
run() { if [ "$DRY" = 1 ]; then printf '[dry-run]'; printf ' %q' "$@"; printf '\n'; else "$@"; fi; }

# --- ACTIVE vendored skills (paths relative to KB_DIR) ---
# Custom skills (every dir under skills/) are activated automatically.
# Keep this vendored list in sync with skills/REGISTRY.md when you
# activate or deactivate a vendored skill.
VENDOR_ACTIVE=(
  "vendor/agent-verifier/skills/verify-security"
  "vendor/agent-skills/skills/interview-me"
  "vendor/agent-skills/skills/debugging-and-error-recovery"
  "vendor/agent-skills/skills/spec-driven-development"
  "vendor/agent-skills/skills/test-driven-development"
  "vendor/ai-skills/skills/postgres"
  "vendor/anthropics-skills/skills/skill-creator"
  # NOTE: the 12 scientific ML skills + ml-challenge are intentionally NOT
  # global-active — they are project-level (~/Projects/Eris/.claude/skills/).
  # A friend who wants them globally can symlink any from
  # vendor/scientific-agent-skills/skills/ per skill (watch the budget).
)

# --- 1. pull the scientific-agent-skills submodule (12 active + 135 dormant) ---
say "==> Initializing scientific-agent-skills submodule…"
run git -C "$KB_DIR" submodule update --init --recursive \
  || say "  ! submodule init failed (offline?) — scientific skills will be skipped"

# --- 2. collect active skill source dirs ---
# Custom skills that are PROJECT-level only (not global) — skip in this global
# installer. Keep in sync with REGISTRY's Project-active section(s).
PROJECT_ONLY="ml-challenge"
SKILL_SRCS=()
for d in "$KB_DIR"/skills/*/; do
  [ -d "$d" ] || continue
  case " $PROJECT_ONLY " in *" $(basename "$d") "*) continue ;; esac   # skip project-only
  SKILL_SRCS+=("${d%/}")
done
for rel in "${VENDOR_ACTIVE[@]}"; do SKILL_SRCS+=("$KB_DIR/$rel"); done          # vendored-active

# --- 3. symlink into each config dir ---
linked=0; missing=0; skipped=0
for cfg in "${CONFIG_DIRS[@]}"; do
  dest="$cfg/skills"
  say "==> Installing skills into $dest"
  run mkdir -p "$dest"
  linked_names=" "   # per-dir guard against duplicate skill names (bash-3.2 safe)
  for src in "${SKILL_SRCS[@]}"; do
    name="$(basename "$src")"
    case "$linked_names" in
      *" $name "*) say "  ! skip $name — name already linked this run (collision)"; continue ;;
    esac
    if [ ! -f "$src/SKILL.md" ]; then
      say "  ! skip $name — source missing (${src#"$KB_DIR"/})"
      missing=$((missing + 1)); continue
    fi
    target="$dest/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      say "  ! skip $name — a real file/dir already exists there, not overwriting"
      skipped=$((skipped + 1)); continue
    fi
    run ln -sfn "$src" "$target"
    linked_names="$linked_names$name "
    linked=$((linked + 1))
  done
done

say ""
say "Done. linked=$linked  missing=$missing  skipped=$skipped"
say "Config dir(s): ${CONFIG_DIRS[*]}"
[ "$missing" -gt 0 ] && say "(missing usually means the submodule didn't pull — re-run with a network connection.)"
say "Next: open Claude Code here and type  /learn-kb"
