#!/usr/bin/env bash
# now-context: inject the current local date + time into context on EVERY user
# message, so Claude knows the wall-clock naturally (e.g. "movie at 5pm" -> it
# sees it is 3pm -> 2 hours left) WITHOUT running date or any tool call.
# Wire as a GLOBAL UserPromptSubmit hook. Ignores stdin. Fail-open: always exit 0.
printf '[Current local time: %s]\n' "$(date '+%a %Y-%m-%d %H:%M %Z' 2>/dev/null)"
exit 0
