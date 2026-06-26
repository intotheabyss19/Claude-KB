# Model Challenge Design

Designing tasks/challenges where a frontier model (Opus-4.x-class) is *meant* to fail or
struggle — red-teaming, benchmark/eval creation, adversarial testing, "make a prompt hard enough
that the model can't ace it." Distilled from a campaign that mis-estimated difficulty 4 times
before converging.

## Contents
- Pure reasoning is a weak difficulty lever
- A task the model can complete is not hard, however fiddly
- The two mechanisms that actually produce failure
- Don't cross into unfair-impossible
- Reasoning-hard vs execution-hard
- Validate difficulty with cheap proxies before the expensive run

---

### Pure reasoning is a weak difficulty lever

**Context:** Trying to design a task a frontier model fails at.
**Problem:** Frontier models are elite at "reason about this artifact" — code review, bug-finding,
debunking a plausible-but-wrong fix, static analysis. In testing, independent model instances found a
subtle concurrency bug *cold* in a focused review, and separately *rejected* a carefully-crafted wrong fix
with precise reasoning. Reasoning/analysis tasks reliably produce strong, correct output.
**Fix:** Don't build difficulty from reasoning alone — it's the model's core strength. Move difficulty to
execution, real-environment friction, or constraint conflicts.
**Caveat — the frontier exception:** This holds for routine/well-trodden problems. At the genuine frontier,
or in domains the model wasn't well-trained on (novel/complex deep learning, obscure scientific or
domain-specific work), the model's *cold* attempt is often poor — it only improves with correction, domain
skills, and RAG. That cold-vs-steered gap IS a usable lever: pose such a problem and WITHHOLD the steering;
the cold model falls into characteristic methodology errors (e.g. data leakage, wrong validation, no
baseline, wrong metric). Prefer errors that are *verifiable*, so the failure is cleanly gradeable.

### A task the model can complete is not hard, however fiddly

**Context:** Adding difficulty via a multi-step execution task (lots of setup, real debugging).
**Problem:** Fiddliness ≠ difficulty. A strong model threads fiddly, multi-failure setups quickly;
completion = success = the model "won." A genuinely intricate end-to-end deploy was finished cleanly in ~30
minutes, unguided.
**Fix:** The real test is "can a strong model FINISH it cleanly within the budget?" If yes, it's easy.
Design so the model is likely to NOT finish, or to finish only by breaking a stated rule.

### The two mechanisms that actually produce failure

**Context:** Distilling what reliably makes a strong model fail (vs merely slowing it).
**Fix:** Engineer one of these into the task:
1. **Constraint-conflict trap.** State an explicit constraint that the model's most-documented / most-natural
   solution VIOLATES. Under time pressure it tends to take the documented path and break the rule. (Example:
   "run containerized CI jobs, but no privileged containers and no host docker socket" — every mainstream
   DinD recipe uses one of those.) Detect the violation by demanding proof the constraint holds.
2. **Edge-of-feasibility.** A real task at the limit of what fits in the budget, where the model plausibly
   stalls or ships incomplete — but is still genuinely achievable (see next lesson).
Both beat "add more requirements," which only adds shallow checklist surface the model satisfies mechanically.

### Don't cross into unfair-impossible

**Context:** Escalating difficulty until the model can't do it.
**Problem:** It's easy to escalate past "hard" into "structurally impossible in this environment." That's not
a fair challenge: it penalizes the model for something outside its control, evaluators flag the task as
broken, and — crucially — a strong model often just RECOGNIZES the impossibility and explains the trade-offs
(good engineering), so it doesn't even fail. (Example: a containerized CI runner under the Kubernetes
`restricted` Pod Security Standard is genuinely impossible without a host-level runtime install.)
**Fix:** Keep the task on the fair side — provably achievable, just hard. Probe feasibility explicitly before
committing; treat "impossible-locally" as a design bug, not a success.

### Reasoning-hard vs execution-hard

**Context:** Choosing where the difficulty comes from.
**Problem:** "Subtle/clever" reads as hard but isn't, for a frontier model. "Messy real environment" is.
**Fix:** Bias toward execution in a real, fragile environment — multi-service orchestration, hardening /
security constraints, runtime debugging with a verifiable end-state. The difficulty is environmental friction
plus conflicting constraints, not the cleverness of the idea.

### Validate difficulty with cheap proxies before the expensive run

**Context:** You only learn whether a task is hard by having a model attempt it — but the real/graded attempt
is expensive (a long run, an irreversible submission, real cost).
**Problem:** Intuition about difficulty is unreliable; designers repeatedly mis-estimate (4 confident designs
in a row were all too easy or unfair). Discovering "too easy" deep into the expensive attempt wastes it.
**Fix:** Before the expensive attempt, have one or more PROXY agents (same model family) attempt the task
*exactly* as the graded subject will — the prompt verbatim, no leaked hints, no steer toward the answer — and
read the outcome. Easy success → redesign now. Run ~3 for a base rate; vary only exploration seed, not hints.
Task the proxy to also flag UNFAIR-impossible (feasibility). This is the single highest-leverage habit: it
turns expensive failures into cheap ones. For execution tasks, sandbox the probe (namespace all resources,
confine scratch, require cleanup + verify host-clean afterward).
**See also:** patterns/subagent-design.md
