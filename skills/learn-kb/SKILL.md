---
name: learn-kb
description: Gentle, one-lesson-at-a-time intro to this knowledge base for newcomers. Use on /learn-kb, or when someone new asks "what is this", "how do I use this", or seems unsure how the KB or its skills work.
---
# Skill: Learn KB (friendly onboarding)

Teach a NON-TECHNICAL newcomer how to use this knowledge base — **one tiny
lesson at a time**, in plain words, with warmth. Assume zero jargon. Never
dump everything at once. Be encouraging, never make them feel slow.

## How to run this (for the agent)

1. **Find their progress.** Read `$HOME/.claude-kb-learn-progress` — it holds a
   single number: the last lesson they finished. No file = they're brand new
   (treat as 0).
   - If the user passed an argument:
     - `reset` / `start over` / `again` → set progress to 0, start at Lesson 1.
     - a plain number `N` → deliver Lesson N.
2. **Deliver the NEXT single lesson** (progress + 1) from the list below — just
   that one, nothing more. Keep it short, warm, and end with its "Try it."
3. **Save progress:** write the new lesson number back to
   `$HOME/.claude-kb-learn-progress`.
4. **Close gently:** end with — *"That's it for now 🙂 Come back and type
   `/learn-kb` whenever you want the next little bit."* No homework, no pressure.
5. **If they finish the last lesson:** congratulate them warmly, tell them they
   can type `/learn-kb reset` to replay anytime, and that from now on they just
   ask for whatever they need.

Rules: deliver exactly ONE lesson per visit. If they ask a question, answer it
simply first, then still advance only one lesson. Match their energy; keep it
human.

## The lessons

### Lesson 1 — What even is this?
This is a **shared brain for your AI helper, Claude**. A friend set it up and
shared it with you. Inside are lots of little **helpers** that make Claude
better at everyday stuff — writing messages, shortening notes, figuring out
what you actually want.
You don't install anything or press buttons. **You just talk to Claude like a
person**, and the right helper quietly shows up.
**Try it:** type `hi, what can you help me with?` and see what it says.

### Lesson 2 — Just ask in plain words
The number-one rule: **say what you want like you'd tell a friend.** No special
commands needed. Examples: *"Help me write a message to my landlord."* /
*"Make this paragraph shorter."* / *"Does this look okay?"*
Claude figures out which helper to use for you, automatically.
**Try it:** ask for one small real thing you need today.

### Lesson 3 — Calling a helper by name
Sometimes you want a specific helper. Type a **slash `/` then its name**. Three
friendly ones to start:
- `/interview-me` — Claude asks you easy questions to figure out what you
  really want (perfect when you're not sure).
- `/compress` — makes a long note shorter.
- `/learn-kb` — this little guide (you're using it right now!).
**Try it:** type `/interview-me` and answer a couple of questions.

### Lesson 4 — Stuck? Just say "interview me"
When you can't explain what you want, say **"interview me."** Claude will ask
one tiny question at a time until it understands. There's no wrong answer — it's
just a friendly chat to get you unstuck.
**Try it:** think of something fuzzy you want, type `interview me`, and follow
along.

### Lesson 5 — You can't really break it
Relax. **Almost everything here can be undone** — changes are saved
automatically. If something ever looks off, just say *"undo that,"* or ask the
friend who shared this with you. There's no button that breaks things.
**Try it:** nothing to do — just breathe. You're ready 🎉 From now on, just ask
for what you need. Type `/learn-kb reset` to replay these lessons anytime.
