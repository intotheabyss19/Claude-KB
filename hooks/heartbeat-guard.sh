#!/usr/bin/env bash
# heartbeat-guard: UserPromptSubmit hook.
#
#   user signals they are LEAVING  -> remind Claude to arm a heartbeat Monitor,
#                                     so the session keeps working unattended.
#   user signals they are BACK     -> remind Claude to stop it, so heartbeats
#                                     do not accumulate across a session.
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

BACK_RE='i.?m back|im back|back now|i.?m here now|just got back|awake now'

if printf '%s' "$lc" | grep -Eq "$AWAY_RE"; then
  cat <<'MSG'
[HEARTBEAT - the user is handing you unattended time]
Arm a heartbeat BEFORE you start, or the session stalls the moment nothing is
running and the unattended hours are wasted. The main loop only runs when
something wakes it; background agents wake you when they finish, but if none are
running, nothing does.

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
If you armed a heartbeat Monitor for their absence, stop it now with TaskStop so
it does not keep firing for the rest of the session. Then summarise what changed
while they were gone, findings first.
MSG
  exit 0
fi

exit 0
