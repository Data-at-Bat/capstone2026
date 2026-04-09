import requests
import pandas as pd
import os
from datetime import datetime, timedelta

BASE_URL = "https://statsapi.mlb.com/api/v1/schedule"

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "raw")
OUTPUT_FILE = "game_results.csv"


def fetch_game_results(start_date, end_date):
    """
    Fetch all game results between two dates using bulk endpoint
    """

    params = {
        "sportId": 1,
        "startDate": start_date,
        "endDate": end_date,
        "hydrate": "linescore"
    }

    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()

    data = response.json()

    rows = []

    for date_block in data.get("dates", []):

        for game in date_block.get("games", []):

            game_id = game["gamePk"]

            linescore = game.get("linescore")

            # skip games without scores yet
            if not linescore:
                continue

            home_score = linescore.get("teams", {}).get("home", {}).get("runs")
            away_score = linescore.get("teams", {}).get("away", {}).get("runs")

            # some API rows have a linescore object but no run totals yet
            if home_score is None or away_score is None:
                continue

            home_win = 1 if home_score > away_score else 0

            rows.append({
                "game_id": game_id,
                "date": date_block["date"],
                "home_score": home_score,
                "away_score": away_score,
                "home_win": home_win
            })

    return pd.DataFrame(rows)


def save_results(df):

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)

    df.to_csv(path, index=False)

    print(f"Saved {len(df)} game results to {path}")


if __name__ == "__main__":

    end_date = datetime.today()
    start_date = end_date - timedelta(days=365)

    print("Fetching game results...")

    df = fetch_game_results(
        start_date.strftime("%Y-%m-%d"),
        end_date.strftime("%Y-%m-%d")
    )

    print(df.head())

    save_results(df)