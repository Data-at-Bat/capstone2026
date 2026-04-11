import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

RAW_DIR = os.path.join(BASE_DIR, "data", "raw")
PROCESSED_DIR = os.path.join(BASE_DIR, "data", "processed")

SCHEDULE_FILE = os.path.join(RAW_DIR, "schedule.csv")
RESULTS_FILE = os.path.join(RAW_DIR, "game_results.csv")

OUTPUT_FILE = os.path.join(PROCESSED_DIR, "model_dataset.csv")


def load_data():

    schedule = pd.read_csv(SCHEDULE_FILE)
    results = pd.read_csv(RESULTS_FILE)

    return schedule, results


def merge_data(schedule, results):

    df = schedule.merge(
        results,
        on=["game_id", "date"],
        how="inner"
    )

    return df


def clean_dataset(df):

    columns = [
        "game_id",
        "date",
        "home_team",
        "away_team",
        "home_team_id",
        "away_team_id",
        "home_pitcher_id",
        "away_pitcher_id",
        "home_score",
        "away_score",
        "home_win"
    ]

    df = df[columns]

    # Drop games missing critical info
    df = df.dropna(subset=["home_score", "away_score"])

    return df


def save_dataset(df):

    os.makedirs(PROCESSED_DIR, exist_ok=True)

    df.to_csv(OUTPUT_FILE, index=False)

    print(f"Saved dataset to {OUTPUT_FILE}")
    print(f"Total rows: {len(df)}")


if __name__ == "__main__":

    schedule, results = load_data()

    df = merge_data(schedule, results)

    df = clean_dataset(df)

    print(df.head())

    save_dataset(df)
