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

### Treat exactly-one-fake as top-instance multiple-instance learning
Context: Find-the-fake / anomaly-in-a-set when each bag contains exactly one, or a known small number of, corrupted members.
Technique: Fit one shared member scorer with a bag-level hardest-negative ranking objective, then decode by within-bag softmax/argmax so outputs obey the cardinality. If only bag labels exist, alternate top-instance selection and scorer refits; use the top-two margin as uncertainty.
Why/when it wins vs fails: Hard negatives share the bag's nuisance/source conditions, so ranking isolates within-set differences and prevents independent sigmoids from predicting zero or several fakes. It fails when the count constraint is wrong or anomalies are collective combinations; use top-k/cardinality DP or set-distribution features then.
CPU cost: One score per row plus `O(m log m)` sorting per bag. Linear/shallow LightGBM scoring for <=1M members is minutes; no `O(m^2)` pair expansion.
Source: https://openaccess.thecvf.com/content_cvpr_2015/html/Li_Multiple_Instance_Learning_2015_CVPR_paper.html ; https://arxiv.org/abs/2311.14773

### Replace a CRF with legality-constrained Viterbi when BIO structure is the dependency
Context: Flat sequence labeling / span extraction with BIO/BILOU labels and CPU-bound training.
Technique: Train independent token cross-entropy emissions, then Viterbi-decode with a fixed transition mask assigning negative infinity to illegal transitions. Escalate to a filtered semi-Markov decoder only when duration or whole-span features add signal.
Why/when it wins vs fails: The cited constrained decoder trained about twice as fast as a CRF with statistically insignificant F1 differences because much CRF benefit came from blocking known-illegal transitions. It fails for nested/overlapping spans, strong duration effects, or long-range segment features.
CPU cost: `O(n|Y|^2)` with a tiny transition table; emissions dominate. Filtered semi-Markov is `O(nL|Y|^2)` after pruning, with `L` capped from train span lengths.
Source: https://arxiv.org/abs/2010.04362 ; https://arxiv.org/abs/2311.18028

### Break graph bridges before transitive closure in entity matching
Context: Matching / re-ID / clustering under shift where one false-positive edge can merge two large identities.
Technique: Generate `O(nk)` candidates from several cheap independent blocks, classify pairs, threshold into components, then remove high-betweenness bridge edges and require graph distance <=2 or a second independent path before emitting inferred matches.
Why/when it wins vs fails: Foursquare competition graph postprocessing raised retrieval max-IoU from 0.9778 to 0.9935 by pruning betweenness bridges and limiting closure to two hops. It attacks catastrophic transitive false positives but can break true chain-shaped identities; validate component-size and bridge rules on source-held-out clusters.
CPU cost: Candidate generation `O(n log n + nk)`, inference `O(nk)`, union-find near-linear. Run exact betweenness only on small ambiguous components; use articulation/bridge tests or sampling above ~100 nodes.
Source: https://future-architect.github.io/articles/20220720a/ ; https://foursquare.com/resources/blog/developer/finding-the-right-poi-match/

### Spend the small-object detector budget on adaptive overlapping slices
Context: High-resolution small-object detection where global resizing collapses targets to a few pixels.
Technique: Run a tiny detector on 6 or 12 resolution-adaptive overlapping tiles, map boxes back, and merge with center-distance/IoMin-aware NMS. Add one full-frame pass only if large objects matter; choose tile count from object-size statistics and a measured runtime budget.
Why/when it wins vs fails: SAHI improved AP 5.1-6.8 without retraining and 12.7-14.5 with sliced training; adaptive slicing reported 20-25% lower inference time than fixed slicing. It fails when class identity needs outside-tile context, overlap is inadequate, or repeated textures multiply false positives.
CPU cost: Approximately tile-count times one small-model pass. Benchmark 100 images, then choose 6 vs 12 tiles so optimized/int8 inference plus NMS stays below 5,400 seconds; avoid multiscale TTA.
Source: https://arxiv.org/abs/2202.06934 ; https://www.mdpi.com/2072-4292/15/5/1249

### Compile OCR confusions into a weighted finite-state lattice before neural reranking
Context: OCR correction, diacritization, and monotonic restoration with mostly local insert/delete/substitute errors.
Technique: Estimate asymmetric character-confusion weights from train alignments, compile a weighted edit transducer, intersect it with a compact candidate model, and Viterbi-decode. Rescore only lattice N-best paths with a small word-character recurrent model when context is needed.
Why/when it wins vs fails: WFST-PostOCR won the ICDAR 2017 error-detection task because the channel model sharply constrains search. It wins for monotonic low-edit channels and scarce data; it fails on sentence reordering, semantic GEC, unseen corruption mechanisms, or lexicons that prune valid inflections.
CPU cost: Alignment is linear-ish in corpus characters; pruned Viterbi is proportional to active arcs. Beam 8-32 plus a 1-10M parameter int8 BiGRU is normally safe; cap candidates and retain an identity fallback.
Source: https://l3i.univ-larochelle.fr/app/uploads/sites/12/2024/05/icdar2017-competition-post28329.pdf ; https://arxiv.org/abs/2011.00538

### Use metric-matched stochastic GBDT ranking, not pointwise relevance regression
Context: Query-grouped ranking with NDCG/MAP/MRR metrics and mixed engineered features.
Technique: Use CatBoost YetiRank for NDCG or YetiLoss configured to MAP/MRR; for LightGBM use `lambdarank` with the exact `eval_at`. Preserve query boundaries and let the ranker blend heuristic scores as features.
Why/when it wins vs fails: A Yandex Kaggle solution jumped near the top with LambdaMART stacking, while a controlled study found YetiRank strongest for NDCG@10 and YetiLoss materially better for MAP/MRR. It fails with size-one groups, sparse/noisy within-query labels, or metrics requiring calibrated probabilities.
CPU cost: Depth 6-8, hundreds to ~1,500 trees, 10 threads; stochastic neighboring-pair sampling avoids quadratic pairs and fits medium Eris tables inside 90 minutes.
Source: https://arxiv.org/abs/2204.01500 ; https://yanirseroussi.com/2015/02/11/learning-to-rank-for-personalised-search-yandex-search-personalisation-kaggle-competition-summary-part-2/

### Canonical neighborhood refinement before feature hashing
Context: Decoded records are sets, graphs, relational claims, molecules, event neighborhoods, or matching candidates where marginals lose connectivity.
Technique: Run 2-4 Weisfeiler-Lehman rounds, replacing each node label with a deterministic hash of its current label and sorted multiset of neighbor labels. Count refined labels, then signed-hash them into `2^16`, `2^18`, or `2^20` sparse buckets; accept the smallest width whose grouped score plateaus.
Why/when it wins vs fails: WL preserves permutation invariance while encoding larger local neighborhoods; fixed-width hashing handles unseen structural tokens. It fails on regular/symmetric graphs indistinguishable by 1-WL, truly global dependencies, or excessive collisions. Audit structural collisions before feature hashing.
CPU cost: `O(hE)` extraction plus streaming/stateless hashing. Two-four rounds and a float32 CSR matrix are usually seconds to minutes for millions of edges. Structural token hashing is not text TF-IDF/BoW.
Source: https://jmlr.csail.mit.edu/papers/v12/shervashidze11a.html ; https://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.FeatureHasher.html

### Group-excluded target statistics, not merely row-excluded target encoding
Context: High-cardinality categoricals repeat within source families while private groups are source-disjoint.
Technique: For row group `g` and category `c`, compute `(sum_y[c]-sum_y[g,c]+alpha*prior)/(n[c]-n[g,c]+alpha)`, plus excluded log-count and unknown flags. Tune smoothing only in outer GroupKFold; restrict interaction CTRs to predeclared pairs/triples.
Why/when it wins vs fails: Ordered row statistics stop self-label leakage, but another row from the same family can still leak the family target. Group subtraction closes that stronger channel. It fails under concept drift, nearly unique combinations, pure-class groups, or broad interaction search; then encodings collapse to the prior or selection noise.
CPU cost: Two groupby tables per feature followed by vectorized subtraction; tens of features over a few million rows are typically under 10 minutes. Keep CatBoost `max_ctr_complexity` near 1-2.
Source: https://papers.nips.cc/paper_files/paper/2018/hash/14491b756b3a51daac41c24863285549-Abstract.html ; https://catboost.ai/docs/en/concepts/algorithm-main-stages_cat-to-numberic

### Treat frequency encoding as two-domain evidence, not category semantics
Context: Train and grader expose unlabeled category frequencies, but source composition changes and rare/unseen levels are common.
Technique: Keep separate smoothed `log1p(count_train)`, `log1p(count_target)`, target/train log-ratio, domain-only flags, and within-parent conditional frequency. Simulate the production visibility contract in every fold; compare CatBoost `SkipTest` with transductive `Full` rather than silently pooling counts.
Why/when it wins vs fails: Separate counts distinguish global rarity, a new target mode, and stable recurrence; pooled counts erase this. It fails when target batches are tiny/resampled, batch sizes differ, or frequency only identifies source. Counts must be rebuilt inside each simulated split.
CPU cost: One domain-aware groupby per key; seconds to low minutes. Use int32 counts and keep only interactions with stable paired grouped-fold gains.
Source: https://catboost.ai/docs/en/concepts/algorithm-main-stages_cat-to-numberic ; https://catboost.ai/docs/en/references/training-parameters/ctr ; https://developer.nvidia.com/blog/leveraging-machine-learning-to-detect-fraud-tips-to-developing-a-winning-kaggle-solution/

### Convert adversarial validation scores into clipped target-risk estimates
Context: Grouped CV respects independence but does not match the unlabeled target covariate distribution.
Technique: Cross-fit a domain classifier for target vs train. Weight source row `x` by `s(x)/(1-s(x))`, multiplied by `n_train/n_target` for unequal sampling. Clip weights, report effective sample size `(sum w)^2/sum(w^2)`, and compare ordinary LOGO, weighted LOGO, and worst-group loss.
Why/when it wins vs fails: Importance-weighted CV estimates target risk under covariate shift when `P(y|x)` is invariant and train covers target support. It fails under label/concept shift or near-separation: odds explode and effective sample size collapses. Shifted features can still be target-predictive, so do not automatically drop them.
CPU cost: One shallow cross-fitted LightGBM/logistic domain model plus reusable weighted metrics, usually 1-5 minutes. Abort weighting when effective sample size is unusable.
Source: https://www.jmlr.org/papers/v8/sugiyama07a.html ; https://arxiv.org/abs/2006.04662

### Admit learned embeddings only through a paired group-transfer tournament
Context: Small shifted data with high-cardinality categories where hand interactions/aggregates are already strong.
Technique: On identical outer groups, record add-one-family and leave-one-family-out deltas, worst-group delta, and domain-classifier AUC. Train one shallow embedding model only after this screen; accept frozen embeddings only if they improve most held-out groups and worst-group loss. Map unseen levels to one unknown embedding and report their test fraction.
Why/when it wins vs fails: Entity embeddings won Rossmann when recurring levels had stable shared geometry, but broad tabular benchmarks find trees stronger near 10k samples. Embeddings fail when categories are source IDs, private levels are unseen, or observations per level are tiny; paired fold deltas expose one-group luck.
CPU cost: The hand-feature tournament is minutes with ridge/small GBDT. One 1-2 layer embedding MLP on <=100k rows should take roughly 5-20 CPU minutes per outer run; cap at one architecture.
Source: https://arxiv.org/abs/1604.06737 ; https://arxiv.org/abs/2207.08815

### Force LightGBM's histogram orientation for deterministic, memory-bounded CPU fits
Context: Large dense/sparse feature matrices requiring deterministic reruns on 10 cores.
Technique: Use `device_type="cpu"`, `num_threads=10`, `deterministic=true`, and explicitly choose `force_row_wise=true` for many rows/modest bins/<=16 threads or `force_col_wise=true` for very wide/high-bin matrices. Bound `histogram_pool_size`; early-stop and retain `best_iteration`.
Why/when it wins vs fails: LightGBM otherwise benchmarks both paths at startup. Row-wise suits 10 cores but doubles Dataset memory; col-wise saves memory. Explicit orientation is required with deterministic mode. Too small a histogram cache causes recomputation; row-wise can OOM before fitting wide data.
CPU cost: Start with a 4-8GB histogram cache and measure full-fold RSS/time, reserving memory for raw data, binned Dataset, fold copies, and predictions.
Source: https://lightgbm.readthedocs.io/en/latest/Parameters.html

### QuantileDMatrix is XGBoost's CPU memory switch, not external-memory training
Context: XGBoost matrices where normal `DMatrix` construction materially raises peak RSS or startup time.
Technique: Use `tree_method="hist"`, `device="cpu"`, `nthread=10`, `max_bin=256` with `QuantileDMatrix`; build validation/test matrices with training as `ref=` and identical `max_bin`. Bound depth 6-8 or use `lossguide` with `max_leaves`, subsampling, and early stopping.
Why/when it wins vs fails: Direct quantization reduces memory/loading overhead for hist training. More bins recover split fidelity but cost storage/compute. `ExtMemQuantileDMatrix` is last resort: disk/cache traffic can lose the deadline when 62GB RAM is sufficient.
CPU cost: Require a timed full-fold extrapolation under ~60 minutes, leaving ~30 minutes for features and inference. Profile external-memory end-to-end before accepting it.
Source: https://xgboost.readthedocs.io/en/stable/python/python_api.html#xgboost.QuantileDMatrix ; https://xgboost.readthedocs.io/en/stable/parameter.html ; https://xgboost.readthedocs.io/en/stable/python/examples/external_memory.html

### CatBoost's RAM limit does not protect total-process RSS
Context: Mixed numeric/high-cardinality forensics where ordered CTRs help but category combinations can explode.
Technique: Start CPU CatBoost with `thread_count=10`, depth 6-8, `border_count=254`, `max_ctr_complexity=1`, `used_ram_limit="32gb"`, and early stopping. Increase CTR complexity only after grouped-CV evidence; monitor full-fold peak RSS.
Why/when it wins vs fails: Ordered CTRs prevent naive target leakage, but `used_ram_limit` only guides CTR memory and does not cover pools, quantized features, model state, or validation copies. Deep symmetric trees and combination CTRs grow fast and overfit rare source-specific conjunctions.
CPU cost: Fail early if one full fold projects beyond 45-50 minutes or RSS exceeds ~45GB; the rerun still needs feature and prediction headroom.
Source: https://catboost.ai/docs/en/references/training-parameters/performance ; https://catboost.ai/docs/en/concepts/parameter-tuning ; https://catboost.ai/docs/en/references/training-parameters/ctr

### Optimize a transformer graph before dynamic INT8 quantization
Context: DistilBERT/ChemBERTa-scale forward passes useful enough to justify CPU inference.
Technique: Export ONNX, run ONNX Runtime's transformer optimizer with correct model type/heads/hidden size, verify logits, then dynamically quantize. Use symbolic shape inference; if dynamic axes block fusions, export fixed sequence-length buckets. Start with CPU S8S8/QDQ; try U8U8 only when S8S8 loses accuracy.
Why/when it wins vs fails: Optimization first enables transformer-specific fusions such as QAttention; dynamic INT8 pre-quantizes weights and computes activation ranges at runtime. It fails with unmatched graph patterns, unsupported fallback ops, wasteful padding, or quantization perturbing close probabilities; recheck log loss/calibration.
CPU cost: Benchmark exact optimized INT8 throughput and require total batches plus tokenization below ~45-60 minutes. Do not extrapolate vendor latency to unknown grader CPUs.
Source: https://onnxruntime.ai/docs/performance/transformers-optimization.html ; https://onnxruntime.ai/docs/performance/model-optimizations/quantization.html ; https://huggingface.co/blog/intel

### Spend ten CPU cores once: outer parallelism or native parallelism
Context: CV, ensembles, BLAS, GBDTs, Polars, and ONNX Runtime coexist in one script.
Technique: Use one process x 10 native threads for a single learner/session, or two processes x five threads for independent models. Set `OMP_NUM_THREADS`, `MKL_NUM_THREADS`, and `OPENBLAS_NUM_THREADS` before imports. For mostly sequential ONNX graphs start `ORT_SEQUENTIAL`, 10 intra-op threads, full graph optimization. Do not multiprocessing-wrap already parallel Polars; if needed use `spawn`, not `fork`.
Why/when it wins vs fails: Outer `n_jobs=10` around a ten-thread learner creates ~100 runnable threads, causing scheduling/cache contention. Joblib mitigation is incomplete, Polars already parallelizes, and fork after multithreading can inherit locked mutexes.
CPU cost: Benchmark `1x10`, `2x5`, and only for tiny jobs `5x2`; keep the fastest configuration whose peak RSS includes simultaneous fold copies.
Source: https://scikit-learn.org/stable/computing/parallelism.html ; https://onnxruntime.ai/docs/performance/tune-performance/threading.html ; https://docs.pola.rs/user-guide/misc/multiprocessing/

### Stream the feature graph, not Python loops or intermediate DataFrames
Context: Large group aggregations, joins, and sequence-flattening features that threaten the pre-model budget.
Technique: Express `pl.scan_* -> select/filter -> group_by/agg/join`, then `collect(engine="streaming")`; inspect the physical plan because unsupported operations can fall back to in-memory. For spill-heavy SQL, use DuckDB with 8 threads, a 32-37GB memory limit, disabled insertion-order preservation, and narrowed dtypes. Convert only the final matrix to contiguous NumPy float32.
Why/when it wins vs fails: Lazy pushdown/join optimization and batching avoid repeated materialization. It fails when a global operation breaks streaming or a late conversion duplicates the full table. DuckDB's limit is not a hard RSS ceiling; some operators bypass its buffer manager.
CPU cost: Scan each source once. A 32-37GB DuckDB limit leaves ~25-30GB for Python/model arrays; lower threads when concurrent operators inflate RSS.
Source: https://docs.pola.rs/user-guide/concepts/streaming/ ; https://docs.pola.rs/user-guide/lazy/optimizations/ ; https://duckdb.org/docs/current/guides/performance/oom

### Cross-fit the calibrator on the same group boundary as the model
Context: Log-loss-heavy classification where source families repeat and calibration data are scarce.
Technique: Generate OOF scores with the production GroupKFold, fit the calibrator only on predictions from models that never saw those groups, and preserve the grouping when selecting calibration complexity. Prefer sigmoid/Platt at small `n`; try isotonic only with roughly >1,000 representative calibration cases and stable per-group gains.
Why/when it wins vs fails: Fitting calibration on in-sample scores biases probabilities toward 0/1. Isotonic corrects arbitrary monotone distortion but overfits small data and creates ties; sigmoid preserves ranking but cannot fix asymmetric/non-sigmoidal distortions. A source-mismatched calibrator can worsen private NLL even when in-domain reliability improves.
CPU cost: Negligible after OOF prediction generation. One global sigmoid is two parameters; isotonic is `O(n log n)`. The expensive part is the already-required grouped OOF models.
Source: https://scikit-learn.org/stable/modules/calibration.html

### Use regularized Dirichlet calibration for multiclass confusion, not one-vs-rest isotonic
Context: Multiclass log loss where classes have systematic probability coupling or prior bias after ensembling.
Technique: Clip probabilities, take log probabilities, fit a ridge-regularized multiclass linear layer, then softmax. Compare diagonal/vector scaling before a full matrix; select regularization on group-held-out OOF predictions.
Why/when it wins vs fails: Dirichlet calibration is natively multiclass and can correct class-to-class confusions that scalar temperature cannot; it improved log loss and Brier across varied models. Full matrix scaling has about `K^2` parameters and fails on small calibration sets or shifted class relationships, so diagonal shrinkage is the safe first escalation.
CPU cost: Tiny convex optimization over `K` or `K^2` parameters; seconds for ordinary class counts and negligible inference.
Source: https://dirichletcal.github.io/ ; https://arxiv.org/abs/1910.12656

### Gate label-shift correction by calibration and confusion-matrix conditioning
Context: Test class prevalence changes while `P(x|y)` plausibly remains stable and target covariates are unlabeled.
Technique: From group-OOF predictions, estimate the source confusion matrix and calibrated posteriors. Run BBSE or maximum-likelihood label-shift estimation on target predictions, then multiply class odds by estimated target/source priors and renormalize. Gate deployment on a non-tiny smallest singular value and stable bootstrap prior estimates.
Why/when it wins vs fails: MLLS uses soft information more efficiently than hard confusion matching, but consistency requires calibrated predictions and identifiable class-conditional prediction distributions. Ill-conditioned confusions amplify noise. Both methods fail under concept/covariate shift because prior correction then changes the wrong quantity.
CPU cost: `O(NK)` probability aggregation plus optimization over `K` priors; seconds. Bootstrap the target predictions cheaply to expose unstable corrections.
Source: https://arxiv.org/abs/2003.07554 ; https://arxiv.org/abs/1802.03916

### Optimize worst-component loss with regularized GroupDRO when the metric has gates
Context: Composite metrics where payout collapses on the weakest source/class/component rather than the average loss.
Technique: Define stable groups matching score components, maintain exponentiated weights on their current losses, and train the base model against the weighted loss. Couple this with stronger L2/early stopping; compare to ERM on both mean log loss and worst component. Do not create groups from test/public-LB feedback.
Why/when it wins vs fails: GroupDRO focuses updates on the currently worst group and produced 10-40 point worst-group gains in cited NLP/image tasks only when paired with stronger regularization. Naive GroupDRO fails when overparameterized models fit every training group, groups are tiny/noisy, or score components are not aligned with stable train groups.
CPU cost: One loss vector and group-weight update per batch/tree iteration; negligible overhead for small nets and implementable as per-row weights for GBDT rounds. It fits 90 minutes if the base learner does.
Source: https://arxiv.org/abs/1911.08731 ; https://proceedings.mlr.press/v235/yu24a.html

### Fit a convex OOF probability blend directly to the composite scoring rule
Context: Several decorrelated models predict probabilities and the metric is a weighted composite with a log-loss-heavy term.
Technique: Freeze a small predeclared model library, concatenate group-OOF predictions, and optimize nonnegative weights summing to one against the exact local composite (or its smooth bounded surrogate). Add ridge-to-equal-weights or a minimum weight floor; evaluate the entire weight-fitting procedure in an outer grouped loop.
Why/when it wins vs fails: Super Learner uses V-fold risk to select a convex combination and asymptotically tracks the best library combination for the chosen loss. Direct metric fitting captures probability scale and component tradeoffs that rank averaging misses. It fails when dozens of models/blend knobs are searched on one OOF vector; selection noise then overfits the blend, especially with discontinuous gates.
CPU cost: Predictions dominate. Weight fitting over 3-10 models is seconds with projected gradient/SLSQP; outer evaluation reuses stored OOF matrices and adds no model inference.
Source: https://www.researchgate.net/publication/5933560_Super_Learner ; https://pmc.ncbi.nlm.nih.gov/articles/PMC4000126/

### WhatsApp Cloud API: paid sends silently dropped until WABA billing configured (error 131042)
- Date: 2026-07-17 · Project: Pickled-Squad
- Symptom: template (authentication/OTP) messages return `"message_status":"accepted"` + wamid, but never deliver. Free service messages (24h-session replies) deliver fine → looks like dev-mode or template issue; it isn't.
- Root cause: WABA had no billing country/currency/payment method. Paid template categories fail ASYNC with error 131042 ("Business eligibility payment issue") — visible ONLY in the `statuses` webhook callback, never in the send response.
- Debug key: webhook handlers usually process `value.messages` and ignore `value.statuses`. Log `statuses[]` where `status=="failed"` — the `errors[].code` + `error_data.details` (incl. a fix URL) name the exact cause. Codes: 131042 billing, 131030 dev-mode recipient not allowed, 131026 undeliverable, 132015 template paused.
- Fix: Business Manager → Billing hub → WhatsApp account → set country/currency + payment method (portfolio-admin only).

### Label-TRANSFORMING augmentation: a bijection on the latent is NOT a bijection on the thresholded label
Context: Eris Traffic Sign Pair (2026-07-20). Label = threshold of a = dx/(dx+dy) at 0.11
(ALIGNED if a<=0.11). Transposing the image swaps dx/dy, so a -> 1-a - a clean bijection on the
LATENT scalar. I wrote the aug as "flip the ALIGNED/OFFSET label" and it was wrong.
Problem: the label is a THRESHOLD of the latent, and the transform is not symmetric about the cut.
ALIGNED (a<=0.11) -> a'>=0.89, which is reliably OFFSET (valid supervision). But OFFSET (a>0.11)
-> a'<0.89, which is ALIGNED only when a>=0.89 - so flipping OFFSET->ALIGNED mislabels ~88% of
those samples. Empirically the aug scored WORSE than no aug (fold deltas +0.027/-0.062).
Fix: for a label-transforming aug, push the observed label INTERVAL through the transform and keep
the new label only if the image of that interval lies entirely inside one output class; otherwise
MASK the loss for those rows. Here: transpose supervises ALIGNED->OFFSET and masks OFFSET rows.
(The coupling label was genuinely invariant - transpose is an isometry so the distance ratio r is
unchanged. Same aug, one head valid and one head not.)
General trigger: whenever an aug "flips"/permutes a label derived by thresholding a continuous
quantity, verify on the INTERVAL, not the point. Applies to any ordinal/bucketed target.

### Acer Nitro RGB keyboard dead: a modprobe `options` line can silently override DMI quirk detection
*Captured 2026-07-31. Hardware: Acer Nitro AN515-58 (Jimny_ADH), CachyOS, linuwu-sense 1.0.0 DKMS.*

**Context:** Four-zone RGB keyboard backlight had been dead for weeks. `linuwu_sense`
loaded fine, `/sys/devices/platform/acer-wmi/nitro_sense/` existed with fan/battery
controls, but `four_zoned_kb/` was absent and `/sys/class/leds/` had no `kbd_backlight`.
Symptom was misattributed to CachyOS's Clang/LTO-built kernel and nearly triggered a
distro migration.

**Problem:** `/etc/modprobe.d/linuwu-sense.conf` contained `options linuwu_sense nitro_v4=1`
(copied from a DAMX guide for the **AN515-43** — a different model). In `find_quirks()`:

```c
if (predator_v4)      quirks = &quirk_acer_predator_v4;
else if (nitro_v4)    quirks = &quirk_acer_nitro_v4;   // { .nitro_v4 = 1 } only
else if (!force_series) dmi_check_system(acer_quirks); // never reached
```

The module param **short-circuits DMI detection entirely**. The generic
`quirk_acer_nitro_v4` lacks `.four_zone_kb`, so `sysfs_create_group(...,
&four_zoned_kb_attr_group)` never runs. The correct DMI-matched
`quirk_acer_nitro_an515_58 = { .nitro_v4 = 1, .four_zone_kb = 1 }` was being bypassed —
the param was redundant *and* destructive.

**Fix:** rename the conf away (`.conf` → `.conf.disabled`; modprobe.d only reads `*.conf`),
reload the module. DMI matches, `four_zoned_kb/{four_zone_mode,per_zone_mode}` appears.

**Generalizable lessons:**
1. A driver `options` line that duplicates what DMI already detects is a red flag — many
   drivers treat an explicit param as "skip autodetection", losing model-specific quirks.
2. Read the quirk table + the selection function in the DKMS source at
   `/usr/src/<mod>-<ver>/` before blaming the kernel build. Faster and more certain than
   web search.
3. Competing out-of-tree drivers for one device (here `facer` vs `linuwu_sense`, both
   binding `acer-wmi`) fail *silently*: facer's `gaming_kbbl_cdev_init` died with `-EEXIST`
   on a duplicate `/class/acer-gkbbl`, leaving stale `/dev/acer-gkbbl-*` nodes. Writes to
   them succeeded and did nothing. Always check `journalctl -k | grep <module>` when a
   userspace tool exits 0 but hardware doesn't respond.
4. Hand-built `.ko` outside DKMS (facer had a `dkms.conf` but was never registered) breaks
   on every kernel update — a recurring "this distro is broken" feeling with a config cause.

---

### macOS Nerd Fonts: `Mono`/`Propo` are FAMILIES, not styles (Linux→Mac migration)

**Context:** Migrating a Linux terminal config (Ghostty + powerlevel10k) to macOS.
Icons rendered as tofu boxes despite the font being installed.

**Problem A — config carried over from Linux:**
```
font-family = "CaskaydiaCove Nerd Font"
font-style  = Mono          # works on fontconfig, NO-OP on macOS
```
macOS CoreText registers three *separate families*:
`CaskaydiaCove Nerd Font`, `... Nerd Font Mono`, `... Nerd Font Propo`.
A `Mono` **style** never matches, so it silently falls back to a non-Nerd font —
no error, no warning, `ghostty +validate-config` stays clean.

**Fix:** name the family directly: `font-family = "CaskaydiaCove Nerd Font Mono"`.
Verify registration with:
`system_profiler SPFontsDataType | grep -i "family: .*<name>" | sort -u`

**Problem B — installing the font ≠ the terminal using it.**
Each terminal has its own font setting. Terminal.app's active profile
(`defaults read com.apple.Terminal "Default Window Settings"`) was on
`SFMonoTerminal-Regular`. Install via `brew install --cask font-caskaydia-cove-nerd-font`
changes nothing there.

**Diagnostic that pinpoints it fast:** in a broken p10k prompt, box-drawing (`─╮`) and
dot fill (`···`) render fine while only the icons break → the font lacks the Nerd Font
**PUA range** (U+E000–F8FF), it is not a general encoding/locale problem.

**Don't script Terminal.app's font:** it lives as an `NSKeyedArchiver` blob under
`Window Settings → <profile> → Font`, and Terminal rewrites its entire plist on quit —
a live `defaults write` gets clobbered. Use the GUI, or edit only while Terminal is quit.
Decode to inspect: `plistlib.loads(prof['Font'])['$objects']`.

---

### VLC skins are not supported on macOS at all (Linux→Mac migration)

**Context:** Dropped a `.vlt` skin into `~/.local/share/vlc/skins2/` per a skins site's
instructions; nothing changed, and there was no Tools or settings menu to select a skin.

**Problem:** The **skins2 interface module is never built for macOS.** Verified on VLC
3.0.23 — 340 plugins ship, and the only interface modules are `libmacosx_plugin.dylib`
(native Cocoa) and `libncurses_plugin.dylib`. No `libskins2_plugin.dylib` exists:
```sh
find /Applications/VLC.app/Contents -iname "*skins*"   # returns nothing
```
Two compounding traps: (1) `~/.local/share/vlc/` is the *Linux* config path — macOS VLC
uses `~/Library/Application Support/org.videolan.vlc/`; (2) the missing "Tools" menu is
not a bug — that's the **Qt** interface's menu layout. macOS uses a native Cocoa menu bar
where preferences live under `VLC → Settings` (`⌘,`). Skin sites rarely state the platform
limitation.

**Fix:** Use VLC's own dark interface style instead — a real, separate option:
```
--macosx-interfacestyle    "Run VLC with dark interface style"  (default: disabled)
```
GUI: `⌘,` → Interface → Appearance. Restart VLC to apply.

**Gotcha:** it does **not** follow the system appearance on 3.0.x — the system can be in
Dark mode while VLC stays light, which is exactly what makes it look broken. Also don't
`defaults write org.videolan.vlc` while VLC is running; like Terminal.app it rewrites its
plist on quit and clobbers the change.

**Generalisation (2 for 2 this migration):** a Linux-era config path or option carried to
macOS tends to **silently no-op** rather than error. Before debugging *why* a setting had
no effect, first verify the mechanism exists on macOS at all.

---

### Homebrew cask adoption: batch is all-or-nothing, MAS apps are off-limits, App Management blocks chmod

**Context:** Adopting 8 already-installed macOS apps into Homebrew with
`brew install --cask --adopt <a> <b> …` so they'd be Brewfile-tracked and `--zap`-removable.

**Problem 1 — a batch cask install is all-or-nothing.** Brew fetches *every* cask before
installing *any*. Six of eight downloads failed on a flaky connection, so the two that
downloaded fine were never installed either; `brew list --cask` was unchanged. Exit 1, zero
progress.
**Fix:** loop one cask at a time so each success commits independently:
```sh
for c in ghostty vlc obsidian; do brew install --cask --adopt "$c" || echo "FAILED: $c"; done
```
Partial downloads persist in `~/Library/Caches/Homebrew/downloads` as `*.incomplete` and
**resume** on retry — a failed run isn't wasted bandwidth.

**Problem 2 — `--adopt` still downloads the full artifact.** Even though all 8 apps were
already in `/Applications`, brew fetched every DMG to verify the installed bundle matches the
cask before claiming it. Adopting costs the same bandwidth as installing fresh.

**Problem 3 — Mac App Store apps cannot be adopted.** Symptom is a sudo prompt:
```
Failure while executing; `/usr/bin/sudo -E -- chmod -R a+rX /Applications/WhatsApp.app` exited with 1
```
Detect before trying: `[ -e "/Applications/<App>.app/Contents/_MASReceipt" ]`, or
`/bin/ls -ld` showing `root wheel`. MAS bundles are root-owned and sealed; supplying the
password doesn't help. The App Store is already their update/uninstall channel — leave them
unmanaged. This is a legitimate permanent exception to "install everything via brew".

**Problem 4 — `chmod: Operation not permitted` on a bundle you own.**
```
drwxr-xr-x yash admin  /Applications/Obsidian.app        # owned by the user
-rwx------ yash admin  …/app.asar.unpacked/…/index.js    # mode 0700, needs a+rX
```
Not a POSIX problem — **macOS App Management (TCC, macOS 13+)** blocks any process from
modifying another app's bundle regardless of ownership. `chmod` fails despite `yash` owning
the file.
**Fix:** System Settings → Privacy & Security → **App Management** → enable the terminal
(Ghostty). Note this is a broad grant: anything run in that terminal may then modify installed
apps. Declining just leaves that app unmanaged.
**Why only some casks hit it:** casks whose files already satisfy `a+rX` make the chmod a
no-op and pass; only a bundle with a genuinely non-conforming mode triggers the block. So the
failure looks arbitrary across a batch when it isn't.

**Cross-ref:** third TCC surprise of this migration, after the removable-volume grant (only
Ghostty held it) and the Terminal.app plist-rewrite-on-quit trap. On macOS, **POSIX
permissions are necessary but not sufficient** — TCC sits above them and fails with ordinary
errno values that read like permission bugs.

### Android USB tethering does not work on macOS at all (Linux→Mac migration)

**Context:** MacBook Air, macOS 26.5.1, Samsung Android phone, USB-C to USB-C.
Tethering worked on Arch; on macOS nothing appears in Network settings. First
suspicion was the macOS firewall.

**Problem:** Android USB tethering speaks **RNDIS** (Microsoft Remote NDIS).
Windows and Linux ship RNDIS drivers; **macOS never has**. macOS supports only
CDC-ECM and CDC-NCM. The phone enumerates on USB, no driver matches, no network
interface is created, and there is nothing in System Settings to configure — a
**silent no-op**, not an error.

The macOS Application Firewall is *not* involved: it only blocks incoming
connections to listening services and cannot prevent interface creation. Ruling
it out is free.

**Fix / diagnosis:** two commands separate "device not seen" from "seen but no
driver":
```sh
ioreg -p IOUSB -w0 -l | grep -iE '"USB (Product|Vendor) Name"|idProduct|idVendor'
networksetup -listnetworkserviceorder
```
Device present in `ioreg` + absent from the service list = driver gap, and it
also **proves the cable is data-capable** (charge-only C-C cables don't
enumerate), which rules out the most common false lead in one step.

Beware `en2`/`en3` "Ethernet Adapter" red herrings — on Apple Silicon these pair
with `anpi0/anpi1` (`AppleUSBDeviceNCMPrivateEthernetInterface`), are Apple
*internal*, and sit at `media: none, status: inactive` regardless of what's
plugged in.

Real options: Wi-Fi hotspot (native, faster than USB anyway — plug the cable in
alongside just for charging); check Android Developer Options for a **CDC-NCM**
tethering toggle (newer One UI builds; macOS binds it with zero drivers);
Bluetooth PAN (native, ~1–3 Mbps). **HoRNDIS** is dead (unsigned kext, no Apple
Silicon, needs SIP disabled). **ReRNDIS** (JellyBrick, GPL-3.0) is the userspace
successor and needs no SIP change, but as of 2026-08-06 it was created 6 days
prior with one release and 0 stars — too immature to route all traffic through.

**Generalises:** second instance of the same migration failure mode — *a
Linux-era config path, option, or protocol carried to macOS tends to silently
no-op rather than error.* When a Linux habit "does nothing" on macOS, check for
an absent driver/module before assuming a setting is hidden. See also the VLC
skins2 lesson.

**Adjacent, same session:** macOS has **no built-in per-app lock** — Touch-ID
app locking is third-party only. Vet by repo/vendor maintenance, and treat all
such tools as privacy curtains, not security boundaries (Terminal stays
reachable by design, so the daemon can always be killed).

### exFAT cluster slack makes small-file trees ~6x larger on a flashdrive
*Captured 2026-08-08, macOS→Linux migration drive.*

**Context:** staging trees onto an exFAT flashdrive for a machine migration; `df`
showed 85G used on a 115G stick while `du -sh` over every visible dir summed to 55G.

**Problem:** exFAT formats large volumes with 128 KiB clusters. Every file, however
small, consumes a full cluster. An `imagehtr/` tree of 115,361 mostly-tiny files held
466 M of real data but occupied **3.0 G** on the drive. Budgeting capacity from real
data size overruns the drive at roughly a third of nominal capacity, and the
`df`-vs-`du` gap looks like phantom/hidden data (it is not — check `.Trashes` to rule
that out, then stop hunting).

**Fix:** `tar -czf` small-file trees before writing them to exFAT; copy only large
files loose. When auditing a drive, compare `df` to `du` early and attribute the gap to
slack rather than chasing it. Verify copies by content (`rsync -rcn --itemize-changes`
or a `sha256sum` manifest) — never by size, since apparent size differs per filesystem.

### ReRNDIS on macOS: it works — plus the IOKit user-client level trap

**Context:** follow-up to the Android-USB-tethering lesson above. Galaxy M35 5G
(One UI 8.5) + MacBook Air, macOS 26.5.1. ReRNDIS built from source and
installed as a root LaunchDaemon. Outcome: **it works** — real DHCP lease,
`reconciler: tether service is primary`, MBs transferred. The earlier
"too immature, don't run it" call was overturned by evidence.

**Problem 1 — the wrong inference (the actually valuable bit).** `ioreg` showed
`Brave Browser <AppleUSBHostDeviceUserClient>` attached to the phone, and
sessions were dying with `kIOReturnNotResponding` (0xe00002ed) on bulk-in. I
concluded Brave was stealing the endpoints. **Wrong.** IOKit user clients attach
at different *levels* of the tree:
- `AppleUSBHostDeviceUserClient` — device level (what a browser's WebUSB grant creates)
- `AppleUSBHostFrameworkInterfaceClient` — interface level (what a driver creates)

Both coexist on the same device simultaneously with no contention. Proof: with
Brave reopened and holding its device-level client, ReRNDIS held interface-level
clients on *both* RNDIS interfaces and pushed 3.7 MB. A browser attached to a USB
device is **not** evidence it is blocking a driver — check which level the
clients sit at before blaming one.

**Problem 2 — sessions drop, and only a HOST-end replug recovers them.** Sessions
die with `kIOReturnNotResponding` at irregular intervals (3m08s, 6m27s, sometimes
instantly). Unplugging at the *phone* end or toggling tethering does not reliably
recover; **unplugging at the Mac end does**, because it forces host-side USB
re-enumeration and clears stale endpoint state. Also: the first attach after a
drop frequently dies in its own second; the second attach succeeds. ReRNDIS does
not re-enumerate on bulk-in abort, so recovery is manual.

**Problem 3 — no menu-bar/Network-panel indicator, and that is correct.** ReRNDIS
never creates a macOS *network service*; it makes a `feth` pair and writes the
default route + `State:/Network/Global/DNS` directly via SCDynamicStore. Traffic
flows with nothing to show in System Settings. Absence of an indicator is the
design, not a fault. Corollary: `networksetup -listnetworkserviceorder` will
never list it.

**Fix / techniques worth reusing:**
- Decode IOKit errors from the SDK header, never memory:
  `grep -rh "0x2ed" /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/libkern/`
  → `kIOReturnNotResponding`.
- Prove which interface carried traffic without disturbing Wi-Fi:
  `curl -s --interface feth0 -w "%{http_code} %{time_connect}" https://...`
- Check for the stranded-route failure mode after any teardown:
  `netstat -rn -f inet | head`, `scutil <<< "show State:/Network/Global/DNS"` —
  if `__IF_INDEX__` and `__CONFIGURATION_ID__` match the live Wi-Fi service, it's
  configd's own record, not a leftover manual override.
- `swift test` needs full Xcode (`Testing` module); Command Line Tools alone
  builds fine but cannot run swift-testing suites. Say so rather than implying
  tests passed.

**Patch applied locally** (`~/Projects/PersonalProjects/rerndis`, commit on top of
upstream): `DeviceMatching.swift:85` `candidate.number == interface.number + 1`
traps on `UInt8` 255 → promoted both sides to `Int`. Verified equivalent over all
65536 pairs. Worth reporting upstream along with the missing re-enumerate-on-abort.
