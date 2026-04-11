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

        # Extract Moneylines (h2h)
        h2h_group = group[group["market"] == "h2h"]
        home_ml_prices = h2h_group[h2h_group["team"] == home_team]["price"]
        away_ml_prices = h2h_group[h2h_group["team"] == away_team]["price"]

        best_home_ml = home_ml_prices.max() if not home_ml_prices.empty else 0.0
        best_away_ml = away_ml_prices.max() if not away_ml_prices.empty else 0.0

        if best_home_ml == 0.0 and best_away_ml == 0.0:
            continue

        # Extract Spreads
        spreads_group = group[group["market"] == "spreads"]
        home_spreads = spreads_group[spreads_group["team"] == home_team]
        away_spreads = spreads_group[spreads_group["team"] == away_team]

        best_home_spread = 0.0
        if not home_spreads.empty:
            best_home_spread = home_spreads.sort_values("price", ascending=False)["point"].iloc[0]

        best_away_spread = 0.0
        if not away_spreads.empty:
            best_away_spread = away_spreads.sort_values("price", ascending=False)["point"].iloc[0]

        rows.append({
            "game_id": game_id,
            "home_moneyline": best_home_ml,
            "away_moneyline": best_away_ml,
            "home_spread": best_home_spread,      # NEW
            "away_spread": best_away_spread,      # NEW
            "home_implied_prob": american_to_prob(best_home_ml),
            "away_implied_prob": american_to_prob(best_away_ml)
        })

    return pd.DataFrame(rows)

def save(df):
    df.to_csv(OUTPUT_FILE, index=False)
    print(f"Saved odds features to {OUTPUT_FILE}")

if __name__ == "__main__":
    df = pd.read_csv(INPUT_FILE)
    features = build_features(df)
    save(features)