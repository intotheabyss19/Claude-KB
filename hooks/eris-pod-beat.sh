#!/usr/bin/env bash
# PreToolUse(Bash), async. Every tool call proves THIS session is alive, so its session
# heartbeat and pod heartbeat are refreshed automatically. Claude never has to remember
# pod_beat.sh. If the session dies, beats stop, the reaper deletes the pod within the
# idle window, and its challenge claims go stale and become available.
#
# Scoped to the calling session on purpose. It used to beat one machine-global pod-state
# file, so ANY session's tool call kept a dead owner's pod alive and the reaper could
# never conclude the owner had gone. Beating only your own state is what makes
# "has this session stopped?" answerable, which the claim lock depends on.
SCRIPTS="$HOME/Projects/Eris/.claude/skills/auto-solve/scripts"
. "$SCRIPTS/eris_sid.sh" 2>/dev/null || exit 0

sid="$(cat 2>/dev/null | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("session_id","") or "")
except Exception: print("")' 2>/dev/null)"
[ -n "$sid" ] || exit 0

eris_beat_session "$sid"

S="$HOME/.eris-pods/$sid"
if [ ! -f "$S" ] && [ -f "$HOME/.eris-pod-state" ]; then
  # legacy single-file state: beat it only when it is genuinely ours
  ow="$(sed -n 's/^OWNER_SID=//p' "$HOME/.eris-pod-state" | head -1 | tr -d '"')"
  if [ -z "$ow" ] || [ "$ow" = "$sid" ]; then S="$HOME/.eris-pod-state"; else S=""; fi
fi
if [ -n "$S" ] && [ -f "$S" ]; then
  # -i.bak is the only in-place form both GNU and BSD sed accept
  sed -i.bak "s/^HEARTBEAT=.*/HEARTBEAT=\"$(date +%s)\"/" "$S" 2>/dev/null && rm -f "$S.bak"
fi
exit 0
