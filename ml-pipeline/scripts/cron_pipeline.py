#!/usr/bin/env python3
"""Daily CRON entry point: predict today's games and POST to the Spring Boot API."""

from __future__ import annotations

import json
import sys
from datetime import date
from pathlib import Path

import pandas as pd
import requests

_ML_ROOT = Path(__file__).resolve().parent.parent
if str(_ML_ROOT) not in sys.path:
    sys.path.insert(0, str(_ML_ROOT))

from data.upcoming_infer import build_upcoming_inference_frame
from models.lightgbm_v1.predict import (
    _attach_odds,
    _build_slim_table,
    _compute_edges,
    _print_predictions,
    load_feature_names,
    load_model,
    DEFAULT_ODDS_PATH,
    DEFAULT_PREDICTIONS_PATH,
)
from models.lightgbm_v1.train import align_X

# ── API configuration ──────────────────────────────────────────────
API_URL = "http://dataatbat.hopto.org:8080/games?batch=true"


def predict_today() -> pd.DataFrame:
    """Build features for today's games, run model, return full DataFrame."""
    today = date.today()
    print(f"=== Daily Pipeline: {today} ===\n")

    df = build_upcoming_inference_frame(on_date=today)
    if df.empty:
        print("No games scheduled today.")
        return df

    df = _attach_odds(df, DEFAULT_ODDS_PATH)

    feature_names = load_feature_names()
    model = load_model()
    X = align_X(df, feature_names)
    df["predicted_home_win_prob"] = model.predict_proba(X)[:, 1]
    df = _compute_edges(df)

    # save slim predictions CSV
    slim = _build_slim_table(df)
    DEFAULT_PREDICTIONS_PATH.parent.mkdir(parents=True, exist_ok=True)
    slim.to_csv(DEFAULT_PREDICTIONS_PATH, index=False)
    print(f"\nSaved predictions to {DEFAULT_PREDICTIONS_PATH} ({len(slim)} rows)\n")
    _print_predictions(slim)

    return df


def push_to_api(df: pd.DataFrame) -> None:
    """Format prediction rows as GameEntity JSON and POST batch to the API."""
    payload = []
    for _, row in df.iterrows():
        model_prob = float(row.get("predicted_home_win_prob", 0.5))

        if model_prob >= 0.50:
            predicted_winner = str(row["home_team"])
            confidence = round(model_prob * 100, 1)
            odds = float(row.get("home_moneyline", 0.0) or 0.0)
        else:
            predicted_winner = str(row["away_team"])
            confidence = round((1.0 - model_prob) * 100, 1)
            odds = float(row.get("away_moneyline", 0.0) or 0.0)

        raw_time = row.get("game_time_utc")
        if pd.isna(raw_time) or raw_time == "":
            game_time = f"{row.get('date', '2026-01-01')}T00:00:00"
        else:
            game_time = str(raw_time).replace("Z", "")

        factors = {
            "edge": float(row.get("edge", 0.0) or 0.0),
            "home_implied_prob": float(row.get("home_implied_prob", 0.0) or 0.0),
            "away_implied_prob": float(row.get("away_implied_prob", 0.0) or 0.0),
        }

        payload.append({
            "gameTime": game_time,
            "homeTeamId": str(row["home_team_id"]),
            "awayTeamId": str(row["away_team_id"]),
            "homeTeamName": str(row["home_team"]),
            "awayTeamName": str(row["away_team"]),
            "predictedWinner": predicted_winner,
            "confidence": confidence,
            "spread": 0.0,
            "odds": odds,
            "predictiveFactors": json.dumps(factors),
        })

    print(f"\nSending {len(payload)} predictions to {API_URL} ...")
    try:
        resp = requests.post(API_URL, json=payload, headers={"Content-Type": "application/json"})
        if resp.status_code in (200, 201):
            print("Success — saved to database.")
        else:
            print(f"API returned {resp.status_code}: {resp.text}")
    except requests.exceptions.RequestException as e:
        print(f"API connection error: {e}")


def main():
    df = predict_today()
    if df.empty:
        return
    push_to_api(df)
    print("\nDaily pipeline complete.")


if __name__ == "__main__":
    main()
