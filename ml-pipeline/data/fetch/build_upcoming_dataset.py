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

    # Safely load odds, handling the case where it might be a 0-byte empty file
    try:
        odds = pd.read_csv(ODDS_FILE)
    except pd.errors.EmptyDataError:
        # If the file is empty, create an empty dataframe with the expected columns
        odds = pd.DataFrame(columns=[
            "game_id", "home_moneyline", "away_moneyline",
            "home_spread", "away_spread",
            "home_implied_prob", "away_implied_prob"
        ])

    return schedule, odds


def build_dataset(schedule, odds):
    if schedule.empty or odds.empty:
        print("Notice: Schedule or Odds data is empty for today. Pipeline will proceed with empty dataset.")

    df = schedule.merge(
        odds,
        on="game_id",
        how="inner"
    )

    columns = [
        "game_id",
        "game_time_utc",
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
        "home_spread",
        "away_spread",
        "home_implied_prob",
        "away_implied_prob",
        "status"
    ]

    if df.empty:
        return pd.DataFrame(columns=columns)

    # This logic ensures that if game_time_utc exists, it's kept.
    existing_cols = [col for col in columns if col in df.columns]
    df = df[existing_cols]

    return df

def save_dataset(df):
    os.makedirs(PROCESSED_DIR, exist_ok=True)
    df.to_csv(OUTPUT_FILE, index=False)

    print(f"Saved upcoming dataset to {OUTPUT_FILE}")
    print(f"Rows: {len(df)}")

    if not df.empty:
        print(df.head())


if __name__ == "__main__":
    schedule, odds = load_data()
    df = build_dataset(schedule, odds)
    save_dataset(df)