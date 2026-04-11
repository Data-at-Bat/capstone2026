"""score games with a trained model; merge odds; write slim predictions + edge."""

from __future__ import annotations

import json
import sys
from datetime import date
from pathlib import Path

import joblib
import numpy as np
import pandas as pd

_ML_ROOT = Path(__file__).resolve().parent.parent.parent
if str(_ML_ROOT) not in sys.path:
    sys.path.insert(0, str(_ML_ROOT))

from models.lightgbm_v1.train import (  # noqa: E402
    DEFAULT_UNIFIED_PATH,
    FEATURE_NAMES_PATH,
    MODEL_PATH,
    align_X,
)

ML_PIPELINE_ROOT = Path(__file__).resolve().parent.parent.parent
DEFAULT_PROCESSED = ML_PIPELINE_ROOT / "data" / "processed"
DEFAULT_ODDS_PATH = DEFAULT_PROCESSED / "odds_features.csv"
DEFAULT_PREDICTIONS_PATH = DEFAULT_PROCESSED / "predictions.csv"
DEFAULT_UPCOMING_WITH_ODDS = DEFAULT_PROCESSED / "upcoming_games_with_odds.csv"

ODDS_MERGE_COLS = [
    "home_moneyline",
    "away_moneyline",
    "home_implied_prob",
    "away_implied_prob",
]

# Home-centric edge: model P(home win) minus market home implied (away edge = 1 - p - away_implied)
SLIM_COLUMNS = [
    "game_id",
    "date",
    "home_team",
    "away_team",
    "home_moneyline",
    "away_moneyline",
    "home_implied_prob",
    "away_implied_prob",
    "edge",
]


def load_feature_names(path: Path | None = None) -> list[str]:
    p = path or FEATURE_NAMES_PATH
    if not p.is_file():
        raise FileNotFoundError(
            f"Feature list not found at {p}. Run training first (run_pipeline train)."
        )
    return json.loads(p.read_text(encoding="utf-8"))


def load_model(path: Path | None = None):
    p = path or MODEL_PATH
    if not p.is_file():
        raise FileNotFoundError(
            f"Model not found at {p}. Run training first (run_pipeline train)."
        )
    return joblib.load(p)


def _merge_odds_from_file(df: pd.DataFrame, odds_p: Path) -> pd.DataFrame:
    """Attach odds by ``game_id``; skip columns already fully populated on ``df``."""
    if not odds_p.is_file():
        return df
    odds_cols_present = [c for c in ODDS_MERGE_COLS if c in df.columns]
    if odds_cols_present and all(df[c].notna().all() for c in odds_cols_present):
        print("Odds already present on all rows; skipping odds file merge")
        return df
    odds = pd.read_csv(odds_p)
    use_cols = ["game_id"] + [c for c in ODDS_MERGE_COLS if c in odds.columns]
    odds = odds[[c for c in use_cols if c in odds.columns]].drop_duplicates(
        subset=["game_id"], keep="last"
    )
    out = df.merge(odds, on="game_id", how="left", suffixes=("", "_odds"))
    for c in ODDS_MERGE_COLS:
        alt = f"{c}_odds"
        if alt in out.columns:
            if c in out.columns:
                out[c] = out[c].combine_first(out[alt])
            else:
                out[c] = out[alt]
            out = out.drop(columns=[alt])
    n = out["home_implied_prob"].notna().sum() if "home_implied_prob" in out.columns else 0
    print(f"Merged odds from file: {n} / {len(out)} rows with home_implied_prob")
    return out


def _odds_incomplete(df: pd.DataFrame) -> bool:
    if "home_implied_prob" not in df.columns:
        return True
    return bool(df["home_implied_prob"].isna().any())


def _attach_odds(df: pd.DataFrame, odds_p: Path) -> pd.DataFrame:
    out = _merge_odds_from_file(df, odds_p)
    if not _odds_incomplete(out):
        return out
    try:
        from data.fetch.odds import merge_odds_api_onto_games

        out = merge_odds_api_onto_games(out)
        n = out["home_implied_prob"].notna().sum() if "home_implied_prob" in out.columns else 0
        print(f"Live odds API: {n} / {len(out)} rows with lines")
    except ValueError as e:
        print(f"Odds API skipped: {e}")
    except Exception as e:
        print(f"Odds API failed: {e}")
    if _odds_incomplete(out):
        print(
            "Warning: some games still missing implied probs "
            "(add odds_features.csv or set THE_ODDS_API_KEY)."
        )
    return out


def _compute_edges(df: pd.DataFrame) -> pd.DataFrame:
    out = df.copy()
    if "home_implied_prob" in out.columns:
        out["edge"] = out["predicted_home_win_prob"] - out["home_implied_prob"]
    else:
        out["edge"] = np.nan
    return out


def _build_slim_table(df: pd.DataFrame) -> pd.DataFrame:
    slim = pd.DataFrame()
    for c in SLIM_COLUMNS:
        if c in df.columns:
            slim[c] = df[c]
        else:
            slim[c] = np.nan
    slim["date"] = pd.to_datetime(slim["date"]).dt.strftime("%Y-%m-%d")
    for c in ("home_moneyline", "away_moneyline"):
        if c in slim.columns:
            slim[c] = pd.to_numeric(slim[c], errors="coerce")
    return slim


def _print_predictions(slim: pd.DataFrame) -> None:
    if slim.empty:
        print("(no rows)")
        return
    with pd.option_context("display.max_rows", 200, "display.width", 200, "display.max_columns", 20):
        print(slim.to_string(index=False))


def run_predict(
    unified_path: Path | None = None,
    odds_path: Path | None = None,
    output_path: Path | None = None,
    *,
    model_path: Path | None = None,
    feature_names_path: Path | None = None,
    season: int | None = None,
    upcoming_season: int | None = None,
    upcoming_csv: Path | None = None,
    prefer_upcoming_file: bool = True,
    predict_date: date | None = None,
) -> Path:
    """
    If ``season`` is set: historical mode — load ``unified_all`` (or ``unified_path``), filter
    to that season, merge odds from file, predict, write slim CSV + print.

    If ``season`` is None: upcoming mode — games on ``predict_date`` (default today), merge odds
    (CSV then live API if needed), predict, write slim CSV + print.
    """
    odds_p = Path(odds_path) if odds_path else DEFAULT_ODDS_PATH
    out = output_path or DEFAULT_PREDICTIONS_PATH

    feature_names = load_feature_names(feature_names_path)
    model = load_model(model_path)

    if season is not None:
        uni = Path(unified_path) if unified_path else DEFAULT_UNIFIED_PATH
        df = pd.read_csv(uni)
        df["date"] = pd.to_datetime(df["date"])
        df = df[df["season"] == season].copy()
        print(f"Historical mode: season={season}, {len(df)} rows from {uni}")
        df = _attach_odds(df, odds_p)
    else:
        from data.upcoming_infer import build_upcoming_inference_frame

        slate_day = predict_date if predict_date is not None else date.today()
        print(f"Upcoming mode: slate date {slate_day}")

        schedule_df = None
        if upcoming_csv is not None:
            schedule_df = pd.read_csv(Path(upcoming_csv))
            print(f"Upcoming mode: using schedule/spine from {upcoming_csv}")
        elif prefer_upcoming_file and DEFAULT_UPCOMING_WITH_ODDS.is_file():
            schedule_df = pd.read_csv(DEFAULT_UPCOMING_WITH_ODDS)
            print(
                f"Upcoming mode: using {DEFAULT_UPCOMING_WITH_ODDS.name} "
                "(from build_upcoming); refresh that file if the slate is stale"
            )
        else:
            print("Upcoming mode: no upcoming_games_with_odds.csv; fetching schedule from API ...")

        print("Building team / pitcher features for slate ...")
        df = build_upcoming_inference_frame(
            season=upcoming_season,
            schedule=schedule_df,
            on_date=slate_day,
        )
        if df.empty:
            slim = _build_slim_table(df)
            out = Path(out)
            out.parent.mkdir(parents=True, exist_ok=True)
            slim.to_csv(out, index=False)
            print(f"Saved empty predictions to {out}")
            _print_predictions(slim)
            return out
        df = _attach_odds(df, odds_p)

    df = df.copy()
    X = align_X(df, feature_names)
    df["predicted_home_win_prob"] = model.predict_proba(X)[:, 1]
    df = _compute_edges(df)

    slim = _build_slim_table(df)
    out = Path(out)
    out.parent.mkdir(parents=True, exist_ok=True)
    slim.to_csv(out, index=False)
    print(f"Saved predictions to {out} ({len(slim)} rows)\n")
    _print_predictions(slim)
    return out


if __name__ == "__main__":
    run_predict()
