#!/usr/bin/env bash
# SessionEnd. Stop the GPU the moment the OWNING session ends - that is where money leaks.
# STOP, not delete: GPU billing ends, the disk survives, a resumed session can restart it.
# The reaper deletes it outright once the idle window passes.
#
# OWNERSHIP CHECK: you may run several Claude sessions at once. Only the session that
# created the pod may stop it, or an unrelated session ending would kill a live training run.
#
# Challenge claims are deliberately NOT released here. `claude --resume` re-enters the
# same session with its work intact, and a claim released at SessionEnd could be taken by
# a sibling in the gap. Claims expire on their own once this session stops beating
# (ERIS_SESSION_TTL, default 45 min), which is the same signal used everywhere else.
SCRIPTS="$HOME/Projects/Eris/.claude/skills/auto-solve/scripts"
. "$SCRIPTS/eris_sid.sh" 2>/dev/null || true

sid="$(cat 2>/dev/null | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("session_id","") or "")
except Exception: print("")' 2>/dev/null)"

S="$HOME/.eris-pods/$sid"
[ -n "$sid" ] && [ -f "$S" ] || S="$HOME/.eris-pod-state"
[ -f "$S" ] || exit 0
POD_ID="$(sed -n 's/^POD_ID=//p' "$S" | head -1 | tr -d '"')"
OWNER="$(sed -n 's/^OWNER_SID=//p' "$S" | head -1 | tr -d '"')"
[ -n "$POD_ID" ] || exit 0

# only act when this session owns it (or ownership was never recorded)
if [ -n "$OWNER" ] && [ -n "$sid" ] && [ "$OWNER" != "$sid" ]; then
  logger -t eris-session-end "session $sid ended but pod $POD_ID belongs to $OWNER - leaving it alone" 2>/dev/null
  exit 0
fi
runpodctl pod stop "$POD_ID" >/dev/null 2>&1
logger -t eris-session-end "owning session ended, stopped pod $POD_ID" 2>/dev/null
exit 0
