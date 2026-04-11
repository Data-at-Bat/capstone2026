import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

MODEL_DATASET_FILE = os.path.join(BASE_DIR, "data", "processed", "model_dataset.csv")
ODDS_FEATURES_FILE = os.path.join(BASE_DIR, "data", "processed", "odds_features.csv")
OUTPUT_FILE = os.path.join(BASE_DIR, "data", "processed", "model_dataset_with_odds.csv")


def main():
    model_df = pd.read_csv(MODEL_DATASET_FILE)
    odds_df = pd.read_csv(ODDS_FEATURES_FILE)

    merged = model_df.merge(
        odds_df,
        on="game_id",
        how="left"
    )

    print("Merged shape:", merged.shape)
    print("Rows with odds:", merged["home_moneyline"].notna().sum())
    print("Rows missing odds:", merged["home_moneyline"].isna().sum())

    merged.to_csv(OUTPUT_FILE, index=False)
    print(f"Saved merged dataset to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()