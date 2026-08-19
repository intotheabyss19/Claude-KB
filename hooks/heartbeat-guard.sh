#!/usr/bin/env bash
# heartbeat-guard: UserPromptSubmit hook.
#
#   work is STARTING or the user is LEAVING -> remind Claude to arm a heartbeat
#                                     Monitor, so work in flight keeps going.
#   work is FINISHING              -> remind Claude to stop it.
#
# The heartbeat tracks WORK IN FLIGHT, not user presence. The user coming back is
# not a reason to stop one - if the work is still running, so is the heartbeat.
#
# Reminds; never blocks. Read-only: reads stdin, writes stdout, touches nothing
# else. No network, no filesystem writes. Any error path still exits 0 silently.

payload="$(cat 2>/dev/null)"
prompt=""
command -v jq >/dev/null 2>&1 && prompt="$(printf '%s' "$payload" | jq -r '.prompt // empty' 2>/dev/null)"
[ -z "$prompt" ] && exit 0
lc="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

AWAY_RE='goodnight|good ?night|going to (sleep|bed)|off to (sleep|bed)|heading to (sleep|bed)|going to nap'
AWAY_RE="$AWAY_RE"'|i.?(ll| will) be (away|out|gone|afk|asleep|offline)|i.?m (heading |going )?(off|away|out) '
AWAY_RE="$AWAY_RE"'|i.?(ll| will) be back (in|after|by|around|soon|shortly|tomorrow|tonight|later today)|be back in [0-9]'
AWAY_RE="$AWAY_RE"'|\bbrb\b|\bafk\b|stepping (out|away)|logging off|signing off|heading out for'
AWAY_RE="$AWAY_RE"'|busy for (the next|a while|a few|[0-9])|for the next [0-9]+ ?(h|hour|hr|min)'
AWAY_RE="$AWAY_RE"'|while i.?m (asleep|away|out|gone)|until i (get |am |.?m )?back|back in the morning|till morning|until morning'
AWAY_RE="$AWAY_RE"'|continue (working )?(autonomously|on your own|without me)|work autonomously'
AWAY_RE="$AWAY_RE"'|keep (going|working) (until|while|till)|do(n.?t| not) pause (for me|and wait|until i)'
AWAY_RE="$AWAY_RE"'|no need to (ask|check with|wait for) me|don.?t wait (for me|on me)'

# Work is starting and will outlive this turn.
WORK_RE='keep (going|working)|carry on|continue( with| on)?\b|get started|start (on|building|working)'
WORK_RE="$WORK_RE"'|(run|kick|start|leave|put|set) [a-z ]{0,12}in the background|kick (it |that )?off'

# The work is over, or is being called off.
DONE_RE='(we are|we.?re|that.?s|all) (done|finished|complete)|wrap (it |this )?up|stop (working|for now|there)'
DONE_RE="$DONE_RE"'|call it (a day|a night|here)|no longer (needed|required)|stand down|shut it down|nothing (more|else) to do'

BACK_RE='i.?m back|im back|back now|i.?m here now|just got back|awake now'

if printf '%s' "$lc" | grep -Eq "$DONE_RE"; then
  cat <<'MSG'
[HEARTBEAT - the work sounds finished]
If a heartbeat Monitor is still armed, stop it now with TaskStop. It exists to carry
work in flight; once the work is done it is just noise. Then summarise what changed.
MSG
  exit 0
fi

if printf '%s' "$lc" | grep -Eq "$AWAY_RE|$WORK_RE"; then
  cat <<'MSG'
[HEARTBEAT - work is starting or being handed over]
Arm a heartbeat BEFORE you start any work that outlives this turn - background
agents, long builds, probes, monitoring, an autonomous stretch. The main loop only
runs when something wakes it; background agents wake you when they finish, but
between them nothing does, so work in flight quietly stalls.

Arm it WHETHER OR NOT the user is present. The heartbeat tracks work, not people.

  Monitor({ persistent: true, timeout_ms: 3600000,
            description: "heartbeat every 10min",
            command: 'while true; do echo "heartbeat $(date -u +%H:%MZ) - <standing instruction>"; sleep 600; done' })

The emitted line IS the wake instruction, so write it as the thing to do on
waking ("check X, fix failures, keep building"), not as the word "heartbeat".
Each line arrives as a notification and re-invokes you.

Then say what you will do with the time, and go. Do not end on a question that
blocks: they are not there to answer it. At a genuine fork, take the reversible
option, state the assumption, and keep moving.
MSG
  exit 0
fi

if printf '%s' "$lc" | grep -Eq "$BACK_RE"; then
  cat <<'MSG'
[HEARTBEAT - the user is back]
Summarise what changed while they were gone, findings first.
Do NOT stop the heartbeat merely because they returned. If work is still in flight
it still needs carrying. Stop it only when that work is finished or called off.
MSG
  exit 0
fi

exit 0
