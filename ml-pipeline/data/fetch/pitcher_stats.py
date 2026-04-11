from __future__ import annotations

import time

import pandas as pd
import requests

_BASE_URL = "https://statsapi.mlb.com/api/v1/people/{pid}/stats"


def _safe_float(val) -> float:
    """Convert MLB stat value to float; returns NaN for missing or placeholder values like '-.--'."""
    if val is None:
        return float("nan")
    try:
        return float(val)
    except (ValueError, TypeError):
        return float("nan")


def _fetch_pitcher_stats(pitcher_id: int, season: int) -> dict | None:
    """Return raw stat dict for one pitcher-season, or None if unavailable."""
    url = _BASE_URL.format(pid=pitcher_id)
    params = {"stats": "season", "season": season, "group": "pitching"}
    resp = requests.get(url, params=params, timeout=30)
    resp.raise_for_status()
    stats = resp.json().get("stats", [])
    if not stats:
        return None
    splits = stats[0].get("splits", [])
    if not splits:
        return None
    return splits[0]["stat"]


def fetch_pitcher_season_stats(
    pitcher_ids: list[int],
    season: int,
    sleep: float = 0.1,
) -> pd.DataFrame:
    """Return prior-season ERA/WHIP/K_per_9/BB_per_9/IP for a list of pitchers.

    Pitchers with no data for the given season are omitted (NaN after join).
    """
    rows = []
    for i, pid in enumerate(pitcher_ids):
        stat = _fetch_pitcher_stats(pid, season)
        if stat is not None:
            ip_raw = stat.get("inningsPitched", "0")
            ip = _parse_ip(ip_raw)
            rows.append({
                "pitcher_id": pid,
                "pitcher_ERA": _safe_float(stat.get("era")),
                "pitcher_WHIP": _safe_float(stat.get("whip")),
                "pitcher_K_per_9": _safe_float(stat.get("strikeoutsPer9Inn")),
                "pitcher_BB_per_9": _safe_float(stat.get("walksPer9Inn")),
                "pitcher_IP": ip,
            })
        if sleep and i < len(pitcher_ids) - 1:
            time.sleep(sleep)

    return pd.DataFrame(rows) if rows else pd.DataFrame(
        columns=["pitcher_id", "pitcher_ERA", "pitcher_WHIP",
                 "pitcher_K_per_9", "pitcher_BB_per_9", "pitcher_IP"]
    )


def _parse_ip(ip_str: str) -> float:
    """Convert MLB-style IP string ('6.1' = 6⅓) to true decimal innings."""
    parts = str(ip_str).split(".")
    whole = int(parts[0])
    if len(parts) > 1:
        thirds = int(parts[1])
        return whole + thirds / 3.0
    return float(whole)
