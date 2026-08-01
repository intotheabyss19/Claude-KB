#!/usr/bin/env bash
# SessionStart. Tell a session what is ACTUALLY its own, and what belongs to a sibling
# session that is still alive. Emits additionalContext so the model sees it.
#
# This hook used to read one machine-global pod-state file and report every job with a
# dead pid as "interrupted, restart it". With parallel sessions that is wrong twice over:
# a sibling's pod was announced to everyone as "inherited, it is billing you", and a
# sibling sitting between turns has no running pid either, so its healthy work looked
# abandoned. On 2026-08-01 that put three sessions on one challenge.
SCRIPTS="$HOME/Projects/Eris/.claude/skills/auto-solve/scripts"
. "$SCRIPTS/eris_sid.sh" 2>/dev/null || true
JOBS="$HOME/.eris-jobs"
out=""

IN="$(cat 2>/dev/null)"
sid="$(printf '%s' "$IN" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("session_id","") or "")
except Exception: print("")' 2>/dev/null)"
[ -n "$sid" ] && eris_beat_session "$sid"

alive() { eris_alive "$1"; }

if [ -n "$sid" ]; then
  out="YOUR SESSION ID: $sid
Prefix eris scripts with ERIS_SID=$sid so pods, jobs and challenge claims are attributed
to you (CLAUDE_SESSION_ID is not set in the Bash tool environment)."
fi

# --- pods: only yours, plus any ORPHANED one, which is a real money leak ------------
for f in "$HOME"/.eris-pods/* "$HOME/.eris-pod-state"; do
  [ -f "$f" ] || continue
  pid="$(sed -n 's/^POD_ID=//p' "$f" | head -1 | tr -d '"')"
  [ -n "$pid" ] || continue
  pn="$(sed -n 's/^POD_NAME=//p' "$f" | head -1 | tr -d '"')"
  pg="$(sed -n 's/^GPU=//p' "$f" | head -1 | tr -d '"')"
  hb="$(sed -n 's/^HEARTBEAT=//p' "$f" | head -1 | tr -d '"')"
  ow="$(sed -n 's/^OWNER_SID=//p' "$f" | head -1 | tr -d '"')"
  idle=$(( ( $(date +%s) - ${hb:-0} ) / 60 ))
  if [ -n "$ow" ] && [ -n "$sid" ] && [ "$ow" != "$sid" ]; then
    alive "$ow" && continue      # a live sibling owns it; not yours to touch or kill
    out="$out
ORPHANED RUNPOD POD: ${pn:-$pid} (${pg:-gpu}), idle ${idle}m, owner ${ow:0:8} is no longer
beating. It is still billing. Run: ERIS_SID=$ow $SCRIPTS/pod_down.sh"
  else
    out="$out
YOUR RUNPOD POD: ${pn:-$pid} (${pg:-gpu}), idle ${idle}m. It is billing you.
Either resume work on it or run $SCRIPTS/pod_down.sh now."
  fi
done

# --- jobs: only yours, or genuinely ownerless ---------------------------------------
pend=""; foreign=""
if [ -d "$JOBS" ]; then
  for d in "$JOBS"/*/; do
    [ -d "$d" ] || continue
    [ -f "$d/done" ] && continue
    p="$(cat "$d/pid" 2>/dev/null)"
    kill -0 "$p" 2>/dev/null && continue
    n="$(basename "$d")"; ow="$(cat "$d/owner" 2>/dev/null)"
    jcwd="$(basename "$(cat "$d/cwd" 2>/dev/null)")"
    if [ -n "$ow" ] && [ -n "$sid" ] && [ "$ow" != "$sid" ] && alive "$ow"; then
      foreign="$foreign
  - $n (session ${ow:0:8}, cwd $jcwd)"
      continue
    fi
    # jobs registered before owners were stamped carry no owner at all. Fall back to the
    # CHALLENGE claim: if a live sibling owns that directory's challenge, the job is
    # theirs no matter what the registry says.
    if [ -n "$jcwd" ] && ! ERIS_SID="$sid" bash "$SCRIPTS/claim.sh" check "$jcwd" >/dev/null 2>&1; then
      foreign="$foreign
  - $n (unstamped, but '$jcwd' is claimed by a live session)"
      continue
    fi
    c=""; [ "$(cat "$d/critical" 2>/dev/null)" = "yes" ] && c=" [CRITICAL - restart this]"
    pend="$pend
  - $n$c
      cwd: $(cat "$d/cwd" 2>/dev/null)
      cmd: $(cat "$d/cmd" 2>/dev/null)
      log: $d/log"
  done
fi
[ -n "$pend" ] && out="$out
INTERRUPTED JOBS that are YOURS or ownerless (background shells do not survive a restart).
Check each log first - it may have finished its useful work before dying - then restart
the ones still needed with $SCRIPTS/job.sh start:$pend"
[ -n "$foreign" ] && out="$out
JOBS OWNED BY OTHER LIVE SESSIONS - do NOT restart, kill, or adopt these, and do not work
in their directories:$foreign"

# --- challenge claims: what is taken, so G-SELECT does not re-pick it ----------------
claims="$(ERIS_SID="$sid" bash "$SCRIPTS/claim.sh" list 2>/dev/null)"
if [ -n "$claims" ] && [ "$claims" != "(no claims)" ]; then
  out="$out
CHALLENGE CLAIMS (a 'live' claim owned by another session is OFF LIMITS in G-SELECT):
$claims
Claim yours before working: ERIS_SID=$sid $SCRIPTS/claim.sh acquire \"<Challenge>\""
fi

# closed challenges whose post-mortem was never written. ANY session can do this -
# it reads the private leaderboard in the browser plus the attempts already on disk -
# so the user should not have to reopen the original session to close the loop.
HV="$HOME/.eris-harvest"
if [ -d "$HV" ]; then
  due="$(ERIS_HARVEST="$HV" bash "$SCRIPTS/harvest.sh" due 2>/dev/null)"
  if [ -n "$due" ]; then
    out="$out
HARVEST DUE - these challenges have CLOSED and their post-mortem was never written:
$due
Run PHASE 5 of the auto-solve skill for each: open it, switch the leaderboard to Private,
record the public->private deltas, download 4-5 solutions (always whoever is above us, plus
the biggest public->private CLIMBERS), diff them against ours component by component, and
write the result into memory/ + the playbook + the mistake-ledger. Then:
  $SCRIPTS/harvest.sh done \"<Challenge Name>\"
This is how the KB compounds; skipping it means the next session repeats the loss."
  fi
fi

[ -z "$out" ] && exit 0
python3 -c '
import json,sys
print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.stdin.read()}}))' <<< "$out"
exit 0
