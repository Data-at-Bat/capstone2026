import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

RAW_DIR = os.path.join(BASE_DIR, "data", "raw")
PROCESSED_DIR = os.path.join(BASE_DIR, "data", "processed")

SCHEDULE_FILE = os.path.join(RAW_DIR, "schedule.csv")
ODDS_FILE = os.path.join(PROCESSED_DIR, "odds_features.csv")

OUTPUT_FILE = os.path.join(PROCESSED_DIR, "upcoming_games_with_odds.csv")


def load_data():
    schedule = pd.read_csv(SCHEDULE_FILE)
    odds = pd.read_csv(ODDS_FILE)
    return schedule, odds


def build_dataset(schedule, odds):
    df = schedule.merge(
        odds,
        on="game_id",
        how="inner"
    )

    columns = [
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
        "status"
    ]

    df = df[columns]

    return df


def save_dataset(df):
    os.makedirs(PROCESSED_DIR, exist_ok=True)
    df.to_csv(OUTPUT_FILE, index=False)

    print(f"Saved upcoming dataset to {OUTPUT_FILE}")
    print(f"Rows: {len(df)}")
    print(df.head())


if __name__ == "__main__":
    schedule, odds = load_data()
    df = build_dataset(schedule, odds)
    save_dataset(df)