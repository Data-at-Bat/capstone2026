import argparse
import os
import joblib
import lightgbm as lgb
import pandas as pd
from sklearn.metrics import log_loss

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA_PATH = os.path.join(BASE_DIR, "data", "processed", "model_dataset.csv")
PITCHER_STATS_PATH = os.path.join(BASE_DIR, "data", "raw", "pitcher_stats.csv")
MODEL_DIR = os.path.join(BASE_DIR, "models", "lightgbm_v1")
MODEL_PATH = os.path.join(MODEL_DIR, "model.pkl")

BASE_FEATURE_COLUMNS = [
    "home_team_id",
    "away_team_id",
    "home_pitcher_id",
    "away_pitcher_id",
    "home_pitcher_era",
    "away_pitcher_era",
    "home_pitcher_whip",
    "away_pitcher_whip",
]

FULL_FEATURE_COLUMNS = BASE_FEATURE_COLUMNS + [
    "home_team_win_pct",
    "away_team_win_pct",
    "home_last10_win_pct",
    "away_last10_win_pct",
]

def load_data():
    df = pd.read_csv(DATA_PATH)
    return df


def add_pitcher_features(df):
    pitcher_stats = pd.read_csv(PITCHER_STATS_PATH)
    pitcher_stats = pitcher_stats[["pitcher_id", "era", "whip"]].copy()
    pitcher_stats["pitcher_id"] = pd.to_numeric(pitcher_stats["pitcher_id"], errors="coerce")
    pitcher_stats["era"] = pd.to_numeric(pitcher_stats["era"], errors="coerce")
    pitcher_stats["whip"] = pd.to_numeric(pitcher_stats["whip"], errors="coerce")

    home_stats = pitcher_stats.rename(
        columns={
            "pitcher_id": "home_pitcher_id",
            "era": "home_pitcher_era",
            "whip": "home_pitcher_whip",
        }
    )
    away_stats = pitcher_stats.rename(
        columns={
            "pitcher_id": "away_pitcher_id",
            "era": "away_pitcher_era",
            "whip": "away_pitcher_whip",
        }
    )

    df = df.merge(home_stats, on="home_pitcher_id", how="left")
    df = df.merge(away_stats, on="away_pitcher_id", how="left")

    for col in ["home_pitcher_era", "away_pitcher_era", "home_pitcher_whip", "away_pitcher_whip"]:
        df[col] = df[col].fillna(df[col].median())

    return df


def add_team_form_features(df):
    games = df[["game_id", "date", "home_team", "away_team", "home_win"]].copy()
    games["home_win"] = pd.to_numeric(games["home_win"], errors="coerce")
    games = games.dropna(subset=["home_win"])

    home_rows = games.rename(columns={"home_team": "team"})
    home_rows["win"] = home_rows["home_win"]
    home_rows["is_home"] = 1

    away_rows = games.rename(columns={"away_team": "team"})
    away_rows["win"] = 1 - away_rows["home_win"]
    away_rows["is_home"] = 0

    team_games = pd.concat([home_rows, away_rows], ignore_index=True)
    team_games = team_games.sort_values(["team", "date", "game_id"])

    # Use only prior games for each team to avoid leakage.
    team_games["games_before"] = team_games.groupby("team").cumcount()
    team_games["wins_before"] = team_games.groupby("team")["win"].cumsum() - team_games["win"]
    team_games["team_win_pct"] = team_games["wins_before"] / team_games["games_before"]
    team_games["team_win_pct"] = team_games["team_win_pct"].fillna(0.5)

    team_games["last10_win_pct"] = (
        team_games.groupby("team")["win"]
        .transform(lambda s: s.shift(1).rolling(window=10, min_periods=1).mean())
        .fillna(0.5)
    )

    home_feats = (
        team_games[team_games["is_home"] == 1][["game_id", "team_win_pct", "last10_win_pct"]]
        .rename(
            columns={
                "team_win_pct": "home_team_win_pct",
                "last10_win_pct": "home_last10_win_pct",
            }
        )
    )
    away_feats = (
        team_games[team_games["is_home"] == 0][["game_id", "team_win_pct", "last10_win_pct"]]
        .rename(
            columns={
                "team_win_pct": "away_team_win_pct",
                "last10_win_pct": "away_last10_win_pct",
            }
        )
    )

    df = df.merge(home_feats, on="game_id", how="left")
    df = df.merge(away_feats, on="game_id", how="left")

    for col in [
        "home_team_win_pct",
        "away_team_win_pct",
        "home_last10_win_pct",
        "away_last10_win_pct",
    ]:
        df[col] = df[col].fillna(0.5)

    return df


def prepare_features(df, feature_columns):
    missing = [col for col in feature_columns if col not in df.columns]
    if missing:
        raise ValueError(f"Missing feature columns: {missing}")
    X = df[feature_columns]

    y = df["home_win"]

    return X, y


def train(feature_set="full12", n_estimators=150, num_leaves=15, learning_rate=0.05):

    df = load_data()
    df = add_pitcher_features(df)
    df = add_team_form_features(df)
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df = df.dropna(subset=["date"]).sort_values("date").reset_index(drop=True)

    feature_columns = FULL_FEATURE_COLUMNS if feature_set == "full12" else BASE_FEATURE_COLUMNS
    X, y = prepare_features(df, feature_columns)

    split_idx = int(len(df) * 0.8)
    if split_idx <= 0 or split_idx >= len(df):
        raise ValueError("Not enough rows for time-based train/test split.")

    X_train = X.iloc[:split_idx]
    y_train = y.iloc[:split_idx]
    X_test = X.iloc[split_idx:]
    y_test = y.iloc[split_idx:]

    train_start = df["date"].iloc[0].date()
    train_end = df["date"].iloc[split_idx - 1].date()
    test_start = df["date"].iloc[split_idx].date()
    test_end = df["date"].iloc[-1].date()

    model = lgb.LGBMClassifier(
        n_estimators=n_estimators,
        learning_rate=learning_rate,
        num_leaves=num_leaves
    )

    model.fit(
        X_train,
        y_train,
        categorical_feature=[
            "home_team_id",
            "away_team_id",
            "home_pitcher_id",
            "away_pitcher_id"
        ]
    )

    accuracy = model.score(X_test, y_test)
    test_probs = model.predict_proba(X_test)[:, 1]
    test_log_loss = log_loss(y_test, test_probs)

    print(f"Train rows: {len(X_train)} | Test rows: {len(X_test)}")
    print(f"Train range: {train_start} -> {train_end}")
    print(f"Test range:  {test_start} -> {test_end}")
    print(f"Feature set: {feature_set} ({len(feature_columns)} features)")
    print(
        "Model params: "
        f"n_estimators={n_estimators}, num_leaves={num_leaves}, learning_rate={learning_rate}"
    )
    print(f"Accuracy: {accuracy:.4f}")
    print(f"Log loss: {test_log_loss:.4f}")

    return model


def parse_args():
    parser = argparse.ArgumentParser(description="Train LightGBM MLB model.")
    parser.add_argument(
        "--feature-set",
        choices=["base8", "full12"],
        default="full12",
        help="base8: IDs + pitcher stats; full12: base8 + team form features",
    )
    parser.add_argument("--n-estimators", type=int, default=150)
    parser.add_argument("--num-leaves", type=int, default=15)
    parser.add_argument("--learning-rate", type=float, default=0.05)
    return parser.parse_args()

    return model

if __name__ == "__main__":
    args = parse_args()
    model = train(
        feature_set=args.feature_set,
        n_estimators=args.n_estimators,
        num_leaves=args.num_leaves,
        learning_rate=args.learning_rate,
    )
    os.makedirs(MODEL_DIR, exist_ok=True)
    joblib.dump(model, MODEL_PATH)
    print(f"Saved model to {MODEL_PATH}")