#!/usr/bin/env python3
"""Daily CRON entry point: predict today's games and POST to the Spring Boot API."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pandas as pd
import requests
from dotenv import load_dotenv

_ML_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(_ML_ROOT / ".env")

if str(_ML_ROOT) not in sys.path:
    sys.path.insert(0, str(_ML_ROOT))

from models.lightgbm_v1.predict import run_predict  # noqa: E402

# ── API configuration ──────────────────────────────────────────────
API_URL = "http://dataatbat.hopto.org:8080/games?batch=true"


def push_to_api(df: pd.DataFrame) -> None:
    """Format prediction rows as GameEntity JSON and POST batch to the API."""
    # Only send games that have odds data
    odds_col = "home_moneyline"
    if odds_col in df.columns:
        has_odds = df[odds_col].notna()
        skipped = (~has_odds).sum()
        if skipped:
            print(f"Skipping {skipped} game(s) with no odds (lines not yet posted)")
        df = df[has_odds]

    payload = []
    for _, row in df.iterrows():
        model_prob = float(row.get("predicted_home_win_prob", 0.5))

        def _nullable(key):
            v = row.get(key)
            return None if pd.isna(v) else float(v)

        if model_prob >= 0.50:
            predicted_winner = str(row["home_team"])
            confidence = round(model_prob * 100, 1)
            odds = _nullable("home_moneyline")
            spread = _nullable("home_spread")
        else:
            predicted_winner = str(row["away_team"])
            confidence = round((1.0 - model_prob) * 100, 1)
            odds = _nullable("away_moneyline")
            spread = _nullable("away_spread")

        raw_time = row.get("game_time_utc")
        if pd.isna(raw_time) or raw_time == "":
            game_time = f"{row.get('date', '2026-01-01')}T00:00:00"
        else:
            game_time = str(raw_time).replace("Z", "")

        factors = {
            "edge": _nullable("edge"),
            "home_implied_prob": _nullable("home_implied_prob"),
            "away_implied_prob": _nullable("away_implied_prob"),
        }

        payload.append({
            "gameTime": game_time,
            "homeTeamId": str(row["home_team_id"]),
            "awayTeamId": str(row["away_team_id"]),
            "homeTeamName": str(row["home_team"]),
            "awayTeamName": str(row["away_team"]),
            "predictedWinner": predicted_winner,
            "confidence": confidence,
            "spread": spread,
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
    print(f"=== Daily Pipeline ===\n")
    _, df = run_predict(predict_days=7, prefer_upcoming_file=False)
    if df.empty:
        return
    push_to_api(df)
    print("\nDaily pipeline complete.")


if __name__ == "__main__":
    main()
