---
name: ml-challenge
description: Senior-rigor playbook for COMPLEX ML/DL challenges (bio/omics, NLP/LLM, obscure scientific domains): data-audit, leakage hunt, baseline-first, correct CV/eval, domain model routing. Not for routine sklearn one-liners.
---
# ml-challenge

Methodology for hard ML/DL challenges (bio/omics, NLP/LLM, obscure scientific domains). **This skill owns the rigor; it ROUTES execution to the specialist skills below — they own the API.**

Use when: a competition/benchmark/client task is complex, the domain is unfamiliar, or naive modeling would silently mislead. Skip for routine sklearn one-liners.

## 0. Frame before you model
- Write the success metric + acceptance bar in ONE sentence before touching data: what score, on what split, beats what baseline, by when. (§8 audits against this — write it once.)
- Underspecified ask (no target, no metric, no "for whom")? → run `interview-me`. Don't fill gaps silently.
- Sanity check: can a human do this task / is signal plausibly present? Guard against modeling pure noise toward an unattainable bar.
- Classify the task (tabular / text / graph / sequence / image / RL / forecasting / survival / unsupervised) → drives §5 routing.
- Identify the **unit of prediction** AND the **unit of independence** (patient? molecule? document? time window? slide vs tile?). Often NOT the row. This decides the CV scheme (§4).

## 1. Data audit FIRST (most challenges are won/lost here)
- **Leakage — the #1 silent killer.** If a feature is "too good," assume leakage until proven otherwise. Hunt:
  - *Proxy/surrogate targets:* post-outcome fields recorded only after the label (`discharge_code`, `num_followup_visits`).
  - *Preprocessing-fit leakage:* scaler, imputer, target/mean-encoding, feature selection, PCA, vocabulary — fit on the train fold INSIDE the CV loop, never on full data before splitting.
  - *Temporal feature leakage:* rolling/lag/aggregate windows computed across the train/test boundary leak future into past even with correct row splits.
  - *Embedding/pretrain leakage:* unsupervised embedding or tokenizer/vocab fit on the full corpus (incl. test) before splitting.
  - *Duplicate/near-dup leakage:* augmented copies, paraphrases, same patient/different visit crossing splits → dedup by content hash + fuzzy match, not just ID.
  - *Length/truncation leakage (NLP):* label correlated with doc length or truncation point.
- **Split hygiene** — split by the independence unit. Lock test away; never fit/select/threshold on it.
- **Distribution shift** — adversarial validation (classifier train-vs-test; AUC≫0.5 = shift). It also names WHICH features drive shift (drop/down-weight) and lets you build a shift-matched val set. Distinguish covariate shift vs label shift vs concept drift — different fixes (importance-weight / reweight / retrain). For any deployable task, validate on the most-recent time block as a "future" proxy even if not framed as forecasting.
- **Label quality** — noise, annotator disagreement, weak/proxy labels, censoring. Hand-inspect raw examples.
- **Class imbalance** — measure base rate; pick metric (§4) + class weights accordingly. Never trust accuracy under imbalance.
- **Tiny-n / high-p (p≫n, e.g. n≈20, 20k features — common in omics):** heavy regularization, nested CV mandatory, distrust any single split.
- **Units/scale/encoding** — log-scale, NaN-vs-zero, categorical cardinality, **batch effects (omics)**, stain/magnification (histopath). Sanity-plot distributions.
- Record findings as explicit assumptions in the deliverable (§8).

## 2. Strong simple BASELINE before any deep model
- Ship a dumb baseline first: majority/mean, logistic/linear, gradient-boosted trees (tabular), TF-IDF+linear (text), label-propagation (graph), seasonal-naive (forecast).
- It calibrates the metric, exposes leakage (baseline scoring "too well" = leak), and sets the bar.
- **Any deep model must beat the baseline by a margin worth its cost, or be cut.** Complexity needs justification, not vibes. If nothing beats baseline, that null result IS the honest deliverable — don't manufacture a leaky win.

## 3. Eval design (get this wrong → everything downstream is noise)
- **CV scheme matched to data:** GroupKFold when units repeat (patients, molecules); forward-chaining (no shuffle) for time; stratified for imbalance; **group+time together** for panel data (same entity over time). Random KFold is usually WRONG for real-world data. Too few groups (e.g. 5 patients) → high-variance folds; prefer leave-one-group-out.
- **Nested CV is mandatory whenever the SAME data does hyperparameter selection AND performance reporting** — single CV optimistically biases the score. Threshold/early-stop selection counts as fitting on val; repeated val reuse overfits it.
- **Resampling/SMOTE inside the CV fold, after the split** — oversampling before splitting leaks synthetic neighbors across folds. Prefer class weights / threshold tuning / focal loss over blind SMOTE (hurts on high-dim/categorical). Never resample val/test — evaluate on the natural base rate; correct probabilities if the training prior changed.
- **Metric matched to goal:** ranking→AUC/AP, but under extreme imbalance/ranking-at-top prefer **PR-AUC / precision@k / partial AUC** + state the operating point. Calibrated probs→log-loss/Brier (and check reliability curve / ECE — calibration is a separate axis from discrimination). Regression→MAE vs RMSE by outlier sensitivity. Survival→C-index. Forecasting→MASE/sMAPE. Segmentation→IoU/Dice. Report a threshold-free metric AND the chosen-threshold metric (threshold from val, never test). State macro vs micro vs weighted aggregation, and per-group metrics to expose subgroup failure.
- **Multiple-testing correction (FDR / Benjamini-Hochberg)** when screening many hypotheses (thousands of genes in omics).
- **Report variance, not point scores:** mean ± std across ≥3–5 seeds/folds or bootstrap CIs. Seed sensitivity is itself a result — if rankings flip across seeds, the "winner" is noise. Compare models on the SAME folds/seeds (paired test or CI of the difference), not separate means. Trying N models and reporting the best (argmax) inflates the estimate — report the selection procedure.
- **No test-set peeking.** The test set is touched exactly once: feature choices, preprocessing tweaks, and "let me just re-run with X" all consume it. Report the CV-vs-test gap; a large gap is evidence of leakage or selection-overfit, not a number to silently accept.

## 4. Model routing — delegate to ACTIVE specialist skills
- NLP / text / tokenization / fine-tune LMs → **transformers** (+ **pytorch-lightning** for custom/multi-GPU loops).
- Graph NNs / molecules-as-graphs → **torch-geometric**. Plain graph analytics (centrality, communities, paths, no learning) → **networkx**, NOT PyG.
- Tabular / pipelines / preprocessing → **scikit-learn**; rigorous inference + diagnostics (OLS/GLM/mixed/ARIMA) → **statsmodels**.
- RL → **stable-baselines3** or **pufferlib** (fast/parallel/multi-agent).
- Bayesian / uncertainty / hierarchical / small-data → **pymc**.
- Univariate forecasting → **timesfm-forecasting**.
- Explainability / feature importance / debugging → **shap**.
- Nonlinear dim-reduction / embedding viz / cluster prep → **umap-learn**.
- Scaling up a validated pipeline, or CPU-bound numpy/pandas/sklearn/graph hotspots → **optimize-for-gpu**.

## 5. OBSCURE / scientific domains: research-first, then activate a dormant skill
1. **`deep-research`** — find SOTA, standard benchmarks, leakage traps, and the canonical metric for THIS domain before inventing one. Adapt the field's known-good recipe. **Trust but verify:** run the researched recipe through the §1 leakage/contamination check too — published pipelines leak.
2. **Activate a dormant scientific skill.** The library at `vendor/scientific-agent-skills/skills/` holds **147** domain skills costing 0 tokens until symlinked. Tell the user to symlink the match into BOTH config dirs, then **deactivate after the task** to reclaim the shared ~8k-char description budget:
   ```
   ln -sfn /home/ysh/Desktop/Obsidian/Prompts/Claude/vendor/scientific-agent-skills/skills/<name> ~/.claude-work/skills/<name>
   ln -sfn /home/ysh/Desktop/Obsidian/Prompts/Claude/vendor/scientific-agent-skills/skills/<name> ~/.claude-personal/skills/<name>
   ```
   Routing map (all names verified present):
   - **Single-cell / omics:** scanpy, anndata, scvi-tools, scvelo, cellxgene-census, pydeseq2, bulk-rnaseq, pathway-enrichment. Batch correction = Harmony/Combat/scVI integration, not just "detect."
   - **Sequence / genomics:** biopython, pysam, scikit-bio, phylogenetics, gget, tiledbvcf.
   - **Proteins / structure:** esm (protein LM), diffdock (docking).
   - **Cheminformatics / drug:** rdkit, datamol, molfeat, medchem, deepchem (general), torchdrug (GNN-drug), pytdc (benchmarks).
   - **Mass-spec / metabolomics:** pyopenms, matchms.
   - **Clinical / health / imaging:** pyhealth, scikit-survival, clinical-decision-support, neurokit2, pydicom, histolab, pathml. (Imaging: tile/patch vs slide is the independence unit; stain-normalize; watch magnification leakage.)
   - **Materials / quantum:** pymatgen, qiskit, pennylane.
   - **Stats helpers:** statistical-analysis (test selection), statistical-power, experimental-design.
3. No skill fits → implement from researched SOTA, still obeying §1–§3.

## 6. NLP/LLM-specific eval pitfalls
- **Contamination:** train/test overlap with the pretraining corpus — a "high score" may be memorization. Check for benchmark leakage.
- **Prompt sensitivity** is variance — report across prompt variants, not one lucky template.
- **LLM-as-judge bias** (position, verbosity, self-preference) — don't treat a judge score as ground truth.
- **n-gram metrics (BLEU/ROUGE) are blind to meaning** — pair with semantic/human eval.
- **Generative tasks:** evaluate faithfulness/groundedness (hallucination), not just accuracy.

## 7. Iterate with discipline
- **Error analysis over metric-chasing:** pull worst predictions, find the pattern (a slice, label-noise cluster, shift). Fix the data/feature, not just hyperparameters.
- **Ablations:** one change at a time; attribute each gain. Unattributed gains are future regressions.
- **Reproducibility:** seed numpy/torch/cuda + `deterministic=True`, `cudnn.benchmark=False` (note throughput cost); other nondeterminism = dataloader worker order, dict/set ordering, parallel/atomic reductions. Pin env (lockfile), hash input data, log configs+scores. A result you can't reproduce isn't a result.
- **Budget compute:** validate the pipeline end-to-end on a subsample / few epochs BEFORE scaling (route scale-up through **optimize-for-gpu**). Stopping rule so you don't over-invest past the acceptance bar.

## 8. Freelance deliverable discipline
Ship like a senior who'll be audited:
- **Reproducible** script/notebook: clone → run → same number (per §7). No hidden manual steps.
- **Documented assumptions** from §1: leakage checks done, splits chosen, units handled.
- **Honest eval:** correct metric with variance, on a sealed held-out test, vs the baseline. State what the model can't do.
- **Cost as a first-class metric** for deployable tasks: latency, model size, $/prediction — a senior is audited on these too.
- **Pre-ship scan:** run **verify-security** over the deliverable for hardcoded secrets / data leaks before handing off.
- **Limitations + next steps:** shift risk, label-noise ceiling, where it fails in production. Underclaim, overdeliver — a leak surfaces on the client's data.

## Anti-patterns (instant red flags)
Deep model before baseline · random KFold on grouped/temporal data · resampling before the split · tuning or thresholding on test · a "suspiciously predictive" feature · reinventing a metric the field already standardized · no variance / single-seed claim · can't reproduce the score.
