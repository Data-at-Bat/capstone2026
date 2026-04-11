import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

RAW_DIR = os.path.join(BASE_DIR, "data", "raw")
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "processed")

SCHEDULE_FILE = os.path.join(RAW_DIR, "schedule.csv")
ODDS_FILE = os.path.join(RAW_DIR, "odds_raw.csv")
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "odds_matched.csv")

def normalize_team(name):
    mapping = {"Athletics": "Oakland Athletics"}
    return mapping.get(name, name)

def load_data():
    schedule = pd.read_csv(SCHEDULE_FILE)
    odds = pd.read_csv(ODDS_FILE)
    return schedule, odds

def preprocess(schedule, odds):
    schedule["home_team"] = schedule["home_team"].apply(normalize_team)
    schedule["away_team"] = schedule["away_team"].apply(normalize_team)
    odds["home_team"] = odds["home_team"].apply(normalize_team)
    odds["away_team"] = odds["away_team"].apply(normalize_team)

    schedule["game_time"] = pd.to_datetime(schedule["game_time_utc"], format="mixed", utc=True)
    odds["commence_time"] = pd.to_datetime(odds["commence_time"], format="mixed", utc=True)

    return schedule, odds


def match(schedule, odds):
    merged = odds.merge(
        schedule,
        on=["home_team", "away_team"],
        how="left"
    )

    merged["time_diff_hours"] = (
                                        merged["game_time"] - merged["commence_time"]
                                ).abs().dt.total_seconds() / 3600.0

    group_cols = [
        "commence_time",
        "home_team",
        "away_team",
        "bookmaker",
        "market",
        "team",
        "price",
        "point"
    ]

    # Only keep candidate games within 12 hours of the odds time
    # (This handles double-headers and weather delays safely)
    merged = merged[merged["time_diff_hours"] <= 12]

    # Sort so the game happening at the EXACT same time is at the top
    merged = merged.sort_values("time_diff_hours")

    # Strictly grab the single closest game to prevent duplicates
    best_match = merged.drop_duplicates(subset=group_cols, keep="first")

    return best_match

def save(df):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    df.to_csv(OUTPUT_FILE, index=False)
    print(f"Saved matched odds to {OUTPUT_FILE}")

if __name__ == "__main__":
    schedule, odds = load_data()
    schedule, odds = preprocess(schedule, odds)
    df = match(schedule, odds)
    save(df)