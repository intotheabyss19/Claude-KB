# Eris (Shipd) Challenges

ML benchmark-creation/solving platform. Each challenge ships a `public.zip`
and a challenge-detail markdown. Solving = produce a notebook/script that
reads `dataset/public/`, writes `working/submission.csv`.

## Contents
- Challenge workspace scaffold from public.zip
- Reverse-engineer the score rescale to locate the leaderboard band
- Custom-metric challenges: optimize the submission belief, don't just submit softmax
- Tiny group-stratified data with pure-class groups: classifiers invert OOF
- Exploit a STABLE OOF inversion (flip the detector)
- EMA decay too high vs total steps looks like a broken model
- Beat the baseline and SUBMIT first to claim an FCFS slot, THEN boost
- Some challenges are exact decode (CV + logic), not ML — don't train a model
- Read synthetic UI widgets across render styles by HSV value, not saturation
- Verify a "smarter" prior against the empirical posterior before coding it
- Website score << local mean → it's the worst-group terms; stratify to find them
- Marginalize variable-size hypotheses with a per-circuit prior (divide by C(n,k))
- Know when you've hit the Bayes ceiling — quantify determinacy, then stop
- Tuned-to-train knobs regress on OOD-hardened test; ship only principled fixes
- Submission credits are scarce — probes usually confirm the ceiling, budget them
- Eris grades solution.py in isolation — make it self-contained (no local imports)
- Stellar Transit: classification is the lever — river-plot CNN + smoothness feats + physics ensemble

---

### Challenge workspace scaffold from public.zip

**Context:** Starting any Eris challenge. Workspace dir holds `public.zip`
  (CSVs + an `images/` tree at the zip root, no top-level `public/` folder)
  and a challenge-detail `.md`.
**Problem:** Every challenge needs the same layout before solving —
  `dataset/public/` (unzipped data, read by the solution), `working/`
  (output dir for `submission.csv`), and `problem.md`. Doing it by hand each
  time is repetitive and easy to get wrong (e.g. unzipping to the wrong dir
  so relative paths break, since the zip has no `public/` prefix).
**Fix:** Reusable idempotent script — unzip into `dataset/public/`, make
  `working/`, copy the detail md to `problem.md`. Solutions then read
  `dataset/public/...` and write `working/submission.csv`, matching the
  platform's runtime contract (reads `/dataset/public/`, writes `./working/`).

```bash
#!/usr/bin/env bash
# setup_challenge.sh — scaffold an Eris challenge workspace from public.zip
# Usage: ./setup_challenge.sh [CHALLENGE_DIR]   (defaults to CWD)
set -euo pipefail
dir="${1:-$PWD}"; cd "$dir"
[[ -f public.zip ]] || { echo "error: no public.zip in $dir" >&2; exit 1; }
mkdir -p dataset/public working
unzip -q -o public.zip -d dataset/public
if [[ ! -f problem.md ]]; then
  detail="$(find . -maxdepth 1 -name '*.md' ! -name 'problem.md' ! -name 'NOTES.md' \
            -printf '%f\n' | head -n1 || true)"
  [[ -n "${detail:-}" ]] && cp "$detail" problem.md
fi
find . -maxdepth 2 -not -path '*/images/*' -not -name public.zip | sort
echo "images: $(ls dataset/public/images 2>/dev/null | wc -l)"
```

**See also:** standard solved-challenge layout adds `attemptN/`
  (`solution.py`, `submission.csv`, `approach.txt`) per iteration alongside
  the shared `working/`.

---

### Reverse-engineer the score rescale to locate the leaderboard band

**Context:** Eris challenge whose grade.py linearly rescales a raw metric to a
leaderboard number (e.g. `raw∈[-2,1] -> 0.02 + (raw+2)/3*0.98`).
**Problem:** Posted numbers (AI baseline 0.6844, top 0.7015) look close together
and uninformative until you invert the rescale. Inverting shows baseline ≈ raw
0.03 and top ≈ raw 0.09 — the entire leaderboard sits in a razor-thin raw band.
**Fix:** Always invert the rescale first. If the band is tiny, the belief/
referral POST-PROCESSING (decision theory on the exact metric) matters as much
as or more than the model. Build a local copy of grade.py immediately and score
every idea offline before spending submission credits. See [[eris]] grader port.

### Custom-metric challenges: optimize the submission belief, don't just submit softmax

**Context:** Grader is a non-accuracy harm/affinity metric over a probability
vector + an auxiliary signal (e.g. a referral/abstain score), often asymmetric
and with quadratic penalties and clipping.
**Problem:** Submitting raw model softmax scores badly — confident wrong-side
mass gets hammered by the penalties. The metric reward as a function of the
submitted belief p is NOT maximized at p = posterior q.
**Fix:** Separate modeling from decision. Estimate a calibrated posterior q,
then for each row solve `p* = argmax_p E_{t~q}[w_t * score(p,t)]` over the
simplex (SLSQP; the objective is concave away from the clip floor). Weight by
`w_t = 1/N_t` to match a macro-average's implicit rare-class upweighting. Tune
any global knobs (temperature, abstain threshold) against the LOCAL grader on
OOF preds. On one challenge an optimized CONSTANT belief (no model) already beat
the AI baseline, because most solvers submit softmax and leave free points.

### Tiny group-stratified data with pure-class groups: classifiers invert OOF

**Context:** Small medical/image dataset, group-disjoint train/test split
(e.g. patient-stratified), where each group is a single class and there are only
~4-9 groups per class (≈30 groups total).
**Problem:** Any fine-tuned CNN or frozen-feature classifier memorizes GROUP
identity (staining/scanner), not the disease, and collapses on held-out groups —
val accuracy drops BELOW chance and held-out AUC comes out ~0.1 (inverted), even
within a covariate stratum (so it's not that covariate's confound). More model
capacity makes it worse. Verified with ConvNeXt fine-tune (diverged), frozen
ImageNet/in12k feats + LR/kNN, and handcrafted morphometrics — all inverted.
**Fix:** Don't trust learned classifiers here. A covariate-conditioned constant
belief (e.g. one belief per magnification, optimized against the metric) is more
robust and can beat every learned model. Validate ALL choices with multi-seed
group-CV; in-sample numbers are meaningless. See also [[eris]] inversion lesson.

### Exploit a STABLE OOF inversion (flip the detector)

**Context:** A binary detector (e.g. normal vs malignant) shows a CONSISTENT
out-of-fold inversion — AUC ~0.09 across every seed, every covariate stratum,
every feature set.
**Problem:** Tempting to discard it as noise, but a *consistent* inversion is
reproducible signal: it's a property of "train on these groups -> predict NEW
groups", which is exactly the test scenario. `1 - P(class)` is then a high-AUC
detector for unseen groups.
**Fix:** Exploit it, but hedge the residual risk (the inversion may be partly
specific to the train groups). Use a soft blend (not a hard flip), keep an
abstain/referral net that sends false-positives to a safe flat score, and prove
the gain with nested multi-seed group-CV before trusting it. This took the
above lung challenge from CV 0.717 (no detector) to 0.739. The danger: if the
mis-classification is heavily penalized (e.g. -1 for crossing a clinical
boundary), a wrong flip is catastrophic — so only bet a hedged fraction.

### EMA decay too high vs total steps looks like a broken model

**Context:** Training a model with weight EMA on a small dataset (few hundred
images, ~400 total optimizer steps), evaluating the EMA weights.
**Problem:** EMA decay 0.999 has an effective window ~1000 steps, so with only
~400 steps the EMA barely leaves initialization. Eval metrics look frozen / at
chance (e.g. binary acc pinned at the majority rate) and it reads as "the model
won't learn" — when the raw weights are actually training fine.
**Fix:** Scale EMA decay to the step budget (e.g. 0.99 with warmup
`min(decay,(1+step)/(10+step))`), or evaluate raw weights to disambiguate. When
a model "won't learn", first run a tiny no-aug overfit test on the RAW model to
separate an optimization bug from an eval/EMA bug.

### Beat the baseline and SUBMIT first to claim an FCFS slot, THEN boost

**Context:** Solving Eris challenges to maximize leaderboard rank. Natural instinct
(and prior instruction) is to "go straight for complex models" and polish locally —
full k-fold CV, ensembling, TTA, post-processing — before producing a submission.
**Problem:** Eris allocates each challenge by **FCFS with a limited slot count**,
NOT an open leaderboard. Mechanism (confirmed by the user): the challenge stays open
only until enough solvers clear the AI baseline — roughly **the first ~8 above the
baseline plus ~2 below** claim the slots; once filled the challenge enters
**lockdown** and new submissions are refused. The slot-holders then get a **~24-hour
window to upgrade** their solutions and fight for rank. So a polished local pipeline
that never got an early submission in scores ZERO — it never claimed a slot, and the
work is wasted. Twice this happened (Lung Cancer, Cardiac MRI: both had
baseline-beating local CV, both locked before any submission).
**Fix:** Two phases, and Phase 1 is a RACE, not a formality. **Phase 1 — claim the
slot ASAP:** the instant a simple model clears the AI baseline on local CV (a single
fold is enough), generate `working/submission.csv` and submit to grab one of the
limited FCFS slots before they fill. Speed to first valid above-baseline submission
is the single most important thing. **Phase 2 — boost within the 24h window:** only
after the slot is secured, add folds/ensembles/TTA/post-processing and decision-rule
work, re-submitting as each improvement validates, to climb the locked field of
slot-holders. Never let local polish delay the Phase-1 submission — being late means
no slot at all, regardless of how good the solution is. (Switch-Lamp did this right:
shipped a baseline-beating submission immediately, then boosted from 5th→1st across
attempts within the window.)

### Some challenges are exact decode (CV + logic), not ML — don't train a model

**Context:** Eris challenge supplying clips/images plus a structured task —
recover a hidden circuit / rule / mapping — with train labels. (e.g. Switch-Lamp
Logic: induce each lamp's hidden gate + input switches from a panel video and a
flip log, then predict a held-out config.)
**Problem:** The "go straight for complex models" default says train a video/CNN
model. But when the target is a DETERMINISTIC function of state you can read off
the pixels plus a provided intervention log, a learned model both underperforms
and wastes the GPU. The honest solution is a decoder, not a regressor.
**Fix:** Recognize the shape: readable state + provided log + deterministic
hidden structure → build a CV reader + an exact enumerator (consistency / SAT),
zero training. Validate the CV reader to ~100% against train labels FIRST (then
the rest is pure logic). Exploit the generator's measured structure as the
disambiguation prior: on Switch-Lamp, train wiring showed fan-in 1→{BUF,NOT},
2→all 6 binary gates, 3→{XOR,XNOR} only (max 3) — this prunes the hypothesis
space hard. Enumerate every allowed (gate,subset) consistent with all observed
(config,output) pairs (the true one is always consistent), MAP-pick by min
fan-in then prior, and for a held-out query marginalize (prior-weighted majority)
over consistent candidates. Result: 100% CV, local mean-metric 0.842 vs AI
baseline 0.7139, no model trained. Remaining error is logically irreducible
(an input the interventions never exercised cannot be recovered) — size your
confidence to that.

### Read synthetic UI widgets across render styles by HSV value, not saturation

**Context:** Reading on/off state of rendered widgets (switches, lamps,
indicators) from synthetic frames, where a hidden "render_style" axis recolors
everything (e.g. green/yellow vs blue/orange schemes).
**Problem:** A saturation-only color mask (or a hard-coded green/yellow hue) works
on one style and silently fails on others: a dark but medium-saturation element —
e.g. a slider TRACK — reads as ON, corrupting every downstream state. Assuming
widgets are an even full-width split also breaks when they aren't (lamps centered
at (c+1)*W/(n+1), narrower than the switch row).
**Fix:** Detect the vivid ON indicator by HSV saturation AND high value
(S>90, V>120). High-V is the key — it rejects dark tracks/backgrounds while
staying hue-agnostic, so it survives any recoloring. Locate non-even layouts with
HoughCircles (accept the detection that returns exactly N circles) instead of
assuming spacing. For a time-series panel, states are evenly spaced in time —
sample each state's MID-frame (settled, away from transition animation). If the
widget values are derivable from a provided log, only CV the INITIAL state and
error-correct it: value[s] = majority_k(read[k][s] XOR cumulative_log[k][s]) —
denoises across all frames and makes the configs exact.

### Verify a "smarter" prior against the empirical posterior before coding it

**Context:** Disambiguating among several hypotheses (e.g. logic gates) all
consistent with sparse observations, using a prior to pick one.
**Problem:** Saw a systematic-looking confusion (always predicting XOR/XNOR over
AND/OR/NAND/NOR) and assumed a learned posterior or a hand-tuned correction would
recover those points. Building it would have been wasted effort.
**Fix:** Measure the conditional posterior first — P(true gate | the SET of gates
consistent on the chosen subset). On Switch-Lamp every ambiguous pair already
favored the prior's pick ({AND,XNOR}→XNOR 34:17, {XOR,NAND}→XOR 29:14, …), so the
existing tie-break was optimal and the "confusions" were just the irreducible
minority. Before correcting a systematic-looking error, compute the conditional
posterior; the residual may be the floor, not a bug.

### Website score << local mean → it's the worst-group terms; stratify to find them

**Context:** An Eris grader whose final score is a weighted blend of mean(row)
plus several `worst(group)` terms over HIDDEN grouping columns (e.g. Switch-Lamp:
`0.68*mean + 0.14*worst(split) + 0.10*worst(ood_axis) + 0.08*worst(render_style)`).
**Problem:** Local mean(row) looked great (0.842) but the website scored 0.7152.
The gap is NOT the mean — it's the `worst(group)` terms (32% weight here): one weak
subgroup, scored as the group minimum, drags the total. Optimizing the mean
further does almost nothing; "a solution cannot win on the easy circuits alone"
is literally encoded in the metric.
**Fix:** Don't add model complexity blindly — find the weak subgroup. The grouping
columns are hidden, so stratify your TRAIN per-row score by every DETECTABLE axis
(n inputs, n outputs, #interventions / data richness, detected render style,
target complexity) and look for the bucket that craters. On Switch-Lamp this
exposed intervention SPARSITY: nflips=4 scored 0.488 vs 0.94 for nflips=14 — that
sparse bucket is what `worst(ood_axis)` keys on. Then spend effort lifting the
worst bucket (even trading a little mean for a lot of worst-group is +EV, since
worst terms carry ~0.10-0.14 each). Build a proxy for the hidden axis from
detectable features and validate against it, not against the mean.

### Marginalize variable-size hypotheses with a per-circuit prior (divide by C(n,k))

**Context:** Picking among / averaging over hypotheses of DIFFERENT support sizes
that are all consistent with sparse data — e.g. a logic gate over a 1-, 2-, or
3-switch subset, or any "which feature subset" model-selection under a prior.
**Problem:** Weighting each consistent hypothesis by only its class prior
P(size)*P(type|size) double-counts the larger sizes: there are C(n,k) subsets of
size k, so a fan-in with more subsets accumulates more total marginal weight than
it should, biasing both the MAP pick and any marginalized prediction toward
high-fan-in. On Switch-Lamp this hurt exactly the sparse (most-ambiguous) scenes.
**Fix:** Weight each SPECIFIC hypothesis by `P(size)*P(type|size) / C(n,size)` —
the class prior spread uniformly over the subsets of that size. Use the same
per-circuit weight for the MAP selection AND for marginalized predictions (the
held-out query bit = per-circuit-weighted majority over consistent candidates).
Lifted Switch-Lamp's worst bucket (nflips=4) from row 0.488→0.532, query 0.716→
0.790, overall mean_row 0.842→0.848, with zero extra training. Verify expected-
score-optimal variants too, but here the binary all-or-nothing gate term meant
plain per-circuit MAP already captured the gain (expected-F1 added +0.0006).

### Know when you've hit the Bayes ceiling — quantify determinacy, then stop

**Context:** An exact-recovery challenge (CV + logic/SAT) where you're already
ranking 1st and the user asks to "push higher for a buffer." Tempting to keep
adding model complexity / ensembles / fitted calibrators.
**Problem:** Past a point the data simply does not determine the answer, and extra
machinery only adds overfitting risk that can REGRESS and lose the lead. You need
an objective stopping test, not vibes.
**Fix:** Prove you're at the information ceiling before touching anything:
(1) verify the reader is EXACT on the held-out split via self-consistency, not
just labels — e.g. raw reads vs log-derived state agree on 100% of test clips,
and every unit has ≥1 consistent hypothesis (0 contradictions);
(2) quantify DETERMINACY — count units with exactly one consistent hypothesis
(Switch-Lamp: 60% of test lamps uniquely determined → exact; 40% carry ≥2
consistent circuits → irreducibly ambiguous);
(3) confirm each estimator is already Bayes-optimal: priors match the empirical
generator distribution, the subset/structure prior is justified (ids salted →
uniform), selection = MAP under the correct posterior, predictions marginalize
that posterior, and no fitted confidence model beats the analytic proxy (CV'd).
When all three hold, the residual is the logical floor that EVERY competitor also
hits. CAVEAT (learned the hard way): "Bayes-optimal for RECOVERING the hidden
structure" is NOT identical to "optimal for the SCORE" — a partial-credit metric
leaves a theoretical tuning lever on the ambiguous tail, and a rival edged the
supposed ceiling by ~0.001. BUT on an OOD-hardened test that lever is mostly a
trap: tuning it against train CV regressed on the real test (see the
"tuned-to-train knobs" lesson below). So the practical conclusion stands — once
determinacy is maxed and every estimator is a principled closed-form, STOP; the
remaining gap is noise you can't safely chase, and fitted tweaks more often lose
the lead than keep it. (Switch-Lamp: attempt2 0.7307 = best; rival 0.7316; a tuned
attempt3 made it WORSE at 0.7303 and was reverted.)

### Tuned-to-train knobs regress on OOD-hardened test; ship only principled fixes

**Context:** Near-tie race on an exact-recovery challenge whose test split is
deliberately OOD-hardened (the brief says so). You're at the recovery ceiling and
tempted to tune the decision rule to the scoring metric — e.g. sharpen the gate
conditional `w = P(fanin)*P(gate|fanin)^T / C(ns,k)` with a temperature `T`, fit
against the local grader on the ambiguous (sparse-intervention) tail.
**Problem:** This is the right IDEA (the metric's partial credit + 45% query weight
means the score-optimal rule ≠ the generation-prior MAP) but the WRONG execution on
an OOD-hardened challenge. I did it carefully — single knob, 5-fold CV stable across
3 seeds (+0.003 held-out correctness), per-group check showing the worst bucket
lifted and only never-worst high-data buckets regressed, surgical (7/258 rows
changed). It still REGRESSED on the real test: `T`=1.3 scored 0.7303 vs the
untuned 0.7307. Train CV is in-distribution; the test ambiguous tail is shifted, so
a parameter fit to train's tail does not transfer — and the tail is exactly where
the tuning acts.
**Fix:** On an OOD-hardened split, ship only PRINCIPLED corrections (provably-correct
math that holds for any distribution), never parameters fit to train. The contrast
on this same challenge: the per-circuit ÷C(ns,k) marginalization (a correct Bayesian
normalization, [[eris]]) transferred and gained +0.0155 on test; the fitted `T`
knob, despite cleaner CV evidence, lost. Heuristic for "will it transfer?": if the
change is a closed-form correction you could justify without ever looking at train
labels, it transfers; if you picked its value BY looking at the train metric, assume
it won't under distribution shift. Keep the untuned principled version; don't trade
a real lead for an in-distribution CV mirage.

### Submission credits are scarce — probes usually confirm the ceiling, budget them

**Context:** Sitting at/near 1st on an Eris challenge, tempted to fish the
leaderboard with many variant submissions to claw back a ~0.001 gap, or to A/B a
hypothesis you can't validate locally (the hidden grouping/labels mean some things
are only measurable by submitting).
**Problem:** Eris challenges have a SMALL per-challenge submission budget, and they
LOCK without warning. Spending credits on variants that the principled analysis
already says are at the ceiling usually returns a negative or noise result — and
worse, if the platform ranks by LAST (not best) submission, a probe can knock you
below your own best with no credit left to restore it. Concretely on Switch-Lamp: a
*principled* confidence probe (conf**1.25, hypothesis "OOD test harder ⇒ my
train-calibrated confidence is too high") scored 0.7302 < the untuned 0.7307 —
confirming the confidence was already well-calibrated and burning a credit to learn
"no change". The earlier tuned attempt also regressed (0.7303). Both probes cost
credits to re-confirm the ceiling.
**Fix:** Treat submission credits like a tiny fixed budget. Submit a variant only
when (a) it's a principled closed-form change you couldn't validate locally AND (b)
it has asymmetric upside (plausibly +, bounded −). Order probes by expected value
and stop after the first that confirms the ceiling — the rest will too. NEVER spend
the last credit or two on a fish; keep one in reserve to re-assert your best if the
platform is last-submission-wins. When the principled analysis says "at ceiling,
gap is noise", believe it instead of buying the same answer with credits.

### Eris grades solution.py in isolation — make it self-contained (no local imports)

**Context:** Eris challenge. After you produce `working/submission.csv`, the
platform runs TWO separate gradings: (1) the uploaded CSV against the test key,
and (2) re-executing your `solution.py` — copied ALONE into an isolated dir
(`/root/setup/solution/solution.py`) — to verify reproducibility.
**Problem:** A `solution.py` that does `import pipe` (or any local helper module
you wrote) fails the SCRIPT grading: `ModuleNotFoundError: No module named
'pipe'` — even though the CSV upload scored fine. Local helper modules are not
copied alongside it. Splitting the solution across files breaks reproduction.
**Fix:** The canonical root `solution.py` MUST be self-contained — only stdlib +
installed packages (numpy/pandas/torch/scipy/sklearn/cv2), NO local imports;
inline whatever it needs. Standard solved-challenge layout (matches Switch-Lamp,
Inferring-Hidden-Populations): `src/` = dev/helper modules you iterate in
(pipe.py, builders, CNN trainers, validators); root `solution.py` = the
self-contained canonical the platform runs; `attemptN/` = per-iteration snapshots
(`solution.py` + `submission.csv` + `approach.txt`); `working/` = live
`submission.csv` + build artifacts. VERIFY self-containment by moving the helper
modules OUT of cwd (into `src/`) and running `python solution.py` — if it imports
a local module it will fail exactly like the platform.

### Stellar Transit: classification is the lever — river-plot CNN + smoothness feats + physics ensemble

**Context:** Eris "Stellar Transit / Syzygy" — a 1600-px brightness scan
(40×40) with regularly-spaced dips at known spacing P, drifted off the lattice
by a slow sinusoid. Predict `regime∈{none,weak,strong}` (the drift amplitude
bin, macro-F1) and `next_pos` (next dip past px 1599, `exp(-|Δ|/1.5)`); score =
`0.5·macroF1 + 0.5·localization`. A physics pipeline (dip-localize → robust
lattice+drift sinusoid fit → threshold amplitude) plateaus ~71 (macroF1 0.82);
spot-banding produces a spurious high-amplitude tail on `none`.
**Problem:** Easy to keep tuning the physics fit, but it's near its limit and the
none/weak boundary stays blurred.
**Fix:** Decompose the score FIRST — perfect classification → composite ceiling
~82.6, so CLASSIFICATION is the dominant lever, not localization. Test the noise
nature: per-dip residual std ≈1.55px and INDEPENDENT of dip depth ⇒ irreducible
PLACEMENT noise ⇒ localization is at the σ/√N ceiling (don't chase it; the failed
high-resid drift fits are unrecoverable — verified with find_peaks, 11/156).
Classification wins (0.82→0.857 macroF1, 71→74.25 composite): (1) a lattice-folded
**river-plot** CNN representation — matched-filter windows (±20px) sampled around
each `φ0+k·P`, stacked into a (K,M) image where the dip ridge snakes with the
drift; P-invariant and detection-soft, so it sidesteps the spot-banding amplitude
blow-up. Dilated convs ALONG the drift axis + test-time aug. (2) amplitude-
INDEPENDENT **smoothness features** of the lattice residuals (sign-change
fraction, lag-1/2 autocorrelation, low-freq ratio) — separate `none` (white
residuals) from `weak` (smooth drift) even where amplitude overlaps. (3) ENSEMBLE
the CNN with a HistGBT on physics+smoothness feats — they make orthogonal errors;
blend 0.6·CNN+0.4·GBT. For next_pos use a DECOUPLED confident binary drift gate
(P(drift)>0.8 & resid<3.5), not the 3-class regime (higher precision). Pitfall:
center-of-mass dip positions are WORSE than sub-pixel parabolic-peak for the 1.5px
tolerance (wide window trades precision for robustness).
