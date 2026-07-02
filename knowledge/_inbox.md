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
