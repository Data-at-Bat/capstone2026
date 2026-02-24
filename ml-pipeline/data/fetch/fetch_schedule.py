import requests
import pandas as pd
from datetime import datetime, timedelta
import os

BASE_URL = "https://statsapi.mlb.com/api/v1/schedule"

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "raw")
OUTPUT_FILE = "schedule.csv"


def fetch_schedule(start_date: str, end_date: str) -> pd.DataFrame:
    """
    Fetch MLB schedule between two dates.

    Returns DataFrame with:
    - game_id
    - date
    - home_team
    - away_team
    - home_team_id
    - away_team_id
    - game_status
    """

    params = {
        "sportId": 1,
        "startDate": start_date,
        "endDate": end_date,
        "hydrate": "probablePitcher"
    }

    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()

    data = response.json()

    rows = []

    for date_block in data.get("dates", []):
        game_date = date_block["date"]

        for game in date_block.get("games", []):

            game_id = game["gamePk"]

            home_team = game["teams"]["home"]["team"]["name"]
            away_team = game["teams"]["away"]["team"]["name"]

            home_team_id = game["teams"]["home"]["team"]["id"]
            away_team_id = game["teams"]["away"]["team"]["id"]

            status = game["status"]["detailedState"]

            # probable pitchers (may not exist)
            home_pitcher = game["teams"]["home"].get("probablePitcher", {})
            away_pitcher = game["teams"]["away"].get("probablePitcher", {})

            rows.append({
                "game_id": game_id,
                "date": game_date,
                "home_team": home_team,
                "away_team": away_team,
                "home_team_id": home_team_id,
                "away_team_id": away_team_id,
                "home_pitcher_id": home_pitcher.get("id"),
                "home_pitcher_name": home_pitcher.get("fullName"),
                "away_pitcher_id": away_pitcher.get("id"),
                "away_pitcher_name": away_pitcher.get("fullName"),
                "status": status
            })

    df = pd.DataFrame(rows)

    return df


def save_schedule(df: pd.DataFrame):
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)

    if os.path.exists(path):
        existing = pd.read_csv(path)
        df = pd.concat([existing, df]).drop_duplicates("game_id")

    df.to_csv(path, index=False)

    print(f"Saved {len(df)} games to {path}")


if __name__ == "__main__":

    # example: fetch last 365 days
    end_date = datetime.today()
    start_date = end_date - timedelta(days=365)

    df = fetch_schedule(
        start_date.strftime("%Y-%m-%d"),
        end_date.strftime("%Y-%m-%d")
    )

    save_schedule(df)