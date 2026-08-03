#!/usr/bin/env bash
# eris-statusline: the bottom bar. Renders, left to right:
#
#   [ STATUS ]  challenge-name   (pod)   13:05
#
#   Everything shown belongs to THIS session: status, name and pod are all read from
#   per-session files (`.claude-status.<sid>`), so a session solving challenge A can never
#   display challenge B's rank, score or timing. A legacy unscoped file is honoured only when
#   its line-2 sid proves it is ours; otherwise the bar shows nothing rather than something wrong.
#
#   STATUS  - from `.claude-status.<sid>` (written by scripts/session.sh):
#             act|<text>   a HUMAN must do something (non-autonomous). Gold, CAPS, loud.
#                          Auto-dims after ACT_TTL so a forgotten pin stops shouting.
#             info|<text>  autonomous progress, e.g. "submitted a3 | 0.6896 | #2". Quiet green.
#             absent       nothing shown.
#   NAME    - from `.claude-session-label` (session.sh name). Falls back to "eris".
#   POD     - from ~/.eris-pod-state, so you can tell which session owns which RunPod box.
#   COLOUR  - one per session (hash of session_id): random across sessions, stable within one.
#
# Back-compat: a legacy `.claude-objective` file is still honoured as an `act` pin.
# Reads the session JSON on stdin. Fail-open: any error still prints something.

ACT_TTL=2700   # 45 min: after this an act pin renders dim instead of gold

input="$(cat 2>/dev/null)"
cwd=""; proj=""; sid=""
if command -v jq >/dev/null 2>&1; then
  cwd="$(printf '%s'  "$input" | jq -r '(.workspace.current_dir // .cwd // empty)' 2>/dev/null)"
  proj="$(printf '%s' "$input" | jq -r '(.workspace.project_dir // empty)' 2>/dev/null)"
  sid="$(printf '%s'  "$input" | jq -r '(.session_id // empty)' 2>/dev/null)"
fi
[ -z "$cwd" ] && cwd="$PWD"
clock="$(date '+%-I:%M %p' 2>/dev/null)"

pick() {  # this session's file only: <base>.<sid> first, then a legacy unscoped file whose line-2 sid matches
  local base="$1" f lsid
  if [ -n "$sid" ]; then
    for f in "$proj/$base.$sid" "$cwd/$base.$sid"; do
      [ -n "$f" ] && [ -s "$f" ] && { printf '%s' "$f"; return 0; }
    done
  fi
  for f in "$cwd/$base" "$proj/$base"; do          # legacy unscoped: only if it is provably ours
    [ -n "$f" ] && [ -s "$f" ] || continue
    lsid="$(sed -n 2p "$f" 2>/dev/null)"
    [ -n "$lsid" ] && [ "$lsid" = "$sid" ] && { printf '%s' "$f"; return 0; }
  done
  return 1
}

# --- name -------------------------------------------------------------------
name=""
if lf="$(pick .claude-session-label)"; then name="$(sed -n 1p "$lf" 2>/dev/null)"; fi
[ -z "$name" ] && name="eris"
short="$(printf '%s' "$name" | cut -c1-34)"

# --- colour: stable per session --------------------------------------------
seed="${sid:-$cwd}"
h="$(printf '%s' "$seed" | cksum 2>/dev/null | cut -d' ' -f1)"; [ -z "$h" ] && h=0
case $(( h % 8 )) in
  0) code=196;; 1) code=39;;  2) code=46;;  3) code=226;;
  4) code=129;; 5) code=208;; 6) code=213;; 7) code=51;; *) code=39;;
esac

# --- pod --------------------------------------------------------------------
pod=""
powner="$(sed -n 's/^OWNER_SID=//p' "$HOME/.eris-pod-state" 2>/dev/null | head -1)"
if [ -s "$HOME/.eris-pod-state" ] && { [ -z "$powner" ] || [ -z "$sid" ] || [ "$powner" = "$sid" ]; }; then
  pn="$(sed -n 's/^POD_NAME=//p' "$HOME/.eris-pod-state" 2>/dev/null | head -1)"
  [ -z "$pn" ] && pn="$(sed -n 's/^POD_ID=//p' "$HOME/.eris-pod-state" 2>/dev/null | head -1)"
  pg="$(sed -n 's/^GPU=//p' "$HOME/.eris-pod-state" 2>/dev/null | head -1)"
  [ -n "$pn" ] && pod="$(printf '%s' "${pn}${pg:+ ${pg}}" | cut -c1-26)"
fi

# --- status -----------------------------------------------------------------
line=""; born=0
if sf="$(pick .claude-status)"; then
  line="$(sed -n 1p "$sf" 2>/dev/null)"
  born="$(sed -n 3p "$sf" 2>/dev/null)"
elif of="$(pick .claude-objective)"; then          # legacy pin
  line="act|$(sed -n 1p "$of" 2>/dev/null)"
  born="$(date +%s)"
fi
[ -z "$born" ] && born=0

out=""
if [ -n "$line" ]; then
  kind="${line%%|*}"; text="${line#*|}"
  age=$(( $(date +%s) - born ))
  case "$kind" in
    act)
      if [ "$age" -lt "$ACT_TTL" ]; then
        out="$(printf '\033[1;38;5;232;48;5;220m  %s  \033[0m ' "$(printf '%s' "$text" | tr '[:lower:]' '[:upper:]')")"
      else
        out="$(printf '\033[2;38;5;220m %s \033[0m ' "$text")"
      fi
      ;;
    info) out="$(printf '\033[38;5;42m %s \033[0m ' "$text")";;
    *)    out="$(printf '\033[2m %s \033[0m ' "$line")";;
  esac
fi

printf '%s\033[1;38;5;%sm%s\033[0m' "$out" "$code" "$short"
[ -n "$pod" ] && printf '  \033[38;5;177m(pod %s)\033[0m' "$pod"
printf '  \033[2m%s\033[0m' "$clock"
