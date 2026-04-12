# ml-pipeline

LightGBM model for predicting MLB home team win probability and estimating edge against sportsbook lines.

## Structure

```
ml-pipeline/
├── config/               # Team and player ID mappings
├── data/
│   ├── fetch/            # Individual data fetchers (schedule, odds, game results, etc.)
│   ├── build_dataset.py  # Builds historical training dataset (schedule + results)
│   ├── build_upcoming.py # Builds upcoming games dataset for inference
│   ├── unified_dataset.py# Merges multi-season data into unified_all.csv
│   └── upcoming_infer.py # Builds feature-ready rows for today's slate
├── features/
│   └── team_stats.py     # Cumulative + rolling team batting/pitching features
├── models/
│   └── lightgbm_v1/
│       ├── train.py      # Train model on unified_all.csv
│       ├── predict.py    # Score upcoming games, merge odds, compute edge
│       └── artifacts/    # Saved model + feature list (gitignored)
├── scripts/
│   └── cron_pipeline.py  # Daily CRON entry point: predict + POST to API
├── run_pipeline.py       # CLI orchestrator (build / train / predict / full)
└── tests/
```

## Quick Start

All commands run from the `ml-pipeline/` directory with the virtualenv active.

**Build historical dataset** (fetches game logs, writes `data/processed/unified_all.csv`):
```bash
python run_pipeline.py build --start-season 2015 --end-season 2024
```

**Train the model** (reads `unified_all.csv`, saves artifacts to `models/lightgbm_v1/artifacts/`):
```bash
python run_pipeline.py train
```

**Predict today's games** (fetches live schedule + odds, writes `data/processed/predictions.csv`):
```bash
python run_pipeline.py predict
```

**Full pipeline** (build + train + predict):
```bash
python run_pipeline.py full --start-season 2015 --end-season 2024
```

**Daily CRON job** (predict today + POST batch to Spring Boot API):
```bash
python scripts/cron_pipeline.py
```

## Environment

Copy `.env.example` to `.env` and set:
```
THE_ODDS_API_KEY=your_key_here
```

Predictions fall back gracefully if no API key is set (edge column will be NaN without odds).
