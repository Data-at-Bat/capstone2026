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

    schedule["date"] = pd.to_datetime(schedule["date"])
    odds["commence_time"] = pd.to_datetime(odds["commence_time"], utc=True)

    odds["odds_date"] = odds["commence_time"].dt.tz_convert(None).dt.normalize()
    schedule["schedule_date"] = schedule["date"].dt.normalize()
    return schedule, odds

def match(schedule, odds):

    merged = odds.merge(
        schedule,
        on=["home_team", "away_team"],
        how="left"
    )

    merged["date_diff_days"] = (
            merged["schedule_date"] - merged["odds_date"]
    ).abs().dt.days


    # .first(), it will automatically grab the value
    # from the first valid match in the schedule.
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

    merged = merged[merged["date_diff_days"] <= 1]
    merged = merged.sort_values("date_diff_days")

    best_match = (
        merged.groupby(group_cols, dropna=False, as_index=False)
        .first() # This will now keep game_time_utc
    )

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