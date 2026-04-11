"""Live MLB moneylines from The Odds API"""

from __future__ import annotations

import os
from typing import Any

import pandas as pd
import requests

ODDS_API_URL = "https://api.the-odds-api.com/v4/sports/baseball_mlb/odds"


def american_to_implied_prob(american: float) -> float:
    if american > 0:
        return 100 / (american + 100)
    return -american / (-american + 100)


def _best_prices_for_game(
    game: dict[str, Any],
) -> tuple[float | None, float | None, float | None, float | None]:
    """Return (best_home_ml, best_away_ml, home_spread_point, away_spread_point)."""
    home_team = game["home_team"]
    away_team = game["away_team"]
    best_home: float | None = None
    best_away: float | None = None
    home_spread: float | None = None
    away_spread: float | None = None
    for bookmaker in game.get("bookmakers", []):
        for market in bookmaker.get("markets", []):
            key = market.get("key")
            for outcome in market.get("outcomes", []):
                name = outcome["name"]
                if key == "h2h":
                    price = float(outcome["price"])
                    if name == home_team:
                        best_home = max(best_home, price) if best_home is not None else price
                    elif name == away_team:
                        best_away = max(best_away, price) if best_away is not None else price
                elif key == "spreads":
                    point = outcome.get("point")
                    if point is not None:
                        point = float(point)
                        if name == home_team and home_spread is None:
                            home_spread = point
                        elif name == away_team and away_spread is None:
                            away_spread = point
    return best_home, best_away, home_spread, away_spread


def fetch_mlb_odds_wide(api_key: str | None = None) -> pd.DataFrame:
    """
    One row per game: best US h2h price per side + implied probs.

    API key: ``THE_ODDS_API_KEY`` or ``ODDS_API_KEY`` env var if ``api_key`` is None.
    """
    key = api_key or os.environ.get("THE_ODDS_API_KEY") or os.environ.get("ODDS_API_KEY")
    if not key:
        raise ValueError(
            "No Odds API key: set environment variable THE_ODDS_API_KEY or ODDS_API_KEY."
        )
    resp = requests.get(
        ODDS_API_URL,
        params={
            "apiKey": key,
            "regions": "us",
            "markets": "h2h,spreads",
            "oddsFormat": "american",
        },
        timeout=45,
    )
    resp.raise_for_status()
    data = resp.json()
    rows: list[dict] = []
    for g in data:
        bh, ba, hs, as_ = _best_prices_for_game(g)
        if bh is None or ba is None:
            continue
        rows.append(
            {
                "home_team": g["home_team"],
                "away_team": g["away_team"],
                "commence_time": g["commence_time"],
                "home_moneyline": bh,
                "away_moneyline": ba,
                "home_implied_prob": american_to_implied_prob(bh),
                "away_implied_prob": american_to_implied_prob(ba),
                "home_spread": hs,
                "away_spread": as_,
            }
        )
    return pd.DataFrame(rows)


def add_event_dates_eastern(wide: pd.DataFrame) -> pd.DataFrame:
    """Match MLB schedule ``date`` (US game day) using Eastern time from ``commence_time``."""
    out = wide.copy()
    ts = pd.to_datetime(out["commence_time"], utc=True).dt.tz_convert("America/New_York")
    out["game_date"] = ts.dt.date
    return out


def merge_odds_api_onto_games(games: pd.DataFrame, api_key: str | None = None) -> pd.DataFrame:
    """
    Left-merge live odds onto MLB rows keyed by ``home_team``, ``away_team``, calendar date.

    Fills missing ``home_moneyline`` / implied columns where the API has a match.
    """
    wide = fetch_mlb_odds_wide(api_key=api_key)
    if wide.empty:
        return games
    wide = add_event_dates_eastern(wide)
    spread_cols = [c for c in ["home_spread", "away_spread"] if c in wide.columns]
    use = wide[
        [
            "home_team",
            "away_team",
            "game_date",
            "home_moneyline",
            "away_moneyline",
            "home_implied_prob",
            "away_implied_prob",
        ] + spread_cols
    ].drop_duplicates(subset=["home_team", "away_team", "game_date"], keep="first")

    g = games.copy()
    g["_game_date_key"] = pd.to_datetime(g["date"]).dt.date
    merged = g.merge(
        use,
        left_on=["home_team", "away_team", "_game_date_key"],
        right_on=["home_team", "away_team", "game_date"],
        how="left",
        suffixes=("", "_api"),
    )
    merged = merged.drop(columns=["_game_date_key", "game_date"], errors="ignore")

    unmatched = merged["home_moneyline"].isna().sum() if "home_moneyline" in merged.columns else 0
    if unmatched:
        print(f"Warning: {unmatched} game(s) could not be matched to live odds (team name mismatch?)")

    odds_cols = [
        "home_moneyline",
        "away_moneyline",
        "home_implied_prob",
        "away_implied_prob",
        "home_spread",
        "away_spread",
    ]
    for c in odds_cols:
        alt = f"{c}_api"
        if alt in merged.columns:
            if c in merged.columns:
                merged[c] = merged[c].combine_first(merged[alt])
            else:
                merged[c] = merged[alt]
            merged = merged.drop(columns=[alt], errors="ignore")

    return merged
