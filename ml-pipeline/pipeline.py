from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd

from data.fetch.schedule import fetch_schedule
from data.fetch.game_results import fetch_game_results
from data.build_dataset import merge_data, clean_dataset
from data.fetch.season_stats import load_batting, load_pitching
from features.team_stats import build_team_features

PROCESSED_DIR = Path(__file__).resolve().parent / "data" / "processed"


def build_season(season: int) -> pd.DataFrame:
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
    print(f"  {len(games)} games after merge+clean")

    # Team-season features from FanGraphs
    print("Fetching batting stats...")
    batting = load_batting(season)
    print("Fetching pitching stats...")
    pitching = load_pitching(season)

    team_features = build_team_features(batting, pitching)
    print(f"  {len(team_features)} team-season rows")

    # Join home team features
    home_features = team_features.copy()
    home_features = home_features.rename(
        columns={c: f"home_{c}" for c in home_features.columns
                 if c not in ("Team", "Season")}
    )
    games = games.merge(
        home_features,
        left_on=["home_team_fg", "season"],
        right_on=["Team", "Season"],
        how="left",
    ).drop(columns=["Team", "Season"])

    # Join away team features
    away_features = team_features.copy()
    away_features = away_features.rename(
        columns={c: f"away_{c}" for c in away_features.columns
                 if c not in ("Team", "Season")}
    )
    games = games.merge(
        away_features,
        left_on=["away_team_fg", "season"],
        right_on=["Team", "Season"],
        how="left",
    ).drop(columns=["Team", "Season"])

    print(f"  Final shape: {games.shape}")
    return games


def main() -> None:
    parser = argparse.ArgumentParser(description="Build unified MLB dataset")
    parser.add_argument("--start-season", type=int, default=2024)
    parser.add_argument("--end-season", type=int, default=2024)
    args = parser.parse_args()

    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    all_seasons = []

    for season in range(args.start_season, args.end_season + 1):
        df = build_season(season)
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
