""" builds upcoming games table, schedule rows + odds by game id

Inputs
  - raw/schedule.csv — must include game_id and odds merge key columns
  - processed/odds_features.csv, from odds pipeline (``game_id``, ML, implied)

Output:
  - processed/upcoming_games_with_odds.csv by default
"""

from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd

ML_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = ML_PIPELINE_ROOT / "data" / "raw"
PROCESSED_DIR = ML_PIPELINE_ROOT / "data" / "processed"

DEFAULT_SCHEDULE = RAW_DIR / "schedule.csv"
DEFAULT_ODDS = PROCESSED_DIR / "odds_features.csv"
DEFAULT_OUTPUT = PROCESSED_DIR / "upcoming_games_with_odds.csv"

OUTPUT_COLUMNS = [
    "game_id",
    "date",
    "home_team",
    "away_team",
    "home_team_id",
    "away_team_id",
    "home_pitcher_id",
    "home_pitcher_name",
    "away_pitcher_id",
    "away_pitcher_name",
    "home_moneyline",
    "away_moneyline",
    "home_implied_prob",
    "away_implied_prob",
    "status",
]


def filter_non_final_games(schedule: pd.DataFrame) -> pd.DataFrame:
    """Keep rows that are not finished (StatsAPI ``detailedState`` == ``Final``)."""
    if "status" not in schedule.columns:
        return schedule
    return schedule[schedule["status"].astype(str) != "Final"].copy()


def build_upcoming_dataset(
    schedule: pd.DataFrame,
    odds: pd.DataFrame,
    *,
    how: str = "left",
    only_non_final: bool = True,
) -> pd.DataFrame:
    if only_non_final:
        schedule = filter_non_final_games(schedule)

    df = schedule.merge(odds, on="game_id", how=how)

    no_odds = df["home_moneyline"].isna().sum() if "home_moneyline" in df.columns else 0
    if no_odds:
        print(f"Warning: {no_odds} game(s) have no odds (bookmakers haven't posted yet or odds fetch gap)")

    missing = [c for c in OUTPUT_COLUMNS if c not in df.columns]
    if missing:
        raise ValueError(
            f"Merged frame missing columns {missing}. "
            "Ensure schedule and odds_features match the expected schema."
        )

    return df[OUTPUT_COLUMNS].copy()


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Merge schedule with odds_features for upcoming / listed games",
    )
    parser.add_argument(
        "--schedule",
        type=Path,
        default=DEFAULT_SCHEDULE,
        help="Path to schedule CSV",
    )
    parser.add_argument(
        "--odds",
        type=Path,
        default=DEFAULT_ODDS,
        help="Path to odds_features CSV",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="Output CSV path",
    )
    parser.add_argument(
        "--how",
        choices=("inner", "left", "right", "outer"),
        default="left",
        help="Merge how (default: left — keeps all scheduled games, NaN odds for missing lines)",
    )
    parser.add_argument(
        "--include-final",
        action="store_true",
        help="Do not drop Final games before merging",
    )
    args = parser.parse_args()

    schedule = pd.read_csv(args.schedule)
    odds = pd.read_csv(args.odds)

    df = build_upcoming_dataset(
        schedule,
        odds,
        how=args.how,
        only_non_final=not args.include_final,
    )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(args.output, index=False)
    print(f"Saved upcoming dataset to {args.output}")
    print(f"Rows: {len(df)}")
    print(df.head())


if __name__ == "__main__":
    main()
