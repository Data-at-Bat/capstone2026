import os
import joblib
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DATA_FILE = os.path.join(BASE_DIR, "data", "processed", "upcoming_games_with_odds.csv")
HISTORICAL_DATA_FILE = os.path.join(BASE_DIR, "data", "processed", "model_dataset.csv")
MODEL_FILE = os.path.join(BASE_DIR, "models", "lightgbm_v1", "model.pkl")
OUTPUT_FILE = os.path.join(BASE_DIR, "data", "processed", "predictions.csv")
FILTERED_OUTPUT_FILE = os.path.join(BASE_DIR, "data", "processed", "predictions_filtered.csv")
PITCHER_STATS_FILE = os.path.join(BASE_DIR, "data", "raw", "pitcher_stats.csv")
MIN_EDGE = 0.03
MAX_EDGE = 0.30
MIN_MODEL_PROB = 0.45
MAX_MODEL_PROB = 0.75

FEATURE_COLUMNS = [
    "home_team_id",
    "away_team_id",
    "home_pitcher_id",
    "away_pitcher_id",
    "home_pitcher_era",
    "away_pitcher_era",
    "home_pitcher_whip",
    "away_pitcher_whip",
    "home_team_win_pct",
    "away_team_win_pct",
    "home_last10_win_pct",
    "away_last10_win_pct",
]


def load_data():
    return pd.read_csv(DATA_FILE)


def load_historical_data():
    return pd.read_csv(HISTORICAL_DATA_FILE)


def load_model():
    return joblib.load(MODEL_FILE)


def add_pitcher_features(df):
    pitcher_stats = pd.read_csv(PITCHER_STATS_FILE)
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


def build_team_form_lookup(history_df):
    games = history_df[["date", "home_team", "away_team", "home_win"]].copy()
    games["date"] = pd.to_datetime(games["date"], errors="coerce")
    games["home_win"] = pd.to_numeric(games["home_win"], errors="coerce")
    games = games.dropna(subset=["date", "home_win"])

    home_rows = games.rename(columns={"home_team": "team"})
    home_rows["win"] = home_rows["home_win"]

    away_rows = games.rename(columns={"away_team": "team"})
    away_rows["win"] = 1 - away_rows["home_win"]

    team_games = pd.concat([home_rows, away_rows], ignore_index=True).sort_values(["team", "date"])

    summary = team_games.groupby("team")["win"].agg(["mean", "count"]).reset_index()
    summary = summary.rename(columns={"mean": "team_win_pct", "count": "games"})

    last10 = (
        team_games.groupby("team")["win"]
        .apply(lambda s: s.tail(10).mean() if len(s) > 0 else 0.5)
        .reset_index(name="last10_win_pct")
    )
    summary = summary.merge(last10, on="team", how="left")
    summary["team_win_pct"] = summary["team_win_pct"].fillna(0.5)
    summary["last10_win_pct"] = summary["last10_win_pct"].fillna(0.5)

    return summary.set_index("team")[["team_win_pct", "last10_win_pct"]]


def add_team_form_features(df, history_df):
    lookup = build_team_form_lookup(history_df)
    home_lookup = lookup.rename(
        columns={
            "team_win_pct": "home_team_win_pct",
            "last10_win_pct": "home_last10_win_pct",
        }
    )
    away_lookup = lookup.rename(
        columns={
            "team_win_pct": "away_team_win_pct",
            "last10_win_pct": "away_last10_win_pct",
        }
    )

    df = df.merge(home_lookup, left_on="home_team", right_index=True, how="left")
    df = df.merge(away_lookup, left_on="away_team", right_index=True, how="left")

    for col in [
        "home_team_win_pct",
        "away_team_win_pct",
        "home_last10_win_pct",
        "away_last10_win_pct",
    ]:
        df[col] = df[col].fillna(0.5)

    return df


def prepare_features(df):
    missing = [col for col in FEATURE_COLUMNS if col not in df.columns]
    if missing:
        raise ValueError(f"Missing feature columns: {missing}")

    return df[FEATURE_COLUMNS]


def main():
    df = load_data()
    history_df = load_historical_data()
    df = add_pitcher_features(df)
    df = add_team_form_features(df, history_df)
    model = load_model()

    X = prepare_features(df)

    probs = model.predict_proba(X)[:, 1]

    df["model_home_win_prob"] = probs
    df["edge"] = df["model_home_win_prob"] - df["home_implied_prob"]
    df = df.sort_values("edge", ascending=False)
    filtered = df[
        (df["edge"] >= MIN_EDGE)
        & (df["edge"] <= MAX_EDGE)
        & (df["model_home_win_prob"] >= MIN_MODEL_PROB)
        & (df["model_home_win_prob"] <= MAX_MODEL_PROB)
    ].copy()

    print("\nAll predictions sorted by edge:")
    print(
        df[
            [
                "home_team",
                "away_team",
                "home_moneyline",
                "model_home_win_prob",
                "home_implied_prob",
                "edge",
            ]
        ]
    )

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    df.to_csv(OUTPUT_FILE, index=False)
    filtered.to_csv(FILTERED_OUTPUT_FILE, index=False)
    print(f"\nSaved predictions to {OUTPUT_FILE}")
    print(
        "Saved filtered predictions "
        f"({len(filtered)} rows, edge in [{MIN_EDGE}, {MAX_EDGE}], "
        f"model_prob in [{MIN_MODEL_PROB}, {MAX_MODEL_PROB}]) "
        f"to {FILTERED_OUTPUT_FILE}"
    )


if __name__ == "__main__":
    main()
