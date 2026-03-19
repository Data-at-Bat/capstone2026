from __future__ import annotations

import pandas as pd


# Batting: counting cols that get cumulatively summed
_BAT_SUM = ["runs", "hits", "homeRuns", "baseOnBalls", "strikeOuts",
            "plateAppearances", "atBats", "doubles", "triples",
            "rbi", "stolenBases", "hitByPitch"]

# Pitching: counting cols that get cumulatively summed
_PIT_SUM = ["inningsPitched", "hits", "runs", "earnedRuns",
            "baseOnBalls", "strikeOuts", "homeRuns", "battersFaced"]


def compute_cumulative_batting(game_logs: pd.DataFrame) -> pd.DataFrame:
    """Compute cumulative batting stats **entering** each game."""
    df = game_logs.sort_values(["Team", "date"]).copy()

    grouped = df.groupby("Team")

    # Cumulative sums, shifted by 1 so game N sees games 1..N-1
    for col in _BAT_SUM:
        df[f"cum_{col}"] = grouped[col].cumsum().groupby(df["Team"]).shift(1)

    # Games played entering this game
    df["cum_games"] = grouped.cumcount()

    # Derived rate stats from cumulative counting stats
    df["batting_AVG"] = df["cum_hits"] / df["cum_atBats"]
    df["batting_OBP"] = (
        (df["cum_hits"] + df["cum_baseOnBalls"] + df["cum_hitByPitch"])
        / df["cum_plateAppearances"]
    )
    tb = (df["cum_hits"]
          + df["cum_doubles"]
          + 2 * df["cum_triples"]
          + 3 * df["cum_homeRuns"])
    df["batting_SLG"] = tb / df["cum_atBats"]
    df["batting_OPS"] = df["batting_OBP"] + df["batting_SLG"]

    # Per-game averages for counting stats
    safe_games = df["cum_games"].replace(0, float("nan"))
    df["batting_R_per_game"] = df["cum_runs"] / safe_games
    df["batting_HR_per_game"] = df["cum_homeRuns"] / safe_games
    df["batting_BB_per_game"] = df["cum_baseOnBalls"] / safe_games
    df["batting_SO_per_game"] = df["cum_strikeOuts"] / safe_games
    df["batting_SB_per_game"] = df["cum_stolenBases"] / safe_games

    # Strikeout & walk rates
    df["batting_K_pct"] = df["cum_strikeOuts"] / df["cum_plateAppearances"]
    df["batting_BB_pct"] = df["cum_baseOnBalls"] / df["cum_plateAppearances"]

    # Drop intermediate cumulative columns
    df = df.drop(columns=[c for c in df.columns if c.startswith("cum_")])

    return df


def compute_cumulative_pitching(game_logs: pd.DataFrame) -> pd.DataFrame:
    """Compute cumulative pitching stats **entering** each game."""
    df = game_logs.sort_values(["Team", "date"]).copy()

    grouped = df.groupby("Team")

    for col in _PIT_SUM:
        df[f"cum_{col}"] = grouped[col].cumsum().groupby(df["Team"]).shift(1)

    df["cum_games"] = grouped.cumcount()

    # Derived cumulative rate stats
    safe_ip = df["cum_inningsPitched"].replace(0, float("nan"))

    df["pitching_ERA"] = 9.0 * df["cum_earnedRuns"] / safe_ip
    df["pitching_WHIP"] = (df["cum_hits"] + df["cum_baseOnBalls"]) / safe_ip
    df["pitching_K_per_9"] = 9.0 * df["cum_strikeOuts"] / safe_ip
    df["pitching_BB_per_9"] = 9.0 * df["cum_baseOnBalls"] / safe_ip
    df["pitching_HR_per_9"] = 9.0 * df["cum_homeRuns"] / safe_ip
    df["pitching_H_per_9"] = 9.0 * df["cum_hits"] / safe_ip

    safe_bf = df["cum_battersFaced"].replace(0, float("nan"))
    df["pitching_K_pct"] = df["cum_strikeOuts"] / safe_bf
    df["pitching_BB_pct"] = df["cum_baseOnBalls"] / safe_bf

    # Per-game averages
    safe_games = df["cum_games"].replace(0, float("nan"))
    df["pitching_R_per_game"] = df["cum_runs"] / safe_games
    df["pitching_SO_per_game"] = df["cum_strikeOuts"] / safe_games

    df = df.drop(columns=[c for c in df.columns if c.startswith("cum_")])

    return df


def build_team_features(
    batting_logs: pd.DataFrame,
    pitching_logs: pd.DataFrame,
    min_games: int = 10,
) -> pd.DataFrame:
    """Build unified per-game team features from game-level logs."""
    bat = compute_cumulative_batting(batting_logs)
    pit = compute_cumulative_pitching(pitching_logs)

    # Keep only the feature columns from each
    bat_feature_cols = [c for c in bat.columns if c.startswith("batting_")]
    pit_feature_cols = [c for c in pit.columns if c.startswith("pitching_")]

    bat_slim = bat[["Team", "date", "game_id"] + bat_feature_cols].copy()
    pit_slim = pit[["Team", "date", "game_id"] + pit_feature_cols].copy()

    merged = bat_slim.merge(pit_slim, on=["Team", "date", "game_id"], how="outer")

    # Drop warm-up games where cumulative stats are unreliable
    if min_games > 0:
        game_num = merged.groupby("Team").cumcount()
        merged = merged[game_num >= min_games].copy()

    return merged
