"""Aggregate player-season FanGraphs data into one row per team per season."""

from __future__ import annotations

import pandas as pd


def aggregate_batting(batting_df: pd.DataFrame) -> pd.DataFrame:
    """Aggregate player batting stats to team-season level.

    Filters out traded-player combined lines (Team == "- - -"),
    sums counting stats, and computes PA-weighted rate stats.
    """
    df = batting_df[batting_df["Team"] != "- - -"].copy()

    sum_cols = ["WAR", "R", "HR", "RBI", "SB", "BB", "SO", "PA", "AB"]
    wavg_cols = ["AVG", "OBP", "SLG", "OPS", "wOBA", "wRC+"]
    weight_col = "PA"

    grouped = df.groupby(["Team", "Season"])

    sums = grouped[sum_cols].sum()

    def _weighted_avg(group: pd.DataFrame) -> pd.Series:
        w = group[weight_col]
        total = w.sum()
        if total == 0:
            return pd.Series({c: 0.0 for c in wavg_cols})
        return pd.Series({c: (group[c] * w).sum() / total for c in wavg_cols})

    wavgs = grouped.apply(_weighted_avg, include_groups=False)

    result = sums.join(wavgs)
    result = result.rename(columns={c: f"batting_{c}" for c in result.columns})
    return result.reset_index()


def aggregate_pitching(pitching_df: pd.DataFrame) -> pd.DataFrame:
    """Aggregate player pitching stats to team-season level.

    Filters out traded-player combined lines, sums counting stats,
    and computes TBF-weighted rate stats.
    """
    df = pitching_df[pitching_df["Team"] != "- - -"].copy()

    sum_cols = ["WAR", "W", "L", "SO", "BB", "HR", "ER", "IP", "TBF"]
    wavg_cols = ["ERA", "FIP", "WHIP", "K/9", "BB/9", "K%", "BB%"]
    weight_col = "TBF"

    grouped = df.groupby(["Team", "Season"])

    sums = grouped[sum_cols].sum()

    def _weighted_avg(group: pd.DataFrame) -> pd.Series:
        w = group[weight_col]
        total = w.sum()
        if total == 0:
            return pd.Series({c: 0.0 for c in wavg_cols})
        return pd.Series({c: (group[c] * w).sum() / total for c in wavg_cols})

    wavgs = grouped.apply(_weighted_avg, include_groups=False)

    result = sums.join(wavgs)
    result = result.rename(columns={c: f"pitching_{c}" for c in result.columns})
    return result.reset_index()


def build_team_features(
    batting_df: pd.DataFrame,
    pitching_df: pd.DataFrame,
) -> pd.DataFrame:
    """Build unified team-season feature table from raw player stats.

    Returns one row per team per season with all batting_ and pitching_ columns.
    """
    batting_agg = aggregate_batting(batting_df)
    pitching_agg = aggregate_pitching(pitching_df)

    return batting_agg.merge(pitching_agg, on=["Team", "Season"], how="outer")
