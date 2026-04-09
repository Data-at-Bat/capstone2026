import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

INPUT_FILE = os.path.join(BASE_DIR, "data", "processed", "odds_matched.csv")
OUTPUT_FILE = os.path.join(BASE_DIR, "data", "processed", "odds_features.csv")


def american_to_prob(odds):
    if odds > 0:
        return 100 / (odds + 100)
    else:
        return -odds / (-odds + 100)


def build_features(df):

    rows = []

    grouped = df.groupby("game_id")

    for game_id, group in grouped:

        home_team = group["home_team"].iloc[0]
        away_team = group["away_team"].iloc[0]

        home_prices = group[group["team"] == home_team]["price"]
        away_prices = group[group["team"] == away_team]["price"]

        if len(home_prices) == 0 or len(away_prices) == 0:
            continue

        best_home = home_prices.max()   # best price for bettor
        best_away = away_prices.max()

        rows.append({
            "game_id": game_id,
            "home_moneyline": best_home,
            "away_moneyline": best_away,
            "home_implied_prob": american_to_prob(best_home),
            "away_implied_prob": american_to_prob(best_away)
        })

    return pd.DataFrame(rows)


def save(df):
    df.to_csv(OUTPUT_FILE, index=False)
    print(f"Saved odds features to {OUTPUT_FILE}")
    print(df.head())


if __name__ == "__main__":

    df = pd.read_csv(INPUT_FILE)

    features = build_features(df)

    save(features)