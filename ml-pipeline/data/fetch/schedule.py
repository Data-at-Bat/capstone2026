import requests
import pandas as pd
from datetime import datetime, timedelta, timezone
import os

BASE_URL = "https://statsapi.mlb.com/api/v1/schedule"

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "raw")
OUTPUT_FILE = "schedule.csv"


def fetch_schedule(start_date: str, end_date: str) -> pd.DataFrame:
    """
    Fetch MLB schedule between two dates.

    Returns DataFrame with:
    - game_id,
    - game_time_utc,
    - date
    - home_team,
    - away_team,
     -home_team_id,
    - away_team_id,
    - home_pitcher_id
    - home_pitcher_name
    - away_pitcher_id
    - away_pitcher_name
    - status
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
        for game in date_block.get("games", []):
            # Extracting game details
            game_id = game["gamePk"]

            game_time_utc = game.get("gameDate")

            home_info = game["teams"]["home"]["team"]
            away_info = game["teams"]["away"]["team"]

            # Skip games with incomplete team info (All-Star, exhibitions)
            if "name" not in home_info or "name" not in away_info:
                continue

            home_team = home_info["name"]
            away_team = away_info["name"]

            home_team_id = home_info["id"]
            away_team_id = away_info["id"]
            status = game["status"]["detailedState"]

            # Probable pitchers (may not exist)
            home_pitcher = game["teams"]["home"].get("probablePitcher", {})
            away_pitcher = game["teams"]["away"].get("probablePitcher", {})

            rows.append({
                "game_id": game_id,
                "game_time_utc": game_time_utc,
                "date": date_block["date"],
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

    return pd.DataFrame(rows)


def save_schedule(df: pd.DataFrame):
    if df.empty:
        print("No games found for this period.")
        return

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)

    if os.path.exists(path):
        existing = pd.read_csv(path)
        # Combine and ensure we don't have duplicates
        df = pd.concat([existing, df]).drop_duplicates("game_id", keep="last")

    df.to_csv(path, index=False)
    print(f"Saved {len(df)} games to {path}")


if __name__ == "__main__":
    # fetch a tight rolling window around today
    today = datetime.now(timezone.utc)
    start_date = today - timedelta(days=3)
    end_date = today + timedelta(days=3)

    df_schedule = fetch_schedule(
        start_date.strftime("%Y-%m-%d"),
        end_date.strftime("%Y-%m-%d")
    )

    save_schedule(df_schedule)