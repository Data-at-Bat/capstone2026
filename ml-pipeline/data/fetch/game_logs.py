from __future__ import annotations

import time
from pathlib import Path

import pandas as pd
import requests

from config.team_mapping import FG_TO_MLB_ID, MLB_ID_TO_FG

_BASE_URL = "https://statsapi.mlb.com/api/v1/teams/{team_id}/stats"

# Counting stats → will be cumulatively summed
BATTING_COUNT = ["runs", "hits", "homeRuns", "baseOnBalls", "strikeOuts",
                 "plateAppearances", "atBats", "doubles", "triples",
                 "rbi", "stolenBases", "hitByPitch"]

# Counting stats → will be cumulatively summed
PITCHING_COUNT = ["inningsPitched", "hits", "runs", "earnedRuns",
                  "baseOnBalls", "strikeOuts", "homeRuns",
                  "battersFaced"]


def _fetch_game_log(team_mlb_id: int, season: int, group: str) -> list[dict]:
    """Fetch raw game-log splits from the MLB Stats API."""
    params = {
        "stats": "gameLog",
        "season": season,
        "group": group,
        "gameType": "R",
    }
    url = _BASE_URL.format(team_id=team_mlb_id)
    resp = requests.get(url, params=params, timeout=30)
    resp.raise_for_status()
    stats = resp.json().get("stats", [])
    if not stats:
        return []
    return stats[0].get("splits", [])


def _parse_batting_splits(splits: list[dict], fg_abbr: str) -> pd.DataFrame:
    """Convert raw batting splits into a flat DataFrame."""
    rows = []
    for s in splits:
        stat = s["stat"]
        rows.append({
            "Team": fg_abbr,
            "date": s["date"],
            "game_id": s["game"]["gamePk"],
            **{col: stat.get(col, 0) for col in BATTING_COUNT},
        })
    return pd.DataFrame(rows)


def _parse_pitching_splits(splits: list[dict], fg_abbr: str) -> pd.DataFrame:
    """Convert raw pitching splits into a flat DataFrame."""
    rows = []
    for s in splits:
        stat = s["stat"]
        # inningsPitched comes as "6.1" (= 6⅓), convert to float
        ip_raw = stat.get("inningsPitched", "0")
        ip = _parse_ip(ip_raw)

        rows.append({
            "Team": fg_abbr,
            "date": s["date"],
            "game_id": s["game"]["gamePk"],
            "inningsPitched": ip,
            **{col: stat.get(col, 0) for col in PITCHING_COUNT
               if col != "inningsPitched"},
        })
    return pd.DataFrame(rows)


def _parse_ip(ip_str: str) -> float:
    """Convert MLB-style IP string ('6.1' = 6⅓) to true decimal innings."""
    parts = str(ip_str).split(".")
    whole = int(parts[0])
    if len(parts) > 1:
        thirds = int(parts[1])
        return whole + thirds / 3.0
    return float(whole)


def fetch_team_logs(
    season: int,
    fg_abbr: str,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Return (batting_logs, pitching_logs) DataFrames for one team-season."""
    mlb_id = FG_TO_MLB_ID[fg_abbr]
    bat_splits = _fetch_game_log(mlb_id, season, "hitting")
    pit_splits = _fetch_game_log(mlb_id, season, "pitching")
    batting = _parse_batting_splits(bat_splits, fg_abbr)
    pitching = _parse_pitching_splits(pit_splits, fg_abbr)
    return batting, pitching


def fetch_all_team_logs(
    season: int,
    sleep: float = 0.25,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Fetch batting + pitching game logs for all 30 teams in a season."""
    all_bat: list[pd.DataFrame] = []
    all_pit: list[pd.DataFrame] = []

    teams = sorted(FG_TO_MLB_ID.keys())
    for i, fg in enumerate(teams, 1):
        print(f"  [{i:2d}/30] Fetching game logs for {fg} {season}...")
        bat, pit = fetch_team_logs(season, fg)
        all_bat.append(bat)
        all_pit.append(pit)
        if sleep and i < len(teams):
            time.sleep(sleep)

    batting = pd.concat(all_bat, ignore_index=True)
    pitching = pd.concat(all_pit, ignore_index=True)

    batting["date"] = pd.to_datetime(batting["date"])
    pitching["date"] = pd.to_datetime(pitching["date"])

    return batting, pitching
