"""Train LightGBM home-win model; save model + feature list for prediction."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import joblib
import lightgbm as lgb
import numpy as np
import pandas as pd
from sklearn.metrics import accuracy_score, log_loss

ML_PIPELINE_ROOT = Path(__file__).resolve().parent.parent.parent
PROCESSED_DIR = ML_PIPELINE_ROOT / "data" / "processed"
ARTIFACT_DIR = Path(__file__).resolve().parent / "artifacts"

DEFAULT_UNIFIED_PATH = PROCESSED_DIR / "unified_all.csv"
MODEL_PATH = ARTIFACT_DIR / "home_win_lgbm.joblib"
FEATURE_NAMES_PATH = ARTIFACT_DIR / "feature_names.json"

TRAIN_END_SEASON = 2022
TEST_START_SEASON = 2023

DROP_COLS = [
    "game_id",
    "date",
    "season",
    "home_team",
    "away_team",
    "home_team_id",
    "away_team_id",
    "home_team_fg",
    "away_team_fg",
    "home_pitcher_id",
    "away_pitcher_id",
    "home_score",
    "away_score",
    "home_win",
]

BASE_FEATURE_COLUMNS = [
    "home_team_id",
    "away_team_id",
    "home_pitcher_id",
    "away_pitcher_id",
    "home_pitcher_era",
    "away_pitcher_era",
    "home_pitcher_whip",
    "away_pitcher_whip",
]

FULL_FEATURE_COLUMNS = BASE_FEATURE_COLUMNS + [
    "home_team_win_pct",
    "away_team_win_pct",
    "home_last10_win_pct",
    "away_last10_win_pct",
]

def load_unified(path: Path | None = None) -> pd.DataFrame:
    p = path or DEFAULT_UNIFIED_PATH
    df = pd.read_csv(p)
    df["date"] = pd.to_datetime(df["date"])
    return df


def prepare_features(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.Series]:
    X = df.drop(columns=[c for c in DROP_COLS if c in df.columns])
    y = df["home_win"]
    return X, y


def feature_columns_for_prediction(df: pd.DataFrame) -> list[str]:
    """Column names the model expects (same as training X)."""
    return [c for c in df.columns if c not in DROP_COLS]


def align_X(df: pd.DataFrame, feature_names: list[str]) -> pd.DataFrame:
    """Build X with the same columns as training; missing columns become NaN."""
    return pd.DataFrame(
        {c: df[c] if c in df.columns else np.nan for c in feature_names},
        index=df.index,
    )


def train(
    unified_path: Path | None = None,
    *,
    train_end_season: int = TRAIN_END_SEASON,
    test_start_season: int = TEST_START_SEASON,
    save: bool = True,
    model_path: Path | None = None,
    feature_names_path: Path | None = None,
) -> tuple[lgb.LGBMClassifier, dict]:
    df = load_unified(unified_path)

    train_mask = df["season"] <= train_end_season
    test_mask = df["season"] >= test_start_season

    train_df = df[train_mask].copy()
    test_df = df[test_mask].copy()

    print(f"Train: {len(train_df)} games (seasons <= {train_end_season})")
    print(f"Test:  {len(test_df)} games (seasons >= {test_start_season})")

    X_train, y_train = prepare_features(train_df)
    X_test, y_test = prepare_features(test_df)

    feature_names = list(X_train.columns)

    model = lgb.LGBMClassifier(
        n_estimators=500,
        learning_rate=0.05,
        num_leaves=31,
        verbose=-1,
    )
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]

    acc = accuracy_score(y_test, y_pred)
    ll = log_loss(y_test, y_prob)

    print(f"\nAccuracy: {acc:.4f}")
    print(f"Log-loss: {ll:.4f}")

    importances = pd.Series(
        model.feature_importances_, index=X_train.columns
    ).sort_values(ascending=False)
    print("\nTop 10 features:")
    for feat, imp in importances.head(10).items():
        print(f"  {feat:40s} {imp}")

    metrics = {"accuracy": acc, "log_loss": ll}

    if save:
        mp = model_path or MODEL_PATH
        fp = feature_names_path or FEATURE_NAMES_PATH
        mp.parent.mkdir(parents=True, exist_ok=True)
        joblib.dump(model, mp)
        fp.write_text(json.dumps(feature_names, indent=2), encoding="utf-8")
        print(f"\nSaved model to {mp}")
        print(f"Saved feature list ({len(feature_names)} cols) to {fp}")

    return model, metrics


def parse_args():
    parser = argparse.ArgumentParser(description="Train LightGBM MLB model.")
    parser.add_argument(
        "--feature-set",
        choices=["base8", "full12"],
        default="full12",
        help="base8: IDs + pitcher stats; full12: base8 + team form features",
    )
    parser.add_argument("--n-estimators", type=int, default=150)
    parser.add_argument("--num-leaves", type=int, default=15)
    parser.add_argument("--learning-rate", type=float, default=0.05)
    return parser.parse_args()

if __name__ == "__main__":
    train()
