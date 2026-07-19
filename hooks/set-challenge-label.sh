#!/usr/bin/env bash
# UserPromptSubmit hook: when the user says "solve <X>", record <X> as THIS
# session's challenge in .claude-session-label (line 1 = name, line 2 = session_id),
# so the bottom status bar shows the challenge name for the rest of the session.
# A message that doesn't start with "solve" leaves it unchanged (so the name is
# PERMANENT after the first "solve X" until another "solve Y"). The session_id stamp
# makes it session-scoped: a fresh session shows "eris", not a stale name.
# Emits NOTHING to stdout (no context injection). Fail-open (always exit 0).
payload="$(cat 2>/dev/null)"
command -v jq >/dev/null 2>&1 || exit 0
prompt="$(printf '%s' "$payload" | jq -r '.prompt // empty' 2>/dev/null)"
sid="$(printf '%s' "$payload" | jq -r '.session_id // empty' 2>/dev/null)"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)"
[ -z "$cwd" ] && cwd="$PWD"
[ -z "$prompt" ] && exit 0

# capture the challenge name after a leading "solve [the] [challenge] ..."
name="$(printf '%s' "$prompt" | sed -nE 's/^[[:space:]]*[Ss]olve[[:space:]]+([Tt]he[[:space:]]+)?([Cc]hallenge[[:space:]]+)?(.+)$/\3/p')"
[ -z "$name" ] && exit 0
# tidy: drop a trailing " challenge", trailing space/punctuation; cap length
name="$(printf '%s' "$name" | sed -E 's/[[:space:]]+[Cc]hallenge[[:space:]]*$//; s/[[:space:]]+$//; s/["'"'"'.!?,:;]+$//' | cut -c1-48)"
[ -z "$name" ] && exit 0

printf '%s\n%s\n' "$name" "$sid" > "$cwd/.claude-session-label" 2>/dev/null
exit 0
