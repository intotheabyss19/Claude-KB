#!/usr/bin/env bash
# eris-statusline: the always-on bottom bar. Two modes, auto-switched:
#   1. PINNED OBJECTIVE - if a `.claude-objective` file exists (current or project
#      dir), show its first line BIG in CAPS on a gold highlight + the name, e.g.
#      "SUBMIT ATTEMPT #3   cute pups". Claude writes it when a result is ready and
#      DELETES/overwrites it (supersede #1->#2, or "#2, #4") so the pin auto-clears.
#   2. LABEL - otherwise the session/challenge name + clock.
# NAME: defaults to the folder (e.g. "Eris"); on "solve X" Claude writes the
# challenge name to `.claude-session-label` and the bar switches to it.
# COLOUR: one per SESSION (hash of session_id) - random across sessions, STABLE
# within a session, so it stays the SAME when the name switches eris -> challenge.
# Reads the session JSON on stdin. Fail-open: any error still prints something.

input="$(cat 2>/dev/null)"
cwd=""; proj=""; sid=""
if command -v jq >/dev/null 2>&1; then
  cwd="$(printf '%s'  "$input" | jq -r '(.workspace.current_dir // .cwd // empty)' 2>/dev/null)"
  proj="$(printf '%s' "$input" | jq -r '(.workspace.project_dir // empty)' 2>/dev/null)"
  sid="$(printf '%s'  "$input" | jq -r '(.session_id // empty)' 2>/dev/null)"
fi
[ -z "$cwd" ] && cwd="$PWD"
clock="$(date '+%H:%M' 2>/dev/null)"

# name: `.claude-session-label` line 1 (Claude writes it on "solve X"), else folder
name=""
for f in "$cwd/.claude-session-label" "$proj/.claude-session-label"; do
  [ -n "$f" ] && [ -s "$f" ] && { name="$(sed -n 1p "$f" 2>/dev/null)"; break; }
done
[ -z "$name" ] && name="$(basename "$cwd")"
short="$(printf '%s' "$name" | awk '{ if (NF>1) print $1" "$2; else print $1 }')"

# colour: one per SESSION (hash of session_id) - stable within a session, random
# across sessions; so switching the name eris -> challenge keeps the same colour
seed="${sid:-$cwd}"
names=(red blue green yellow purple orange pink cyan)
h="$(printf '%s' "$seed" | cksum 2>/dev/null | cut -d' ' -f1)"; [ -z "$h" ] && h=0
case "${names[$(( h % 8 ))]}" in
  red) code=196;; blue) code=39;; green) code=46;; yellow) code=226;;
  purple) code=129;; orange) code=208;; pink) code=213;; cyan) code=51;;
  *) code=39;;
esac

# --- mode 1: pinned CAPS objective (gold highlight) + name in the session colour ---
for f in "$cwd/.claude-objective" "$proj/.claude-objective"; do
  [ -n "$f" ] || continue
  if [ -s "$f" ]; then
    obj="$(head -1 "$f" 2>/dev/null | tr '[:lower:]' '[:upper:]')"
    printf '\033[1;38;5;232;48;5;220m  %s  \033[0m \033[1;38;5;%sm%s\033[0m  \033[2m%s\033[0m' "$obj" "$code" "$short" "$clock"
    exit 0
  fi
done

# --- mode 2: session/challenge label in the session colour + clock ---
printf '\033[1;38;5;%sm%s\033[0m  \033[2m%s\033[0m' "$code" "$short" "$clock"
