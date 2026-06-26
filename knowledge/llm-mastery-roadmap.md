# Roadmap: Mastering LLM Usage

Goal: become able to **challenge, guide, and amplify** frontier models to their full potential — design
tasks that genuinely stress them, steer them to high-quality output, verify and break their work, and do it
**mostly solo with calibrated instincts**. Distilled from the Boxing campaign (2026-06), where 6 probes and
4 design pivots showed how strong frontier models actually are and how to work with/against them.

## North Star — four capabilities, in order of how much they compound
1. **Predict** a frontier model's behavior on a task *before* running it (calibration).
2. **Challenge** — design tasks that reliably make it fail or struggle.
3. **Guide** — steer it interactively to high-quality output (correction, context, RAG, skills).
4. **Amplify** — orchestrate (subagents, workflows, RAG, tools) to exceed what one prompt does.

## The growth engine: predict → test → reconcile
The one habit that produces exponential growth — turn every task into a calibration rep:
1. **Predict** (write it down BEFORE running/probing): Will it succeed? Where *exactly* will it fail? How long? Which constraint will it break?
2. **Test**: run the probe / the task.
3. **Reconcile**: where was the prediction wrong, and WHY? Update your mental model + the KB.
Track your prediction hit-rate over time. Mastery = the day your predictions ≈ reality. Wrong predictions
are the most valuable data — log them, don't bury them.

## Stages
- **Stage 0 — Foundations (now).** Tooling fluency (Claude Code, skills, MCP, the trace extractor, Docker/env). The three disciplines below as reflexes. Start the prediction log.
- **Stage 1 — Calibrated operator.** Design + probe a task solo. Predictions roughly match outcomes in your main domains. Build a personal capability map. Take 1-2 domains to genuine senior depth.
- **Stage 2 — Challenger / guide.** Construct difficulty on demand (execution / constraint-conflict / frontier-domain / verifiable-failure levers). Steer interactively with skill. Orchestrate routinely. Predictions hold across domains.
- **Stage 3 — Master.** Intuition ≈ reality. Break / guide / amplify fluently across domains. Contribute novel difficulty patterns + deep failure-mode understanding. The KB becomes a curriculum you could teach from.

## DOs
- **Predict-then-test, always.** Log the prediction + outcome. This is the engine.
- **Verify everything.** A model's summary is a *claim*, not evidence. Re-run, inspect, reproduce. Actively hunt for overclaims.
- **Probe before expensive commits.** Cheap proxy first; never intuit difficulty or feasibility.
- **Keep a personal capability map.** Living doc: what frontier models ace vs struggle with, by domain, with concrete evidence. Update every task.
- **Work at the edge.** Pick tasks slightly beyond your current solo ability — growth lives there.
- **Deepen real domain expertise.** You can only judge or break what you understand at senior level. Pick 1-2 and go deep.
- **Study failure modes.** Collect concrete examples (overclaiming, wrong CV, missed code path, talking past a constraint). Patterns emerge.
- **Compound via the KB.** Capture lessons — especially wrong predictions. Review/consolidate periodically.
- **Wean off coaching deliberately.** Use assistance to learn a move once; do it solo next time.

## DON'Ts
- **Don't trust the model's self-report** — the single most common way people get burned.
- **Don't intuit difficulty** — validate with a probe.
- **Don't inflate ratings / fudge results** — honest; reviewers and reality re-check.
- **Don't equate fiddly with hard** — completion = easy, however many steps.
- **Don't pile difficulty into follow-ups** (for Boxing): difficulty belongs in the opener.
- **Don't escalate into unfair-impossible** — impossible ≠ hard.
- **Don't skip the reconcile step** — prediction without reconciliation doesn't calibrate.
- **Don't let coaching become a permanent crutch.**

## Skills to build, in priority order
1. **Verification & reproduction** — the foundation; everything rests on it.
2. **Calibrated capability modeling** — the prediction log + capability map.
3. **Difficulty engineering** — the levers ([[model-challenge-design]] / knowledge/model-challenge-design.md).
4. **Interactive steering** — correction, nudging, context/RAG/skill injection (the cold→steered gap; verified by hands-on DL experience).
5. **Orchestration** — subagents, workflows, RAG, tools (patterns/subagent-design.md).
6. **Domain depth** — 1-2 domains to senior+.

## Concrete weekly practice
- ≥1 prediction-logged task per session; reconcile after.
- Add ≥1 entry to the capability map.
- 1 KB lesson from the biggest surprise.
- Monthly: `/review-knowledge-base`; recompute your prediction hit-rate.

## For DataAnnotation / Boxing specifically
- Run the local Boxing pipeline (`DataAnnotation/Boxing/knowledge/task-design-process.md`).
- Front-load design with the `model-challenge-design` lessons to fit the time window.
- Always verify the model's output before rating; rate honestly even when it "failed to challenge."

## See also
- knowledge/model-challenge-design.md — difficulty levers + the frontier exception
- patterns/subagent-design.md — orchestration patterns
- DataAnnotation/Boxing/knowledge/ — the Boxing playbook + the worked example
