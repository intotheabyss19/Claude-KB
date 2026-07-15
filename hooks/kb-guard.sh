#!/usr/bin/env bash
# kb-guard: UserPromptSubmit hook enforcing the KB Contract (see docs/working-rules.md).
#   task-start language      -> inject KB-preflight  (RETRIEVE before building)
#   directive / durable-fact -> inject capture nudge (SAVE the fact this turn)
# The hook is the mechanical backstop for two rules I otherwise skip. It only
# reminds; it never blocks. Fail-open: any error path still exits 0 with no output.

MEM="$HOME/.claude-ashish/projects/-home-ysh-Projects-Eris/memory/MEMORY.md"
INDEX="/home/ysh/Desktop/Obsidian/Prompts/Claude/knowledge/INDEX.md"

payload="$(cat 2>/dev/null)"
prompt=""
command -v jq >/dev/null 2>&1 && prompt="$(printf '%s' "$payload" | jq -r '.prompt // empty' 2>/dev/null)"
[ -z "$prompt" ] && exit 0
lc="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

out=""

# --- branch 1: task-start -> retrieval preflight (fixes "KB had it, went unused") ---
if printf '%s' "$lc" | grep -Eq 'challenge|problem\.md|dataset|benchmark|solution\.py|setup_challenge|leaderboard|baseline|kaggle|\bsolve\b|\bimplement\b|new (challenge|problem|task)'; then
  out="${out}[KB PREFLIGHT - retrieve BEFORE writing code]
Step 0 is mandatory and is the #1 skipped step (a KB lesson sat unused while the
task was re-derived - Coptic, Cross-Sport). Before the first line of code:
1. rg -i '<this task KIND>' \"$MEM\" \"$INDEX\"
2. Name the closest PRIOR item of the same KIND + its winning approach.
3. State which lessons/memories bind. A KB hit outranks instinct until disproven.

"
fi

# --- branch 2: directive / durable-fact -> capture nudge (fixes "made me re-tell you") ---
if printf '%s' "$lc" | grep -Eq "always|never|from now on|going forward|henceforth|remember|note that|keep in mind|in future|for future|don'?t forget|make sure"; then
  out="${out}[KB CAPTURE - directive / durable-fact language detected]
If the user just stated a rule, preference, correction, fact, or result that will
matter next session, SAVE it THIS TURN to memory/ or knowledge/_inbox.md. Capture
needs no approval (frictionless lane); only PROMOTING inbox -> curated knowledge/
needs approval. Deferred capture is the exact bug the user keeps paying for.
"
fi

printf '%s' "$out"
exit 0
