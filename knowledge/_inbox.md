# Inbox — uncurated capture lane

Append-only. New insights land here as dated one-liners during work, at **zero
session cost** (this file is NOT `@imported`). Promotion into a curated
`knowledge/` or `patterns/` file is **human-approved** via
`/review-knowledge-base`. Don't edit curated files unattended; don't delete
entries here except when promoting one.

Format: `- YYYY-MM-DD — <insight> (context / why it matters)`

<!-- entries below -->

- 2026-07-02 — Eris macro-F1-over-long-tail metrics: build the CV proxy as OOF pooled over the FULL train scored ONCE, not per-fold mean. A single fold's val contains few of the rare classes so its macro-F1 wildly over-estimates the leaderboard; scoring pooled OOF over all classes tracked the Syriac board (proxy 0.30 vs board 0.318) while single-fold showed a fantasy 0.39. (Syriac diacritics)
- 2026-07-02 — Ensembling SMOOTHS softmax and suppresses low-frequency classes under argmax, which HELPS micro-F1/exact-match but HURTS macro-F1 (rare classes stop firing). Decouple: ensemble for the common-class stability, then a modest decode-time probability boost (×3) on low-freq labels to recover the one or two learnable rare classes. The boost is principled (counteract empty-bias), keep it moderate not OOF-max on OOD-hardened splits. (Syriac diacritics: macro 0.150→0.193)
- 2026-07-02 — Fine-grained displacement/localization CNNs: downsampling destroys the fine axis. If y-bins are 2px but x-bins are 8px, use an ANISOTROPIC encoder (stride 1 on the fine axis, stride 2 on the coarse) — lifted the hard axis materially (y-band 0.58→0.65) where isotropic stride-2 or full-res dilated did not. Generic ImageNet-pretrained backbones can HURT on far-OOD imagery (particle blobs: 0.46 scratch → 0.34 pretrained). (Bedload particle motion)
- 2026-07-02 — When a target is marked by a fixed overlay (e.g. a red cross at the crop centre), the overlay OCCLUDES the object and is identical every image — inpaint it out (cv2, colour mask) before template/feature matching so you match the object not the marker; but note the true appearance under it is unrecoverable, which caps precision. (Bedload particle motion)
- 2026-07-02 — Semi-supervised self-training (pseudo-label a large unlabeled pool at high confidence, retrain) is worth testing on small-labeled NLP tasks but VALIDATE per-fold before shipping: on Biomedical-QA it helped 2/3 grouped folds and regressed the 3rd for a net +0.001 (noise) — inconsistent gains that average to ~0 are an overfit trap, ship the simpler cross-encoder. A biomedical BERT cross-encoder over (question,candidate) hit AUC-lift 0.727 grouped-CV where TF-IDF lexical similarity gave only 0.13. (Biomedical QA intrusion)

### [2026-07-08, Aviation Causal Finding / Eris] Hot board = provision cloud GPU at t=0 or skip
Context: FCFS slot race (eris.md lesson known and followed in spirit); board already
had 4 solvers above the AI baseline when we started. Local 4GB 3050 = ~20 min/fold ->
~2h per 5-fold transformer, ~4.5h to a competitive ensemble. Challenge locked while
the ensemble was mid-flight; attempt1 (OOF 0.4992 vs baseline 0.5042) submitted at
lockdown scored below baseline. Two candidate lessons: (1) the FCFS clock starts
before you open the challenge - count the solvers already above baseline; 4+ means
hours, not a day, so rent an A10G-class GPU immediately (fine-tune pace 5-6x local)
or consciously skip; (2) calibration - a 10-model fold-ensemble on test gave <+0.005
over OOF; don't submit hoping ensemble uplift closes a visible OOF-to-baseline gap.
Possible eris.md merge: extend the "Beat the baseline and SUBMIT first" lesson with
a "pace budget" clause.
CORRECTION (same day): attempt1 CSV actually scored 0.5082 (CLEARED baseline
0.5042); script-run rescored 0.5035. So (2) above is wrong: fold-ensemble uplift
was +0.009 (OOF 0.4992 -> CSV 0.5082). New calibration pair: (a) uplift is real,
~+0.01 for 10-model fold-ensembles; (b) the A10G script RERUN can land ~0.005
BELOW your uploaded CSV (nondeterminism) - keep a >=0.005 margin over any
threshold you must clear, or seed/determinize the solution script.

### Best-of-N private draws: quantified win (Eris Masked Structural, 2026-07-09)
Context: challenge closed; final = public 0.6324 (2nd) / private 0.6534 (1st, $250).
Problem: our private winner was attempt5 - our 4TH-best public score (0.6210); we'd
half-attributed its weak public showing to selection creep. Public leader (0.6404)
gained only +0.002 on private and fell to 3rd.
Fix/lesson: on split-scored platforms, ~0.01 public differences between DECORRELATED
attempts carry ~no private signal - submit every decorrelated attempt as a free
best-of-N draw; judge attempts by design robustness (EMA, multi-representation
ensembles, pre-declared blends), not by small public deltas. Also steal from rank2:
runtime-verified assumptions w/ fallbacks + label-identity consistency projection
(details in Eris exemplary-patterns.md).

### [2026-07-09, Masked Structural Regime / Eris] Label-derived constants must be derived in-code - win revoked
Context: private-1st ($250) solution REJECTED on human review; paid $18. The
regime head (20% of score) was a pasted rule `np.select([b<0.25, b<1.5, b<3.0],
[rg_c, rg_a, rg_d], rg_b)` mapping ANONYMIZED class codes to band intervals -
knowable only from train labels, yet nothing in the script derived it. Aggravator:
the comment claimed "thresholds learned from the training labels"; reviewers treat
asserted-but-absent derivations as offline hardcoding. Other solvers derived the
same rule from train in a few lines and passed.
Lesson: any constant obtainable only from the labels (class<->value maps,
thresholds, orderings) must be FIT inside solution.py (boundary scan / shallow
tree / groupby - trivial); physics/literature constants OK with source. Never
write a comment claiming work the code doesn't show. Mandatory pre-submit
hardcode scan added to the Eris project workflow.
CORRECTION to the 2026-07-09 "Best-of-N private draws" entry above: the $250
1st place it cites was later revoked on this review; the best-of-N lesson itself
still stands (a5 WAS the best private scorer), but the payout figure is now $18.
Possible eris.md merge: new lesson "Reviewers judge the code as submitted -
derive label-derived constants in-code".

### CORRECTION + rule (2026-07-09): Masked Structural 1st REVOKED - label-derived literals
The "best-of-N private win" below stands STATISTICALLY (scores were real) but the
$250 was revoked on human review -> $18. Cause: a pasted `np.select` regime rule whose
class<->interval assignment was learned from train labels offline; a comment claiming
it was "learned from the training labels" (with no in-code derivation) aggravated it.
Platform-wide lesson: EDA discoveries are not knowledge you own - the submitted script
must RE-LEARN them from train at runtime (boundary scan / shallow tree / groupby = ~5
lines). Comments must never claim work the code doesn't contain. Rank2's runtime
derivation + train-consistency gate (already banked as a "steal this" pattern) was the
compliant version of the exact same rule; he kept his payout. Mandatory pre-submit
hardcode grep now in Eris solving-workflow.md.

### Rerun-graded competitions: the script's training budget IS the model (Eris Crowd Plurality, 2026-07-10)
Context: LB scores a fresh 90-min rerun of solution.py, not the uploaded predictions.
Problem: identical models/blend scored 0.4122 -> 0.4245 -> 0.4449 purely by how many
ensemble members finished training inside the rerun budget (2 -> ~4 -> all 8); the
uploaded-CSV score sat at ~0.45 the whole time, masking the leak.
Fix/lesson: on any rerun-graded platform, engineer the script's throughput before
tuning the model: (1) fallback submission written first + re-bank output after every
member; (2) per-member try/except (an OOM member must not kill the run); (3) adaptive
member gate - measure each member's wall time, start the next only if elapsed +
1.1*slowest < deadline minus margin (dominates fixed cutoffs, robust to unknown host
speed); (4) cheapen members losslessly first (bigger batch at same effective batch,
length-bucketed batching). Also: cross-family LLM ensemble diversity (answer agreement
~0.5) >> seed reseeds, which saturate after ~2 seeds/family (+0.0017 for 4x); test a
new family against a PRE-DECLARED solo+blend gate to resist fold-noise seduction.
