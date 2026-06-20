# Skill: Code Review

One line per finding. Location, problem, fix. No throat-clearing.

Attribution:
  Source: github.com/JuliusBrussee/caveman
  License: MIT (c) 2026 Julius Brussee

---

## Format

`L<line>: <problem>. <fix>.` — or `<file>:L<line>: ...` for multi-file diffs.

## Severity Prefix

- `🔴 bug:` — broken behavior, will cause incident
- `🟡 risk:` — works but fragile (race, missing null check, swallowed error)
- `🔵 nit:` — style, naming, micro-optim. Author can ignore
- `❓ q:` — genuine question, not a suggestion

## Drop

- "I noticed that...", "It seems like...", "You might want to consider..."
- "This is just a suggestion but..." — use `nit:` instead
- "Great work!", "Looks good overall but..." — say it once at top, not per comment
- Restating what the line does — reviewer can read the diff
- Hedging ("perhaps", "maybe", "I think") — if unsure use `q:`

## Keep

- Exact line numbers
- Exact symbol/function/variable names in backticks
- Concrete fix, not "consider refactoring this"
- The *why* if the fix isn't obvious from the problem statement

## Examples

Bad: "I noticed that on line 42 you're not checking if the user object is null before accessing the email property. This could potentially cause a crash if the user is not found in the database. You might want to add a null check here."

Good: `L42: 🔴 bug: user can be null after .find(). Add guard before .email.`

Bad: "Have you considered what happens if the API returns a 429?"

Good: `L23: 🟡 risk: no retry on 429. Wrap in withBackoff(3).`

## Auto-Clarity

Drop terse mode for: security findings (need full explanation + reference),
architectural disagreements (need rationale), onboarding contexts where
author needs the "why". Write a normal paragraph, then resume terse.
