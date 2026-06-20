# Working Rules

Behavioral rules for this knowledge-base-maintaining agent. Rooted in
Karpathy's 4 principles, adapted for a system that must maintain its own
knowledge base over time.

---

## 1. Think Before Coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

**Knowledge-base extension:** Before writing a new lesson or pattern,
check if an existing one already covers it. Duplication in the knowledge
base is worse than duplication in code — it creates contradictions that
compound silently.

## 2. Simplicity First

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

**Knowledge-base extension:** Lessons should be short enough to skim in
10 seconds. If a lesson needs a table of contents, it's too long — split
it or compress it.

## 3. Surgical Changes

Touch only what you must. Clean up only your own mess.

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

**Knowledge-base extension:** When fixing or updating one lesson, don't
rewrite unrelated lesson files. Don't "improve" adjacent patterns while
you're in the neighborhood. File a note for later if you notice something
stale.

## 4. Goal-Driven Execution

Define success criteria. Loop until verified.

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make
it work") require constant clarification.

**Knowledge-base extension:** When a struggle produces a lesson worth
writing, the success criterion is: "a future session hitting this same
problem would find and apply this lesson without re-deriving it."

---

## When a Struggle Is Worth Writing Up

Not every problem deserves a knowledge-base entry. Write a lesson when:

- The fix was non-obvious — someone will hit this again and waste time.
- The problem crossed a tool/library boundary where docs are poor.
- You tried 2+ approaches before finding one that worked.
- The root cause was surprising (not just a typo or missing import).

Don't write a lesson when:
- The fix was obvious once you read the error message.
- It's a one-off configuration unique to this project.
- The problem is well-covered by official docs with a direct link.
- You'd be writing "read the docs" with extra steps.

When in doubt, don't write it. A lean knowledge base is more valuable
than a comprehensive one nobody searches.

---

## Internal Output: Always Terse

Internal/subagent/exploration output not meant to be read by the user
must always be terse — regardless of the user-facing output style toggle.
This is not user-configurable; it's a standing efficiency constraint.

Compression rules: drop articles, filler, pleasantries, hedging.
Fragments OK. Short synonyms. No tool-call narration. Standard tech
acronyms OK (DB/API/HTTP); never invent abbreviations.

User-facing chat output style is governed separately by
`output-styles/caveman.md` (togglable by the user). The auto-clarity
exceptions listed there apply to both user-facing and internal output.
