"""build model-ready rows for scheduled  games using stats entering each game."""

from __future__ import annotations

from datetime import date

import pandas as pd

from config.team_mapping import MLB_NAME_TO_FG
from data.build_upcoming import filter_non_final_games
from data.fetch.game_logs import fetch_all_team_logs
from data.fetch.pitcher_stats import fetch_pitcher_season_stats
from data.fetch.schedule import fetch_schedule
from features.team_stats import build_team_features

def infer_mlb_season(reference: date | None = None) -> int:
    """Calendar year used as MLB API ``season`` (good enough for fetch_all_team_logs)."""
    return (reference or date.today()).year


def _merge_asof_side(
    games: pd.DataFrame,
    team_features: pd.DataFrame,
    team_col: str,
    prefix: str,
) -> pd.DataFrame:
    """Attach latest team feature row at or before each game's ``date`` (per-team merge_asof)."""
    feat_cols = [c for c in team_features.columns if c not in ("Team", "date", "game_id")]
    chunks: list[pd.DataFrame] = []
    for team in games[team_col].dropna().unique():
        u = games.loc[games[team_col] == team].sort_values("date").copy()
        tf = team_features.loc[team_features["Team"] == team, ["date"] + feat_cols].sort_values(
            "date"
        )
        tf = tf.rename(columns={c: f"{prefix}{c}" for c in feat_cols})
        m = pd.merge_asof(u, tf, on="date", direction="backward")
        chunks.append(m)
    if not chunks:
        return games.iloc[:0].copy()
    return pd.concat(chunks, ignore_index=True)


def build_upcoming_inference_frame(
    season: int | None = None,
    min_games: int = 10,
    *,
    start_date: str | None = None,
    end_date: str | None = None,
    schedule: pd.DataFrame | None = None,
    on_date: date | None = None,
) -> pd.DataFrame:
    """
    Non-final games from schedule + team features (as-of prior games) + pitcher priors.

    Odds are merged in ``predict.run_predict`` (file and/or live API).

    If ``on_date`` is set, only that calendar day is kept (and schedule fetch is narrowed to
    that day when ``schedule`` is None).

    If ``schedule`` is None, fetches from StatsAPI from ``start_date`` through ``end_date``.
    """
    season = season if season is not None else infer_mlb_season(on_date or date.today())
    if schedule is None:
        if on_date is not None:
            day = on_date.isoformat()
            start = start_date or day
            end = end_date or day
        else:
            start = start_date or date.today().isoformat()
            end = end_date or f"{season}-11-30"
        print(f"Fetching schedule {start} .. {end} ...")
        schedule = fetch_schedule(start, end)

    games = filter_non_final_games(schedule.copy())
    games["date"] = pd.to_datetime(games["date"])
    if on_date is not None:
        games = games[games["date"].dt.date == on_date].copy()
        print(f"Filtered to game date {on_date}: {len(games)} games (non-final)")

    games["home_team_fg"] = games["home_team"].map(MLB_NAME_TO_FG)
    games["away_team_fg"] = games["away_team"].map(MLB_NAME_TO_FG)
    unmapped = games[games["home_team_fg"].isna() | games["away_team_fg"].isna()]
    if not unmapped.empty:
        print(f"Warning: dropping {len(unmapped)} game(s) with unmapped team names: {unmapped['home_team'].tolist()} vs {unmapped['away_team'].tolist()}")
    games = games.dropna(subset=["home_team_fg", "away_team_fg"])
    games["season"] = season

    if games.empty:
        print("No non-final games with mapped team abbreviations.")
        return games

    print(f"Building features for {len(games)} game(s)")
    print(f"Fetching team logs for season {season} ...")
    batting_logs, pitching_logs = fetch_all_team_logs(season)
    team_features = build_team_features(batting_logs, pitching_logs, min_games=min_games)
    team_features["date"] = pd.to_datetime(team_features["date"])

    games = _merge_asof_side(games, team_features, "home_team_fg", "home_")
    games = _merge_asof_side(games, team_features, "away_team_fg", "away_")
    games = games.sort_values("game_id").reset_index(drop=True)

    pitcher_ids = (
        pd.concat([games["home_pitcher_id"], games["away_pitcher_id"]])
        .dropna()
        .astype(int)
        .unique()
        .tolist()
    )
    if pitcher_ids:
        print(f"Fetching prior-season pitcher stats ({season - 1}) ...")
        pitcher_stats = fetch_pitcher_season_stats(pitcher_ids, season - 1)
        home_cols = {c: f"home_{c}" for c in pitcher_stats.columns if c != "pitcher_id"}
        games = games.merge(
            pitcher_stats.rename(columns=home_cols),
            left_on="home_pitcher_id",
            right_on="pitcher_id",
            how="left",
        ).drop(columns=["pitcher_id"])
        away_cols = {c: f"away_{c}" for c in pitcher_stats.columns if c != "pitcher_id"}
        games = games.merge(
            pitcher_stats.rename(columns=away_cols),
            left_on="away_pitcher_id",
            right_on="pitcher_id",
            how="left",
        ).drop(columns=["pitcher_id"])

    return games
