from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd

from data.fetch.schedule import fetch_schedule
from data.fetch.game_results import fetch_game_results
from data.fetch.game_logs import fetch_all_team_logs
from data.fetch.pitcher_stats import fetch_pitcher_season_stats
from data.build_dataset import merge_data, clean_dataset
from features.team_stats import build_team_features

PROCESSED_DIR = Path(__file__).resolve().parent / "data" / "processed"


def build_season(season: int, min_games: int = 10) -> pd.DataFrame:
    """Build unified game-level dataset for a single season."""
    start = f"{season}-03-01"
    end = f"{season}-11-30"

    print(f"\n{'='*60}")
    print(f"  Processing season {season}")
    print(f"{'='*60}")

    # Game spine
    print("Fetching schedule...")
    schedule = fetch_schedule(start, end)
    print(f"  {len(schedule)} games in schedule")

    print("Fetching game results...")
    results = fetch_game_results(start, end)
    print(f"  {len(results)} game results")

    games = merge_data(schedule, results)
    games = clean_dataset(games)
    games["date"] = pd.to_datetime(games["date"])
    print(f"  {len(games)} games after merge+clean")

    # Per-game team logs from MLB Stats API
    print("Fetching team game logs (batting + pitching)...")
    batting_logs, pitching_logs = fetch_all_team_logs(season)

    print("Computing cumulative rolling features...")
    team_features = build_team_features(batting_logs, pitching_logs,
                                        min_games=min_games)
    print(f"  {len(team_features)} team-game rows after warm-up filter")

    # Join home team features
    home_features = team_features.copy()
    home_features = home_features.rename(
        columns={c: f"home_{c}" for c in home_features.columns
                 if c not in ("Team", "date", "game_id")}
    )
    games = games.merge(
        home_features,
        left_on=["home_team_fg", "date", "game_id"],
        right_on=["Team", "date", "game_id"],
        how="inner",
    ).drop(columns=["Team"])

    # Join away team features
    away_features = team_features.copy()
    away_features = away_features.rename(
        columns={c: f"away_{c}" for c in away_features.columns
                 if c not in ("Team", "date", "game_id")}
    )
    games = games.merge(
        away_features,
        left_on=["away_team_fg", "date", "game_id"],
        right_on=["Team", "date", "game_id"],
        how="inner",
    ).drop(columns=["Team"])

    # Pitcher features: join prior-season stats
    pitcher_ids = (
        pd.concat([games["home_pitcher_id"], games["away_pitcher_id"]])
        .dropna().astype(int).unique().tolist()
    )
    if pitcher_ids:
        print(f"Fetching prior-season pitcher stats ({season - 1})...")
        pitcher_stats = fetch_pitcher_season_stats(pitcher_ids, season - 1)

        home_cols = {c: f"home_{c}" for c in pitcher_stats.columns if c != "pitcher_id"}
        games = games.merge(
            pitcher_stats.rename(columns=home_cols),
            left_on="home_pitcher_id", right_on="pitcher_id", how="left",
        ).drop(columns=["pitcher_id"])

        away_cols = {c: f"away_{c}" for c in pitcher_stats.columns if c != "pitcher_id"}
        games = games.merge(
            pitcher_stats.rename(columns=away_cols),
            left_on="away_pitcher_id", right_on="pitcher_id", how="left",
        ).drop(columns=["pitcher_id"])

    print(f"  Final shape: {games.shape}")
    return games


def main() -> None:
    parser = argparse.ArgumentParser(description="Build unified MLB dataset")
    parser.add_argument("--start-season", type=int, default=2024)
    parser.add_argument("--end-season", type=int, default=2024)
    parser.add_argument("--min-games", type=int, default=10,
                        help="Drop first N games per team (warm-up period)")
    args = parser.parse_args()

    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    all_seasons = []

    for season in range(args.start_season, args.end_season + 1):
        df = build_season(season, min_games=args.min_games)
        path = PROCESSED_DIR / f"unified_{season}.csv"
        df.to_csv(path, index=False)
        print(f"  Saved {path}")
        all_seasons.append(df)

    combined = pd.concat(all_seasons, ignore_index=True)
    combined_path = PROCESSED_DIR / "unified_all.csv"
    combined.to_csv(combined_path, index=False)
    print(f"\nSaved combined dataset: {combined_path}")
    print(f"Total rows: {len(combined)}, columns: {len(combined.columns)}")


if __name__ == "__main__":
    main()
