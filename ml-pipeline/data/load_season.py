from __future__ import annotations

import os
from pathlib import Path

import pandas as pd
from pybaseball import (
    batting_stats,
    cache,
    pitching_stats,
    statcast,
)

# Configuration
PROCESSED_DIR = Path(__file__).resolve().parent / "processed"
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

cache.enable()


# Helpers
def _summarize(df: pd.DataFrame, label: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {label}")
    print(f"{'='*60}")
    print(f"Shape : {df.shape}")
    print(f"Columns ({len(df.columns)}):\n  {list(df.columns)}")
    print(f"\nSample rows:")
    print(df.head())
    print()


# Public API

# start_season/end_season: year range (end defaults to start for single season)
# qual: minimum plate appearances to include a player (1 = everyone)
# save_csv: if True, writes result to data/processed/
def load_batting(
    start_season: int = 2024,
    end_season: int | None = None,
    qual: int = 1,
    save_csv: bool = False,
) -> pd.DataFrame:

    end_season = end_season or start_season
    print(f"Loading batting stats {start_season}–{end_season} (qual={qual}) …")
    df = batting_stats(start_season, end_season, qual=qual, ind=1)
    tag = f"{start_season}" if start_season == end_season else f"{start_season}_{end_season}"
    _summarize(df, f"Batting {tag}")

    if save_csv:
        path = PROCESSED_DIR / f"batting_{tag}.csv"
        df.to_csv(path, index=False)
        print(f"Saved → {path}")

    return df


# start_season/end_season: year range (end defaults to start for single season)
# qual: minimum batters faced to include a pitcher (1 = everyone)
# save_csv: if True, writes result to data/processed/
def load_pitching(
    start_season: int = 2024,
    end_season: int | None = None,
    qual: int = 1,
    save_csv: bool = False,
) -> pd.DataFrame:
    
    end_season = end_season or start_season
    print(f"Loading pitching stats {start_season}–{end_season} (qual={qual}) …")
    df = pitching_stats(start_season, end_season, qual=qual, ind=1)
    tag = f"{start_season}" if start_season == end_season else f"{start_season}_{end_season}"
    _summarize(df, f"Pitching {tag}")

    if save_csv:
        path = PROCESSED_DIR / f"pitching_{tag}.csv"
        df.to_csv(path, index=False)
        print(f"Saved → {path}")

    return df


# start_dt/end_dt: date range in "YYYY-MM-DD" format
# save_csv: if True, writes result to data/processed/
def load_statcast(
    start_dt: str = "2024-07-01",
    end_dt: str = "2024-07-07",
    save_csv: bool = False,
) -> pd.DataFrame:
    
    print(f"Loading Statcast data {start_dt} → {end_dt} …")
    df = statcast(start_dt, end_dt)
    tag = f"{start_dt}_{end_dt}"
    _summarize(df, f"Statcast {tag}")

    if save_csv:
        path = PROCESSED_DIR / f"statcast_{tag}.csv"
        df.to_csv(path, index=False)
        print(f"Saved → {path}")

    return df


def main() -> None:
    """Demo: load batting, pitching, and a small Statcast window for 2024."""
    batting_df = load_batting(2024, save_csv=True)
    pitching_df = load_pitching(2024, save_csv=True)
    statcast_df = load_statcast("2024-07-01", "2024-07-07", save_csv=True)

    print("\nAll DataFrames loaded successfully.")
    print(f"batting : {batting_df.shape}")
    print(f"pitching : {pitching_df.shape}")
    print(f"statcast : {statcast_df.shape}")


if __name__ == "__main__":
    main()
