#!/usr/bin/env bash
# kb-guard: UserPromptSubmit hook enforcing the KB Contract (see docs/working-rules.md).
#   STRONG task-start   -> RETRIEVE-FIRST + COMPONENT-AUDIT gate (derive the approach FROM the KB,
#                          not invent-then-verify). Fixes the repeated "KB had it, I missed it" loss.
#   weaker task context -> one-line mid-task reminder (kept short to avoid banner-blindness).
#   directive/durable   -> capture nudge (SAVE the fact this turn).
# Reminds; never blocks. Fail-open: any error path still exits 0 with no output.

MEM="$HOME/.claude-ashish/projects/-home-ysh-Projects-Eris/memory/MEMORY.md"
INDEX="/home/ysh/Desktop/Obsidian/Prompts/Claude/knowledge/INDEX.md"

payload="$(cat 2>/dev/null)"
prompt=""
command -v jq >/dev/null 2>&1 && prompt="$(printf '%s' "$payload" | jq -r '.prompt // empty' 2>/dev/null)"
[ -z "$prompt" ] && exit 0
lc="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

out=""

# --- branch 1: STRONG task-start -> retrieve-first + component-audit GATE ---
if printf '%s' "$lc" | grep -Eq '\bsolve\b|setup_challenge|new (challenge|problem|task)|tackle (the|this|a)|start(ing)? (the|this|a) (challenge|problem)'; then
  out="${out}[KB GATE - RETRIEVE then AUDIT before any approach idea. Do 1-3 and SHOW them BEFORE you propose or code a solution. This is a HARD ORDER: KB first, thinking second - do NOT invent an approach and then check the KB (that is the exact loop that lost the last 4 challenges). Skip only if already shown for THIS challenge this session.]
1. RETRIEVE FIRST: name the KIND, then actually READ the binding files - rg -i '<KIND>' \"$MEM\" \"$INDEX\", then Read the matching memory/project_*.md AND the eris-playbook recipe/catalog row for that KIND. Derive the approach FROM what you read. A KB hit outranks instinct until evidence overturns it.
2. METRIC-TARGET (one line): the exact quantity + granularity the score rewards. Frame from THAT + how the data was generated - NOT the domain label or problem.md's suggested method (both are slop).
3. COMPONENT AUDIT - one row each; cite the GOVERNING playbook recipe by name, OR write 'no recipe / DEVIATING: <why>'. Checkmarks are not allowed - each cell needs the specific recipe. This is where past challenges were lost by building components on instinct:
   Frame | Augmentation (match the data's real invariances, e.g. rotation, not just h/v flip) | Loss (metric-faithful) | Decode/output (exact-metric SET decode + count prior - NOT a fixed threshold) | CV (match the shift) | Hardware+runtime (CPU-native if the grader is CPU? did you profile the real SCRIPT-RUN, not a GPU dev CSV?) | Submission (ship a verified attempt EARLY with a real grading buffer).
   Do NOT write solution.py until this table is shown; RE-VERIFY the table against the SHIPPED code before EVERY submit (did the code actually do what the row claimed?).

"
# --- branch 1b: weaker task context -> light mid-task reminder ---
elif printf '%s' "$lc" | grep -Eq 'challenge|problem\.md|dataset|benchmark|solution\.py|leaderboard|baseline|kaggle|\bimplement\b'; then
  out="${out}[KB mid-task] Is your component-audit table (Frame/Aug/Loss/Decode/CV/Hardware/Submission) still honored by the CURRENT code + plan? Re-check the relevant row before you build or submit on it.

"
fi

# --- branch 2: directive / durable-fact -> capture nudge (fixes 'made me re-tell you') ---
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
