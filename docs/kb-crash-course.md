# KB Crash Course (owner's guide)

How to actually drive this KB so it compounds instead of rotting. Written for
you (the human operator), not for Claude. Skim in 2 minutes; the checklists are
the part you reuse.

> Companion docs: `working-rules.md` (Claude's behavioral contract),
> `repo-overview.md` (structure), `solving-workflow.md` (Eris Step 0).
> This guide is the "what do *I* do" layer on top of those.

---

## 1. The system in 30 seconds

Three knowledge layers, loaded differently:

| Layer | Where | Loaded | Holds |
|---|---|---|---|
| **Auto-memory** | `~/.claude-ashish/projects/-home-ysh-Projects-Eris/memory/` | `MEMORY.md` every session; files on demand | Per-challenge lessons + your feedback/preferences |
| **Global KB** | `~/Desktop/Obsidian/Prompts/Claude/` | `working-rules.md` + `knowledge/INDEX.md` every session; rest on demand | Cross-project rules, lessons, patterns, skills |
| **Project KB** | `~/Projects/Eris/.claude/knowledge/` | `solving-workflow.md` + `eris-platform.md` every session | Eris platform contract + solving playbook |

Two automatic helpers run without you:
- **`kb-guard` hook** (fires on every message you send): if your message looks
  like a task-start it tells Claude to grep the KB *before* coding; if it carries
  directive language (always/never/remember...) it tells Claude to save the fact.
- **`kb-autopush` hook** (fires when Claude stops): pushes the global KB to git.
  You never commit the KB by hand.

**The one mental model:** thin *discovery layer* (always loaded, cheap) points to
fat *content* (loaded only when relevant). Keep that separation and the KB scales;
break it (paste content into the index) and every session gets more expensive.

---

## 2. Your regular routine

### Every task (start of a challenge)
- [ ] Paste `problem.md`, run `setup_challenge.sh` as usual.
- [ ] **Confirm Claude did Step 0 before writing code:** it should name the
      closest *prior* challenge of the same kind and which lessons bind. The hook
      nudges it, but you are the check. If it starts coding cold, say
      **"do the KB preflight first."**
- [ ] If Claude proposes an approach that contradicts a KB lesson, ask why - a KB
      hit should outrank instinct until evidence overturns it.

### Whenever you say something durable (mid-chat)
- [ ] Use a **trigger word** so the capture hook fires reliably: *always, never,
      from now on, going forward, remember, note that, make sure.* Example:
      "**From now on**, stop pods the moment work ends."
- [ ] Glance that Claude actually saved it (it should mention writing to
      `memory/` or `_inbox.md`). If not, say **"save that to the KB."**
- [ ] **Red flag:** if you catch yourself explaining the same thing a 2nd time
      across sessions, capture failed. Say **"why isn't this already in the KB?"**
      That is the exact failure this setup exists to kill.

### End of session
- [ ] Nothing. `kb-autopush` syncs the global KB automatically.

### Periodic (every few challenges / weekly)
- [ ] Run **`/review-knowledge-base`** to promote accumulated `_inbox.md` notes
      into curated `knowledge/` files (promotion is human-approved on purpose).
- [ ] Skim `MEMORY.md`: is any one-line hook creeping back into a paragraph? Tell
      Claude **"re-thin MEMORY.md"** (or run the `compress` skill on a fat file).
- [ ] If you added skills, check the **~8,000-char description budget** in
      `skills/REGISTRY.md` - active skills cost tokens every turn.

---

## 3. Power moves (optional but high-leverage)

| Want to... | Do this |
|---|---|
| Force a KB lookup | Say "check the KB" / "run Step 0" / name the task kind |
| Force a save | Use a trigger word, or "capture this" / "remember this" |
| Deliberately bank a lesson | Invoke the `project` skill ("save this lesson") |
| Shrink a bloated file | Invoke the `compress` skill (regex, ~40% smaller, no LLM) |
| Promote inbox to curated | `/review-knowledge-base` |
| See/disable the hooks | `/hooks` |
| Tune what the hook nudges on | Edit `hooks/kb-guard.sh` regex branches |
| Pressure-test an approach | Ask Claude to fan out subagents (see `solving-workflow.md`) |

---

## 4. What to avoid

- **Don't ask "are you using the KB?" mid-task.** By then Step 0 was already
  skipped. Require the preflight up front instead (it is faster and it is the
  documented failure mode).
- **Don't let content leak back into `MEMORY.md` / `INDEX.md`.** Those are
  pointers. Detail belongs in the linked file. A ballooning index taxes every
  single session.
- **Don't hoard one-off facts.** A lean KB you search beats a comprehensive one
  you don't. If it is obvious-from-the-error or one-time config, skip it.
- **Don't over-activate skills.** Every active skill's description is loaded each
  turn against the shared budget. Vendor broadly, activate narrowly.
- **Don't expect memory to trigger automated behavior.** "Whenever X, do Y" needs
  a *hook*, not a memory note. The harness runs hooks; it does not run preferences.
- **Don't hand-edit curated `knowledge/` / `patterns/` expecting auto-promotion.**
  Promotion is gated through `/review-knowledge-base` by design.

---

## 5. Quick reference

| Path | What |
|---|---|
| `docs/working-rules.md` | Claude's rules incl. the **KB Contract** (retrieve + capture) |
| `docs/kb-crash-course.md` | This file |
| `knowledge/INDEX.md` | Keyword -> lesson map (always loaded) |
| `knowledge/_inbox.md` | Append-only capture lane (0 token cost, promote later) |
| `skills/REGISTRY.md` | Active skill set + description budget ledger |
| `hooks/kb-guard.sh` | Preflight + capture nudge hook |
| `hooks/kb-autopush.sh` | Auto-sync hook |
| `~/.claude-ashish/.../memory/MEMORY.md` | Auto-memory index (one-line hooks) |
| `~/Projects/Eris/.claude/knowledge/` | Eris solving playbook + platform contract |

Commands: `/review-knowledge-base`, `/learn-kb`, `/hooks`. Skills: `project`,
`compress`.

---

## 6. What I took from Google's OKF

> Source: the LinkedIn article you shared. Treat "OKF" here as the *concept the
> article describes* (organize-and-publish-knowledge-for-reuse), not a spec I can
> independently verify. The useful ideas transfer regardless.

- The value of a knowledge system is **not retrieval speed - it is organizing
  knowledge once so many queries reuse it.** "Organize the library before anyone
  searches."
- The failure mode of pure retrieve-per-query (RAG-style) is **duplication and
  per-query cost.** OKF's answer is a **shared, pre-structured layer.**
- Our KB was **already OKF-shaped** (always-loaded INDEX + MEMORY hooks + skill
  descriptions = the organized layer). It had **drifted** into carrying content -
  the RAG-style duplication OKF warns against. Thinning restored the separation.
- The article's real conclusion is **OKF + RAG are complementary.** Our new
  `kb-guard` hook adds the *active-retrieval* half (forced grep) on top of the
  *organized* half (thin index). We now run both.

### 6a. Our KB: before vs after (through the OKF lens)

| Aspect | Before | After | Verdict |
|---|---|---|---|
| Discovery layer size / session | `MEMORY.md` ~1,170 words carrying content | ~500 words of one-line hooks | **Better** (~1.1k tokens/session saved) |
| Duplication | Detail in index *and* file | Single source in file; hook points to it | **Better** |
| Retrieval discipline | Step 0 optional, often skipped | Hook forces preflight `rg` on task-start | **Better** |
| Capture reliability | Discretion; facts re-nudged across sessions | Trigger list + hook nudge on directive language | **Better** |
| Growth vs cost | Linear (more memories = more tokens every turn) | Flat (hooks stay short) | **Better** |
| Detail at a glance | Inline in index (no file open) | One file open when relevant | **Slight cost**, pay-on-relevance |
| Re-bloat risk | Index could balloon silently | Header warning + "re-thin" habit | **Better, but needs upkeep** |

**Net: clearly better than before.** One mild tradeoff (Claude opens a file when a
memory is truly relevant, instead of reading a fat summary inline) and one upkeep
duty (don't let the index re-bloat). Both are cheap next to the token savings and
the retrieval/capture guarantees.

### 6b. Google OKF vs our KB (conceptual)

| Dimension | Google OKF (as described) | Our KB |
|---|---|---|
| Goal | Share structured knowledge across many AI systems / teams | Compound one operator's problem-solving across sessions |
| Scale | Enterprise, multi-agent, multi-team | Personal, single-operator, file-based |
| Unit of knowledge | Published, connected knowledge objects | Markdown lessons/memories + skills |
| Discovery mechanism | A common knowledge layer many apps read | `@imported` INDEX + MEMORY hooks + skill descriptions |
| Retrieval | Shared layer queried by many apps | `rg` + description-match, *forced* by `kb-guard` |
| Update model | Publish into the shared layer | Capture to `_inbox`/`memory`, promote via `/review-knowledge-base` |
| Governance | Org-level | Human-approved promotion + git autopush |
| Relationship to RAG | Complement (organize + retrieve) | Same: organized layer + active retrieval |
| Biggest strength | Interoperability + reuse at scale | Zero-infra, transparent, version-controlled, tuned to one workflow |
| Biggest weakness | Infra-heavy, needs org adoption | Single-machine, manual promotion, discipline-dependent |

**Bottom line:** OKF and our KB solve different-scale problems, but the same
principle powers both - *structure knowledge once, retrieve actively at query
time.* We are not competing with OKF; we borrowed its best idea and paired it with
RAG-style active retrieval, which is exactly what the article recommends.

---

## 7. If you only remember three things

1. **At task start, make sure Claude greps the KB before coding** (Step 0).
2. **When you state a rule/fact, use a trigger word and confirm it got saved.**
3. **Periodically run `/review-knowledge-base` and keep the index thin.**
