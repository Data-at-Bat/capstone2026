import os
import requests
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "raw")
OUTPUT_FILE = "odds_raw.csv"

API_KEY = 'b1affd3226b86f1767662cd62b7afe99'
BASE_URL = "https://api.the-odds-api.com/v4/sports/baseball_mlb/odds"


def fetch_odds():

    params = {
        "apiKey": API_KEY,
        "regions": "us",
        "markets": "h2h",
        "oddsFormat": "american",
    }

    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()

    data = response.json()

    rows = []

    for game in data:

        home_team = game["home_team"]
        away_team = game["away_team"]
        commence_time = game["commence_time"]

        for bookmaker in game.get("bookmakers", []):

            book_name = bookmaker["title"]

            for market in bookmaker.get("markets", []):

                if market["key"] != "h2h":
                    continue

                for outcome in market.get("outcomes", []):

                    rows.append({
                        "commence_time": commence_time,
                        "home_team": home_team,
                        "away_team": away_team,
                        "bookmaker": book_name,
                        "team": outcome["name"],
                        "price": outcome["price"]
                    })

    return pd.DataFrame(rows)


def save_odds(df):

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)

    df.to_csv(path, index=False)

    print(f"Saved {len(df)} rows to {path}")


if __name__ == "__main__":

    df = fetch_odds()

    print(df.head())

    save_odds(df)