import pandas as pd
import lightgbm as lgb
import os
from sklearn.metrics import accuracy_score, log_loss

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA_PATH = os.path.join(BASE_DIR, "data", "processed", "unified_all.csv")

# Config
TRAIN_END_SEASON = 2022   # Train on seasons <= this year
TEST_START_SEASON = 2023  # Test on seasons >= this year

# Columns that are identifiers or labels — not features
DROP_COLS = [
    "game_id",
    "date",
    "season",
    "home_team",
    "away_team",
    "home_team_id",
    "away_team_id",
    "home_team_fg",
    "away_team_fg",
    "home_pitcher_id",
    "away_pitcher_id",
    "home_score",
    "away_score",
    "home_win",
]


def load_data():
    df = pd.read_csv(DATA_PATH)
    df["date"] = pd.to_datetime(df["date"])
    return df


def prepare_features(df):
    X = df.drop(columns=[c for c in DROP_COLS if c in df.columns])
    y = df["home_win"]
    return X, y


def train():
    df = load_data()

    # Temporal split
    train_mask = df["season"] <= TRAIN_END_SEASON
    test_mask = df["season"] >= TEST_START_SEASON

    train_df = df[train_mask].copy()
    test_df = df[test_mask].copy()

    print(f"Train: {len(train_df)} games (seasons <= {TRAIN_END_SEASON})")
    print(f"Test:  {len(test_df)} games (seasons >= {TEST_START_SEASON})")

    X_train, y_train = prepare_features(train_df)
    X_test, y_test = prepare_features(test_df)

    # Model
    model = lgb.LGBMClassifier(
        n_estimators=500,
        learning_rate=0.05,
        num_leaves=31,
        verbose=-1,
    )

    model.fit(X_train, y_train)

    # Evaluation
    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]

    acc = accuracy_score(y_test, y_pred)
    ll = log_loss(y_test, y_prob)

    print(f"\nAccuracy: {acc:.4f}")
    print(f"Log-loss: {ll:.4f}")

    # Feature importance
    importances = pd.Series(
        model.feature_importances_, index=X_train.columns
    ).sort_values(ascending=False)
    print(f"\nTop 10 features:")
    for feat, imp in importances.head(10).items():
        print(f"  {feat:40s} {imp}")

    return model


if __name__ == "__main__":
    model = train()