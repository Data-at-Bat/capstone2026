import os
import requests
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PROCESSED_DIR = os.path.join(BASE_DIR, "data", "processed")
RAW_DIR = os.path.join(BASE_DIR, "data", "raw")

INPUT_FILE = os.path.join(PROCESSED_DIR, "upcoming_games_with_odds.csv")
OUTPUT_FILE = os.path.join(RAW_DIR, "pitcher_stats.csv")

BASE_URL = "https://statsapi.mlb.com/api/v1/people/{}/stats"


def fetch_pitcher_stats(player_id):
    url = BASE_URL.format(int(player_id))

    params = {
        "stats": "season",
        "group": "pitching",
        "sportIds": 1
    }

    response = requests.get(url, params=params)
    response.raise_for_status()

    data = response.json()

    try:
        splits = data["stats"][0]["splits"]
        if not splits:
            return None

        stat = splits[0]["stat"]

        return {
            "pitcher_id": int(player_id),
            "era": stat.get("era"),
            "whip": stat.get("whip"),
            "innings_pitched": stat.get("inningsPitched"),
            "strikeouts": stat.get("strikeOuts")
        }

    except (KeyError, IndexError):
        return None


def main():
    df = pd.read_csv(INPUT_FILE)

    pitcher_ids = pd.concat([
        df["home_pitcher_id"],
        df["away_pitcher_id"]
    ]).dropna().unique()

    rows = []

    print(f"Fetching stats for {len(pitcher_ids)} pitchers...")

    for i, pitcher_id in enumerate(pitcher_ids, start=1):
        print(f"{i}/{len(pitcher_ids)}")

        result = fetch_pitcher_stats(pitcher_id)
        if result is not None:
            rows.append(result)

    out = pd.DataFrame(rows)
    out.to_csv(OUTPUT_FILE, index=False)

    print(f"Saved pitcher stats to {OUTPUT_FILE}")
    print(out.head())


if __name__ == "__main__":
    main()