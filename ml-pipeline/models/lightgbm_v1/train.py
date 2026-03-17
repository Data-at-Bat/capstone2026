import pandas as pd
import lightgbm as lgb
import os
from sklearn.model_selection import train_test_split

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA_PATH = os.path.join(BASE_DIR, "data", "processed", "unified_all.csv")


def load_data():
    df = pd.read_csv(DATA_PATH)
    return df


def prepare_features(df):

    drop_cols = [
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
    X = df.drop(columns=[c for c in drop_cols if c in df.columns])

    y = df["home_win"]

    return X, y


def train():

    df = load_data()

    X, y = prepare_features(df)

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.2,
        random_state=42
    )

    model = lgb.LGBMClassifier(
        n_estimators=500,
        learning_rate=0.05,
        num_leaves=31
    )

    model.fit(X_train, y_train)

    accuracy = model.score(X_test, y_test)

    print(f"Accuracy: {accuracy:.4f}")

    return model


if __name__ == "__main__":
    model = train()