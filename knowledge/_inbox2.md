# Inbox 2 — uncurated capture lane (overflow of _inbox.md)

Append-only, same rules as `_inbox.md` (created because codex was writing `_inbox.md`
concurrently). Promotion into curated `knowledge/`/`patterns/` is human-approved via
`/review-knowledge-base`.

<!-- ===== 2026-07-15 PREEMPTIVE research batch (Eris CPU-only regime): 4-agent web-research fan-out over archetype playbooks / representation discovery / CPU tooling / validation+calibration. Sourced, CPU-regime-checked, deduped against known KB. 26 lessons. Promote winners into eris.md / exemplary-patterns.md. ===== -->

## Theme 1 — CPU-era archetype playbooks

### Snap predictions to the generator's discrete output lattice, then reverse-engineer the generator
Context: Target produced by a deterministic simulator/controller/quantizer, so the label set is a small FINITE grid (find-the-structure archetypes: Cross-Sport quantized glyph blocks, physics/DSP sims, PID/rule engines). Symptom: `df.y.nunique()` tiny vs row count.
Technique: (1) SNAP - after any regressor, round each prediction to the nearest value in `np.unique(y_train)` via searchsorted: free error cut because the true label can only land on that lattice. (2) DECODE - hypothesize the generator's closed form, grid-search its few params by EXACT-MATCH not by loss (Ventilator winners posited `pressure = kt - u_in/kp`, swept (kt,kp), accepted only the pair whose computed values aligned exactly with the 950 observed - worth +0.004, decisive at the top).
Why/when it wins vs fails: Wins when input->label is deterministic + low-parameter (you recover the function, not its marginals). Fails/misleads if the generator injects per-row noise or a hidden latent - exact-match never triggers and snapping to a non-discrete grid ADDS error. Test first: is a strong model's residual quantized/striped? If smooth Gaussian, don't decode.
CPU cost: Trivial - vectorized numpy grid sweep + `np.searchsorted`. Milliseconds.
Source: https://medium.com/data-science/winning-the-kaggle-google-brain-ventilator-pressure-prediction-2d4c90d831ec

### Find-the-fake / anomaly-in-a-set: ensemble cheap shallow detectors, score WITHIN group, and even 1% labels flips you to supervised
Context: "Which item in this group is corrupted/OOD" - tabular/feature-vector anomaly, forensics/tamper.
Technique: ADBench (30 algos x 57 datasets): no unsupervised method statistically dominates, so ensemble diverse CHEAP detectors on rank-score - IForest + ECOD + COPOD + HBOS + kNN/LOF (LOF local, kNN global). Deep unsupervised AD (DeepSVDD/DAGMM) ranks BELOW these (extra hyperparameters, no validation signal to tune them). Decisive for our regime: with just 1% labeled anomalies, semi-supervised beats best-unsupervised (median AUROC 75.56 vs 60.84) - so synthesize a handful of process-matched corruptions and train a supervised GBM. Label-free score: feature-subset consistency (predict a random feature subset from its complement; SLAD/ICL +7-21% AUC-ROC over IForest) beats reconstruction/density on feature-DEPENDENCY anomalies. For "which is fake", score every item then argmax WITHIN its group (relative) so group-level nuisance shift cancels.
Why/when it wins vs fails: Deep AD fails from no held-out tuning signal; reconstruction/density fail on high-dim dependency anomalies (a row plausible per-feature but inconsistent across features). Escapes the KB's "discriminator-on-your-own-corruption overfits" trap two ways: process-matched corruption, OR the label-free subset signal that never sees synthetic labels.
CPU cost: IForest/ECOD/COPOD/HBOS `n_jobs=-1` on 62 GB = seconds-minutes for 100k x 100; SLAD/ICL small MLPs, minutes. Well inside 1.5h.
Source: https://ar5iv.labs.arxiv.org/html/2206.09426 ; https://ar5iv.labs.arxiv.org/html/2305.16114

### Sequence labeling on CPU: iterated dilated CNN (ID-CNN), not BiLSTM - 8-14x faster at equal F1
Context: token/char classification, NER-like tagging where the grader RE-TRAINS+infers on 10 CPU cores in 1.5h. (Beyond the KB's char-BiLSTM.)
Technique: Replace BiLSTM(-CRF) with an Iterated Dilated CNN - stacked 1D dilated convs (dilations 1,2,4,...) applied repeatedly with SHARED params for a wide receptive field at fixed depth. CoNLL-2003: greedy ID-CNN (no CRF) 90.32 F1 at 14.1x faster than BiLSTM-CRF; ID-CNN-CRF 90.54 (matches BiLSTM-CRF 90.43) at 1.28x; document-level ID-CNN 90.65 at 7.96x. Keep the CRF ONLY when illegal label sequences (BIO validity, span structure) are a real error source; else greedy per-token decode gets ~all the F1 at ~10x throughput.
Why/when it wins vs fails: An LSTM is inherently sequential (O(N), no batching help); dilated convs parallelize across the whole sequence - on 10 CPU cores over long sequences that's the difference between fitting and blowing the wall clock. The CRF's Viterbi decode re-serializes inference and erases the speed edge for only ~0.2 F1 - spend it only if you'd otherwise emit illegal transitions.
CPU cost: char/word embeds + 4-block ID-CNN = a few M params, trains in minutes, infers thousands of tokens/sec on CPU. Fits with room to spare.
Source: https://ar5iv.labs.arxiv.org/html/1702.02098

### Matching / re-ID / entity linking: blocking RECALL is the hard ceiling - measure it FIRST, then symmetric-similarity GBM + transitive-closure clustering
Context: Link entities/records/tracklets across sources under shift; dedup; any pair-then-cluster task.
Technique: (a) BLOCKING/candidate generation (ANN on cheap embeddings, sorted-neighborhood, multi-key grouping with per-key size caps ~1000 to kill quadratic blowup) - this stage's RECALL caps the whole pipeline: every true match not proposed here is unrecoverable, so MEASURE candidate recall first and push past ~0.98 before touching the matcher. (b) Pairwise matcher: XGBoost over a BANK of ORDER-INVARIANT similarities (Jaccard, Cosine, Dice, Overlap, Levenshtein, Jaro-Winkler, Monge-Elkan, exact) with f(a,b)=f(b,a); emit a probability. (c) Entity formation: build a graph (edge=match prob), take connected components / greedy disjoint max-weight cliques instead of thresholding pairs independently - enforces transitivity and repairs contradictions (A~B, B~C, A!~C). Calibrate the threshold on a grouped holdout.
Why/when it wins vs fails: Teams over-engineer the matcher while blocking caps recall (a perfect matcher on a 0.80-recall block ceilings at 0.80). Symmetric features stop the classifier learning record-ORDER artifacts (a real leak when pairs are stored (a,b) consistently). Transitive closure beats independent pair thresholds by resolving contradictions.
CPU cost: hashing/ANN blocking near-linear; similarity bank + XGBoost over millions of pairs = minutes on 10 cores / 62 GB (MERAI processed 15.7M records). Fits.
Source: https://arxiv.org/html/2508.03767v1

### Small-object detection without ultralytics: slicing-aided FINE-TUNING (train on tiles) + full-image merge, not just tiled inference
Context: tiny objects in large images, CPU-only, torchvision detectors (no ultralytics/YOLO, no smp). (Beyond the KB's tiled Faster R-CNN.)
Technique: SAHI has two levers; the TRAINING one is the bigger, commonly-skipped win. (a) Slicing-aided fine-tuning (SF): cut TRAINING images into overlapping tiles (~400-640px, 25% overlap), train on tiles+originals so small objects appear large vs the receptive field. (b) Sliced inference: tile the test image identically, detect per tile, map boxes back, merge with NMS/NMM. (c) Keep ONE full-image pass and merge it (FI) so objects larger than a tile aren't chopped. VisDrone: sliced inference alone +5.1-6.8% AP; SF+sliced together +12.7-14.5% AP; FI adds up to +3.3% large-object AP on xView. Use torchvision FCOS/RetinaNet (anchor-free/one-stage, cheaper per pass on CPU) or Faster R-CNN.
Why/when it wins vs fails: Inference-only tiling still leaves the detector TRAINED on down-scaled tiny objects - SF is ~half the AP gain, so skipping it caps you. Without FI, objects spanning tiles get split+dropped. Overlap <25% misses objects on tile seams; tiles too small explode the pass count and blow the wall clock.
CPU cost: runtime ~ (image_area/tile_area) x per-tile cost; FCOS-R50 on ~500px tiles ~ 0.1-0.3s/tile on CPU - pick tile size so total passes fit 1.5h. SF adds zero inference cost (training-data change only).
Source: https://ar5iv.labs.arxiv.org/html/2202.06934

### Text restoration / diacritization / OCR post-correction: char-level + noisy-student self-training on the PROVIDED unlabeled corpus (~5% relative error cut, compliant)
Context: diacritization, OCR post-correction, GEC, script restoration - sub-token character edits. (Beyond the KB's edit-tagger.)
Technique: Model at CHARACTER/BYTE granularity (subword tokenizers hide the very edits you must predict). Add noisy-student self-training: train a first char model on labeled train, PSEUDO-LABEL the large raw/unlabeled text shipped with the challenge, retrain on labeled + pseudo-labeled. CATT reports this alone cuts DER ~5% relative on top of an already-strong char transformer; MLM-pretraining the char encoder on the provided corpus first stacks further.
Why/when it wins vs fails: Self-training uses ONLY challenge-provided data (critical under no-external-data) and turns unlabeled text into free supervision - wins when there's substantial raw text AND the base model is already decent. Fails when pseudo-labels are noise (base too weak) - gate by keeping only high-confidence pseudo-labels. Char granularity fails on very long sequences (quadratic attention) - use a dilated-CNN/BiLSTM char encoder or chunk.
CPU cost: a small char transformer/BiLSTM trains in minutes-to-tens on CPU for a challenge-sized corpus; one self-training round ~doubles train time, still clears 1.5h (CATT needed an A100 only for 1M+ sentences).
Source: https://arxiv.org/html/2407.03236v1

### Ranking / within-group ordering: retrieve-then-rerank, candidate RECALL caps the reranker, LightGBM lambdarank on group-RELATIVE features
Context: learning-to-rank, recommend/retrieve top-K within groups, order-items-within-group metrics.
Technique: (a) Cheap candidate generation (co-visitation/co-occurrence counts, ANN, popularity) down to ~100-200 per group - the reranker CANNOT beat candidate recall@K (OTTO's reranker hard-capped at recall@20 ~ 0.196/0.152/0.160), so measure+maximize candidate recall FIRST (exact analogue of blocking-recall). (b) Rerank with LightGBM lambdarank (`objective=lambdarank, metric=ndcg`, correct `group` array), ~1:40 pos:neg. (c) The gain lives in FEATURES not the objective: group-RELATIVE dominate (item rank/percentile WITHIN its group, co-occurrence counts, recency; OTTO top features: covisitation ~28% + item-rank-within-session). (d) If the metric splits by sub-objective (click/cart/order), train a SEPARATE ranker per objective.
Why/when it wins vs fails: Single-stage ranking over the full universe is too slow on CPU and dilutes signal; retrieve-then-rerank concentrates compute. Silent failure = low-recall candidate set caps the score regardless of reranker quality. Raw per-item features underperform group-relative (ranking is inherently relative). GBDT matches/beats deep LTR on engineered features at ms vs s inference, no GPU - the correct CPU default.
CPU cost: candidate gen via groupby/co-visitation near-linear; lambdarank over millions of (group,item) rows = minutes on 10 cores. Deep LTR would not fit.
Source: https://github.com/nicolaivicol/otto-recommender

## Theme 2 — Representation discovery & smart experimentation

### Let CatBoost's ordered target statistics do the encoding; hand-rolled OOF target encoding still leaks under group/time shift
Context: High-cardinality categoricals (IDs, families, source groups); train/test source-disjoint.
Technique: Prefer CatBoost native `cat_features=[...]` - its ordered TS computes each row's category mean from only PRECEDING rows in a random per-tree permutation, so no row sees its own label (kills the prediction-shift plain KFold-OOF target encoding leaves). If hand-rolling for LGBM/XGB: the ENCODER's fold split must match the eval split - random KFold-OOF still leaks when categories cluster by group, so encode with GroupKFold on the SAME group, and smooth `(n*mean_cat + m*global)/(n+m)`, m~10-50, so rare categories fall to the prior.
Why/when it wins vs fails: Leakage isn't just "used my own label" - it's "used labels correlated with mine through a shared group"; random OOF doesn't break that, grouped OOF does. Fails if `has_time=False` on temporal data, or smoothing off on a long tail (rare encodings become noise the GBDT splits on = public mirage, private collapse).
CPU cost: Native, `thread_count=-1`, 62 GB holds large frames; few-hundred iters on 10 cores = minutes.
Source: https://arxiv.org/abs/1706.09516

### On small/shifted data, count/frequency-encode BEFORE target-encoding - it survives category shift target encoding can't
Context: Disjoint train/test groups, long-tailed categoricals, small N (the Eris norm).
Technique: Add count/frequency encoding as a first-class feature computed on train+test COMBINED (uses no labels -> pooling legal, gives unseen test categories a real value). Keep a smoothed OOF target encode too but treat count as the robust default; let the GBDT choose. Map unseen categories in target encoding to the GLOBAL PRIOR, never NaN->0 (a tree reads 0 as an extreme category).
Why/when it wins vs fails: Count carries no label dependence -> zero prediction-shift, degrades gracefully on unseen categories, and WINS outright when frequency itself is signal (fraud/typos/minority families = rare-vs-common is predictive). Target encoding fails precisely under shift: a category train-dominant but test-rare contributes a confident label-derived number in train and the prior in test - the model leans on a feature that evaporates. Count's only failure: two categories sharing a frequency collide - pair with one more encoding.
CPU cost: Negligible - `value_counts().map`.
Source: https://feature-engine.trainindata.com/en/1.8.x/user_guide/encoding/index.html

### Cross-row group aggregations are the features a GBDT physically cannot invent - but target-based ones leak
Context: Data with a group key (session/family/source/entity) and multiple rows per key.
Technique: A tree only splits on within-row values, so it can NEVER compute "value minus its group mean" or "rank within group". Precompute per-group mean/std/min/max/count/median of each numeric feature, then row-relative transforms (value - group_mean, value/group_mean, within-group rank/percentile). Within-group rank + z-score are the shift-robust ones - they cancel the group-level offset that is often the exact train<->test drift. These aggregate FEATURES (not labels) -> compute on train+test together, no leakage.
Why/when it wins vs fails: Hands the model a cross-row interaction it structurally cannot reach; within-group normalization additionally cancels between-group shift. Failure that revokes prizes: aggregating the TARGET by group is target encoding in disguise (needs OOF); and feature aggregations "population-leak" if group membership itself encodes the split. Rule: aggregate features freely on the pool, aggregate labels only OOF, never aggregate over a key whose composition differs train vs test unchecked.
CPU cost: `groupby().transform()` over 62 GB is seconds (polars lazy faster). No model cost.
Source: https://valeman.medium.com/kaggle-folklore-is-not-data-science-and-its-hurting-real-ml-66e6ee341dcf

### Feature hashing is LEGAL for categorical IDs but still BANNED when used as a text vectorizer
Context: Post-TF-IDF/BoW ban; tempting to reach for `HashingVectorizer`. Also genuinely useful for extreme-cardinality categoricals.
Technique: Draw the line by WHAT you hash. Hashing a high-cardinality categorical VALUE (user_id, sku) into K buckets is a dimensionality-reduction encoding - a legal one-hot alternative. But hashing word/char n-grams of free text produces a hashed bag-of-n-grams - sklearn's own docs frame `HashingVectorizer` as a drop-in for `CountVectorizer`/TF-IDF, i.e. it IS BoW with the vocab replaced by a hash -> falls under the ban, do NOT bank it as an NLP workaround. For text use a small pretrained encoder or a from-scratch char/token seq net. For the legal categorical use: buckets ~ next power of two above cardinality/2; pair with a count encode so colliding categories stay separable by frequency.
Why/when it wins vs fails: Categorical hashing wins on cardinality that blows up one-hot or leaks via target encoding, and handles unseen values gracefully. Fails with too-few buckets (collisions merge unrelated categories) - and fails COMPLIANCE the moment the "categories" are text tokens.
CPU cost: Single pass, O(rows), no stored vocabulary. Trivial.
Source: https://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.HashingVectorizer.html

### Vet each representation with null-importance (target-permutation) before committing
Context: You've built a candidate feature bank on small shifted data and need a cheap, model-honest "real signal vs memorized noise" filter inside the budget.
Technique: Fit the model M times on the TRUE target (actual importances) and N>=20 times on SHUFFLED targets (null importances), same features/model. A feature is real only if its actual importance exceeds ~the 95th percentile of its OWN null distribution; features scoring as high on shuffled labels as real ones are noise the tree memorized - exactly the ones that inflate public then collapse. Score = actual / null-percentile, keep the top set. Truer than raw gain because it's calibrated against what THIS model extracts from randomness.
Why/when it wins vs fails: Separates signal from overfit using the model's own behavior, not a generic correlation - prevents shipping a public-tuned feature set. Fails if N too small (noisy null -> unstable cutoff) or under correlated features (importance splits across duplicates, both look weak - dedup first).
CPU cost: N+M shallow GBDT fits on 10 cores - tens of seconds to a few minutes; dev-time filter, not in solution.py.
Source: https://target-permutation-importances.readthedocs.io/en/latest/

### Adversarial validation: build a private-tracking CV fold AND triage (don't blindly drop) shifted features
Context: Train/test from disjoint source groups (Eris default); GroupKFold CV disagrees with public/private and you can't tell which folds resemble the hidden test. [MERGED from two independent agents.]
Technique: Label train=1, test/public=0, pool+shuffle, fit CatBoost/LGBM (~100 iters, eval AUC). AUC~0.5 aligned (CV trustworthy); 0.75-0.95 strong covariate shift; >0.95 near-separable (suspect an ID/index leak first). Two exploits: (1) FOLD SELECTION - rank train rows by P(test); the most test-like rows become a dedicated validation fold (or importance-weight them) so local CV tracks the private distribution, not the easy in-distribution slice. (2) FEATURE TRIAGE - the classifier's top features are the drifting ones, but do NOT auto-drop (a feature can be both drifting AND label-predictive): transform to remove only the drift component (strip time digits from a version string, absolute date -> "days since first row", z-score within group); drop only if drifting AND not predictive.
Why/when it wins vs fails: Converts an invisible pub->private gap into a measurable AUC + concrete feature list; the test-like split stops public-LB overfit. Fails when AUC~1.0 is driven by a nuisance ID/row-hash (you'd amputate the whole feature set - inspect WHAT drives the AUC first), and under PURE label shift (P(x) identical) AUC stays ~0.5 and tells you nothing - use label-shift tools (BBSE/MLLS) instead.
CPU cost: One ~100-iter GBM on stacked rows - seconds to low minutes, dev-time only, deterministic with a fixed seed.
Source: https://blog.zakjost.com/post/adversarial_validation/ ; https://medium.com/@nlztrk/adversarial-validation-a-sanity-checker-and-an-exploiter-2dff1baced19

## Theme 3 — CPU-fast modeling & inference tooling

### LightGBM out-scales XGBoost on CPU cores; set threads to PHYSICAL cores, not the 10 "vCPUs"
Context: any GBDT on the 10-core/62 GB grader; booster + thread-count choice.
Technique: Set `num_threads`/`nthread` to REAL physical cores, never hyperthreads. LightGBM scales far better than XGBoost across cores (Laurae sweep: LightGBM up to +1116% vs single-thread, XGBoost only +154% on the same box). Per-tree build ranks CatBoost 17.9ms < LightGBM 40ms << XGBoost-hist 488ms, but LightGBM gives the best speed/accuracy at scale - default for large matrices. If the "10 cores" are 5-physical-with-HT, `num_threads=10` can run SLOWER than `=5` (histogram build oversubscribes) - benchmark both early.
Why/when it wins vs fails: threads past physical cores add scheduling overhead with no compute gain (LightGBM docs: "using too many threads makes performance worse"; "use the number of real CPU cores"). XGBoost's poor thread scaling wastes most of the 10 cores. Fails on small data: "do not expect lots of threads to scale well (it will negatively scale)".
CPU cost: correct thread count is a 2-10x wall-time lever - more in-budget rounds/members = higher score.
Source: https://lightgbm.readthedocs.io/en/latest/Parameters-Tuning.html

### onnxruntime / Optimum / OpenVINO are NOT in packages.md - the entire ORT int8 CPU-inference playbook is BLOCKED at grading
Context: any plan to speed CPU transformer inference via ONNX Runtime or HF Optimum. The single biggest trap in the "fast CPU inference" literature for this platform.
Technique: packages.md has ONLY `onnx` (the exporter/IR), NOT `onnxruntime`, `optimum`, `openvino`, or `intel-extension-for-pytorch`. `mkl` + `intel-openmp` ARE present. So you can EXPORT an ONNX graph but cannot RUN it, and runtime `pip install onnxruntime` is a hard rejection. Every blog showing "6x CPU speedup with ORT int8" is unusable here - use the pure-PyTorch path (`torch.quantization.quantize_dynamic` + `torch.set_num_threads`). VERIFY every inference-accel lib against packages.md before building around it.
Why/when it wins vs fails: reviewers reject non-packages.md imports regardless of score; discovering this at submission burns a credit. The mistake is copying an ORT recipe because it has the best published numbers.
CPU cost: n/a - an availability gate.
Source: /home/ysh/Projects/Eris/packages.md (only `onnx` present) ; https://medium.com/microsoftazure/faster-and-smaller-quantized-nlp-with-hugging-face-and-onnx-runtime-ec5525473bb7

### PyTorch dynamic int8 quantization: the available CPU transformer speedup, but ~1.8x (Linear-only), not the 4-6x ORT/VNNI blogs cite
Context: forward-passing a DistilBERT/MiniLM/ChemBERTa-scale model over N-thousand samples in 1.5h on CPU, onnxruntime unavailable.
Technique: `torch.quantization.quantize_dynamic(model, {torch.nn.Linear}, dtype=torch.qint8)` - quantizes only nn.Linear (+LSTM) weights to int8, activations on the fly; attention/embedding/LayerNorm stay fp32. Official BERT/MRPC tutorial: 438MB->181MB, F1 0.9019->0.902, inference 160s->90s @1 thread / 85s->46s @4 threads (~1.8x). Pair with `torch.set_num_threads(<physical cores>)`.
Why/when it wins vs fails: int8 GEMM is the win, but MAX int8 throughput needs AVX-512 VNNI (3.7x over AVX-512 fp32) - on AVX2-only CPUs the gain shrinks toward marginal and can regress, so budget ~1.8x. Multithread gains saturate on memory bandwidth, so quantization's relative win is LARGEST at low thread counts. Doesn't help models dominated by non-Linear ops.
CPU cost: ~1.8x faster + ~2.4x smaller ~ roughly doubles the samples you can score in-budget.
Source: https://docs.pytorch.org/tutorials/intermediate/dynamic_quantization_bert_tutorial.html

### joblib x BLAS oversubscription: on 10 cores pick n_jobs=10 with 1 BLAS thread OR n_jobs=1 with 10 - never both
Context: any sklearn/joblib parallel loop (CV, RandomForest, per-fold GBDT, feature funcs) that internally calls MKL/OpenBLAS/OpenMP.
Technique: total threads = `n_jobs x <LIB>_NUM_THREADS`. The `loky` backend auto-caps children at `n_cpus//n_jobs` (n_jobs=10 -> 1 BLAS thread each = 10 total, correct). BUT manually exporting `OMP_NUM_THREADS`/`MKL_NUM_THREADS` OVERRIDES loky's cap (n_jobs=10 x OMP=10 = 100 threads on 10 cores); the `threading` backend has NO protection at all. Rule: parallelize at ONE level - wide-shallow (n_jobs=10, BLAS=1) for many light tasks; narrow-deep (n_jobs=1, threadpoolctl BLAS=10) for few heavy linear-algebra tasks. HistGradientBoosting already uses OpenMP+threadpoolctl - don't wrap it in an n_jobs loop.
Why/when it wins vs fails: oversubscription adds pure context-switch overhead - a "parallel" run ends slower than serial, silently eating the 1.5h. The trap is setting env vars "to be safe" and defeating loky.
CPU cost: eliminating N-way oversubscription commonly recovers 2-5x on nested loops.
Source: https://scikit-learn.org/stable/computing/parallelism.html

### Build features in polars/duckdb, not pandas - pandas leaves 9 of 10 cores idle
Context: any feature engineering with group-bys, joins, window functions, or large CSV reads (both libs in packages.md).
Technique: pandas is single-threaded for almost all ops; polars is multithreaded by default; duckdb parallelizes SQL and spills to disk if 62 GB is tight. Measured vs pandas: group-by polars ~8.7x / duckdb ~9.4x; joins ~5x / ~4x; window functions duckdb ~10x; CSV read polars ~7.7x; polars also 30-60% less RAM. Route by shape: polars for filter-then-aggregate dataframe pipelines, `duckdb.query("...")` for multi-join/subquery SQL over raw files. Convert to pandas only at the sklearn/LightGBM boundary.
Why/when it wins vs fails: on 10 cores the win ~ core count for parallelizable ops; evaporates on tiny data (thread setup dominates) or row-at-a-time Python UDFs (stay vectorized/native-expression).
CPU cost: turns a multi-minute feature build into tens of seconds, freeing budget for more model members.
Source: https://medium.com/@ThinkingLoop/pandas-vs-polars-vs-duckdb-fastest-analytics-in-2025-44c3162e5f73

### GBDT beats NN on tabular within a 1.5h CPU budget - default to trees unless the modality forces a net
Context: the recurring "gradient-boosted tree vs neural net" fork on CPU-only tabular/structured challenges.
Technique: For tabular up to ~mid-size samples, tree ensembles are SOTA over tuned deep nets even before their speed edge (Grinsztajn et al., NeurIPS 2022, 45-dataset benchmark). Trees win because they're robust to uninformative features, rotation-invariant (preserve feature orientation), and learn irregular/piecewise-constant targets MLPs smooth over - and need far less HPO to reach their ceiling. Reserve NNs for where their inductive bias pays: raw text/image/audio/sequence, very high-cardinality categoricals, or very large N. On CPU/1.5h the tree's low tuning cost compounds (full CV + several seeds vs one under-tuned net pass).
Why/when it wins vs fails: fails only when the signal lives in a modality trees can't ingest (pixels, token order) - there the pretrained-encoder-then-head route wins. Don't reach for TabNet/FT-Transformer on CPU; they cost more and rarely beat LightGBM here.
CPU cost: trees hit ceiling in minutes vs a net's full-budget single run - strictly better accuracy/time on tabular.
Source: https://neurips.cc/virtual/2022/poster/55627

### LightGBM throughput knobs so more members fit the budget (GOSS is only ~1.3-1.8x in practice, not the paper's 20x)
Context: squeezing more trees/rounds/ensemble members into 1.5h once LightGBM is chosen - script throughput is itself a score lever.
Technique: (1) `max_bin=63` (vs default 255) - fewer histogram bins = faster build, usually negligible accuracy loss. (2) `force_col_wise=true` (or row-wise) to skip LightGBM's startup auto-test of both directions (the log prints which to set). (3) `early_stopping_round` on a val set to kill dead rounds. (4) GOSS (`data_sample_strategy='goss'`) - real-world speedup only ~1.3-1.8x (NOT 20x), slightly perturbs accuracy, so treat as a modest lever AND a decorrelated best-of-N member. (5) `feature_fraction`/`bagging_fraction`+`bagging_freq` cut per-tree work and decorrelate. Prefer more diverse in-budget members over HPO inside seed noise.
Why/when it wins vs fails: max_bin/force_col_wise/early_stopping are near-free time wins; GOSS underdelivers vs its reputation and can hurt on small/clean data (all gradients informative) - measure, don't assume; bagging too aggressive underfits.
CPU cost: max_bin 255->63 + force_col_wise commonly cut train time 20-40%; that budget buys extra seeds/folds.
Source: https://github.com/microsoft/LightGBM/issues/2902

## Theme 4 — Validation & calibration under shift + log-loss metrics

### Pick the calibrator by calibration-set size, and fit it from scratch (netcal/betacal/dirichletcal are NOT installed)
Context: composite/log-loss-heavy metric; you have logits and need calibrated probabilities. Only `sklearn.calibration`, `scipy`, `numpy` available.
Technique: Ladder by disjoint calibration-fold size N (per class): N < ~500/class -> TEMPERATURE scaling (1 scalar T; `scipy.optimize.minimize_scalar` on val NLL of `softmax(logits/T)`); N in the thousands with class-dependent bias -> VECTOR/Dirichlet/matrix scaling `softmax(W·log p + b)` but MUST add ODIR (L2 on off-diagonal W and on b, strength proportional to 1/N) or the K^2+K params memorize noise; large N, monotone single-class distortion -> ISOTONIC. Always fit the calibrator on a GROUP-held-out fold disjoint from the model's training fold (nested/OOF), never in-fold.
Why/when it wins vs fails: Temperature is safest under shift (1 param can't overfit, only rescales confidence = the dominant miscalibration) - wins by default on small data. Dirichlet+ODIR beats it only when miscalibration is genuinely class-specific AND N large (unregularized it degrades below temperature). Isotonic overfits hard below a few thousand points (nonparametric monotone steps memorize the sample, extrapolate flat at the ends, spike log-loss on shifted tails). In-fold calibration reads perfectly calibrated locally and collapses on test - classic leakage.
CPU cost: all negligible (scalar/convex opt on cached OOF logits), seconds.
Source: https://arxiv.org/pdf/1910.12656 ; https://scikit-learn.org/stable/modules/generated/sklearn.calibration.CalibratedClassifierCV.html

### Label-shift prior correction: MLLS-on-bias-corrected-calibration beats BBSE; gate it or it backfires
Context: P(x|y) stable but the class prior P(y) differs between train and hidden test (find-the-rare-class, disjoint-source). Predicting with train priors inflates log-loss.
Technique: BBSE (detector + quick fix): confusion matrix `C[i,j]=mean 1{pred=i,true=j}`, predicted-label test histogram `mu`, solve `w=solve(C,mu)`, `pi_test=w*pi_train`, clip w>=0 + renormalize. MLLS/EM (the better estimator): FIRST calibrate with bias-corrected temperature scaling `softmax(logits/T + b)` (fit T,b on val NLL), THEN Saerens EM on calibrated test posteriors - init `pi_test=pi_train`; E `q(y|x) proportional to p(y|x)*pi_test/pi_train` (renorm per row); M `pi_test(y)=mean_x q`; ~20-50 iters. Predict with the converged ratio-adjusted posteriors.
Why/when it wins vs fails: Alexandari et al. (ICML 2020): naive EM fails because nets are overconfident/uncalibrated, and BBSE/RLLS confusion-inversion is high-variance when C is near-singular - MLLS on bias-corrected calibration beats both. BACKFIRES when (a) there's NO label shift (test prior=train prior) - forcing an estimated shift injects noise; gate on a real shift signal (BBSE w far from 1, or held-out-fold improvement); (b) tiny test set (mu noisy, EM chases sampling noise). Verify it improves a shifted held-out fold first.
CPU cost: trivial - matrix ops x dozens of iters on cached probability vectors, sub-second, deterministic.
Source: https://proceedings.mlr.press/v119/alexandari20a.html ; https://arxiv.org/abs/1802.03916

### Blend probabilities for log-loss: arithmetic mean is the safe default; log-pool (geo-mean of odds) only for decorrelated calibrated models
Context: several models' probabilities, a log-loss metric, choosing the blend for the single submission and extra best-of-N draws.
Technique: ARITHMETIC mean `mean(p_k)` is the default - proper, variance-reducing, guaranteed at-least-as-calibrated as the member mean, can't be wrecked by one confident-wrong model. LOG-POOL / geo-mean of odds `p proportional to exp(mean(log p_k))` (average log-odds) EXTREMIZES: matched to the log scoring rule, use ONLY when members are individually calibrated AND decorrelated (different feature families/architectures). Temperature-scale each model separately first so no overconfident member dominates.
Why/when it wins vs fails: Log-pool wins when independent calibrated models genuinely agree - moves toward truth faster, squeezes log-loss. Fails catastrophically if any member assigns near-0 to the true class (`log 0=-inf` drags the geo-mean to ~0, one row dominates the whole log-loss) - always floor probs to [1e-6, 1-1e-6] before pooling. Arithmetic under-extremizes (timid when all are confidently right) but never blows up - hence the safe default. For correlated CV-fold models (same data), arithmetic wins.
CPU cost: free - elementwise ops on saved arrays.
Source: https://forum.effectivealtruism.org/posts/sMjcjnnpoAQCcedL2/when-pooling-forecasts-use-the-geometric-mean-of-odds

### F-beta / macro-F1 thresholding: per-class OvR thresholds are SEPARABLE for macro (calibrate first), coupled only for micro
Context: metric is (macro-)F1 or F-beta but the model emits probabilities; converting to hard labels for the metric, not 0.5.
Technique: Calibrate first (temperature), then optimize thresholds on OOF. MACRO-F1: optimize each class's OvR threshold INDEPENDENTLY - macro-F1 is the unweighted mean of per-class F1s and each class's F1 depends only on its own decisions, so per-class grid-search on OOF is exactly optimal. MICRO-F1 / instance-level expected-F1: thresholds are COUPLED across the set, tune jointly. Anchor: for a well-calibrated binary score the F1-max threshold ~ half the achieved optimal F1 (best F1 0.6 -> threshold ~0.3), so optimal thresholds sit well below 0.5 for hard/rare classes - expect it.
Why/when it wins vs fails: rare classes need low thresholds; leaving 0.5 silently zeroes minority recall and tanks macro-F1. Failure to guard: under an uninformative classifier the F1-optimal move degenerates to predicting a rare class ALL-positive (tiny denominator looks good on OOF) - overfits the visible fold, collapses private; cap thresholds or require minimum precision. Tune on grouped-OOF, never per public-fold.
CPU cost: trivial - 1D grid search per class over cached OOF probs, seconds.
Source: https://arxiv.org/pdf/1402.1892

### Importance-weighting for covariate shift helps ONLY under model misspecification - otherwise it just adds variance
Context: adversarial validation flags covariate shift and you're tempted to reweight the training loss by the density ratio.
Technique: From the adversarial model's `s=P(test|x)` (calibrated), set `w(x)=s/(1-s)`, reweight the train loss via `sample_weight`. CRITICAL stabilizers: clip/winsorize w at ~the 99th percentile (or cap the max) AND self-normalize (divide by mean weight) - unclipped ratios are heavy-tailed and blow up variance where train support is thin. Gate: only bother if the base model is misspecified for the shifted region - test whether importance-weighted CV actually improves on the test-like adversarial fold.
Why/when it wins vs fails: The non-obvious result (Shimodaira): if the model is well-specified, unweighted MLE is already asymptotically optimal and IW ONLY inflates variance (strictly hurts). Weighting reduces bias only under misspecification where the shift moves mass into poorly-fit regions. So the honest default under shift is NOT "always reweight" - on flexible models (GBMs, nets) that fit train well, IW usually DEGRADES private log-loss via variance. Clipping trades a little bias for large variance reduction and is almost always net-positive when you do weight.
CPU cost: trivial - weights from the already-fit adversarial classifier; reweighting is a `sample_weight` arg.
Source: https://arxiv.org/abs/1910.06324 ; https://davidrosenberg.github.io/ttml2021/missing-data/5.covariate_shift.pdf

### Best-of-N under a private set: send DECORRELATED draws, shrink toward CV when CV and public disagree
Context: every submitted attempt is independently graded on the private set (best-of-N = free draw), but a noisy public subscore tempts overfitting.
Technique: Treat submissions as a portfolio. Fix your strongest-CV solution as the FLOOR, spend remaining credits on DECORRELATED draws (different model family, calibration/label-shift correction, seed-ensemble) not near-duplicates of the leader - decorrelation is what makes an extra private draw actually raise expected best. When CV and public disagree, use the gap as a shrinkage signal: top-public/mediocre-CV is likely public-overfit - keep it as ONE speculative draw, never primary. Most draws track CV, at most one chases public.
Why/when it wins vs fails: private rewards robustness and independent draws each get their own private eval - your best is monotone non-decreasing in decorrelated attempts. Fails when "extra" draws are correlated tweaks (HPO inside seed noise, per-metric decode hacks) - they re-sample the same overfit and waste a credit. The disagreement signal weakens if public is itself a large representative subset (trust it more) - size the public set before deciding how hard to shrink.
CPU cost: N/A (submission strategy); each draw reuses trained artifacts.
Source: https://www.kaggle.com/competitions/tabular-playground-series-nov-2021/writeups/ambrosm-3-solution-don-t-trust-the-cv-scores
