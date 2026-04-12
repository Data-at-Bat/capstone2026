LightGBM v1 — Model Notes
=========================

Hyperparameters (current)
  n_estimators  = 500
  learning_rate = 0.05
  num_leaves    = 31

Train/Test split
  Season-based chronological split:
    train: seasons <= 2022
    test:  seasons >= 2023
  Input: data/processed/unified_all.csv

Artifacts (gitignored, saved to artifacts/)
  artifacts/home_win_lgbm.joblib   — trained model
  artifacts/feature_names.json     — ordered feature list used at train time

Features
  Team form (leakage-aware, computed from games prior to each row):
    home_batting_*  / away_batting_*   — cumulative season batting stats
    home_pitching_* / away_pitching_*  — cumulative season pitching stats
    home_rolling_*  / away_rolling_*   — rolling N-game batting/pitching stats
  Pitcher priors (prior-season stats fetched by pitcher_id):
    home_era, home_whip / away_era, away_whip
    (missing values median-imputed)

Metrics printed at training
  - Accuracy
  - Log loss (primary signal quality metric)
  - Top 10 feature importances

Known caveats
  - LightGBM warns on sparse pitcher_id features; limited signal expected there.
  - Pitcher prior stats are from the previous season — no in-season update yet.
  - Edge thresholds in predict.py are for screening only, not staking logic.
  - Odds are merged at predict time (file then live API fallback); training does
    not use odds as features.
