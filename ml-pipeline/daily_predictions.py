import datetime
import json
import requests
import os
import joblib

from data.fetch.schedule import fetch_schedule
from data.fetch.game_logs import fetch_all_team_logs
from features.team_stats import build_team_features
from config.team_mapping import MLB_NAME_TO_FG

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models", "lightgbm_v1")
MODEL_PATH = os.path.join(MODEL_DIR, "lgbm_model.joblib")
FEATURES_PATH = os.path.join(MODEL_DIR, "model_features.json")
API_URL = "http://localhost:8080/games?batch=true"

def get_todays_schedule():
    today_str = datetime.date.today().strftime("%Y-%m-%d")
    print(f"Fetching schedule for {today_str}...")

    schedule_df = fetch_schedule(today_str, today_str)
    if schedule_df.empty:
        print("No games scheduled for today.")
        return None

    schedule_df["home_team_fg"] = schedule_df["home_team"].map(MLB_NAME_TO_FG)
    schedule_df["away_team_fg"] = schedule_df["away_team"].map(MLB_NAME_TO_FG)
    return schedule_df

def build_todays_features(schedule_df):
    season = datetime.date.today().year
    print(f"Fetching {season} game logs to calculate rolling stats...")
    batting_logs, pitching_logs = fetch_all_team_logs(season)

    print("Computing cumulative features...")
    team_features = build_team_features(batting_logs, pitching_logs, min_games=0)
    latest_features = team_features.sort_values("date").groupby("Team").tail(1)

    # Drop 'date' and 'game_id' BEFORE merging to prevent Pandas column collisions
    feats_to_merge = latest_features.drop(columns=["date", "game_id"])

    print("Merging features with today's schedule...")
    # Home Teams
    home_features = feats_to_merge.copy().rename(
        columns={c: f"home_{c}" for c in feats_to_merge.columns if c != "Team"}
    )
    df = schedule_df.merge(home_features, left_on="home_team_fg", right_on="Team", how="left").drop(columns=["Team"])

    # Away Teams
    away_features = feats_to_merge.copy().rename(
        columns={c: f"away_{c}" for c in feats_to_merge.columns if c != "Team"}
    )
    df = df.merge(away_features, left_on="away_team_fg", right_on="Team", how="left").drop(columns=["Team"])

    return df

def predict_outcomes(df):
    print("Loading model and predicting...")
    model = joblib.load(MODEL_PATH)

    with open(FEATURES_PATH, "r") as f:
        feature_cols = json.load(f)

    for col in feature_cols:
        if col not in df.columns:
            df[col] = 0

    X = df[feature_cols].fillna(0)

    probabilities = model.predict_proba(X)[:, 1]

    df["model_confidence"] = probabilities
    df["predicted_winner"] = df.apply(
        lambda row: row["home_team"] if row["model_confidence"] > 0.5 else row["away_team"],
        axis=1
    )
    return df

def push_to_api(df):
    payload = []
    for index, row in df.iterrows():
        factors_dict = {
            "home_ops": row.get("home_batting_OPS", 0.0),
            "away_ops": row.get("away_batting_OPS", 0.0),
            "home_pitching_era": row.get("home_pitching_ERA", 0.0),
            "away_pitching_era": row.get("away_pitching_ERA", 0.0)
        }

        # 1. Format the exact time for Spring Boot LocalDateTime (Strip the 'Z')
        exact_time = str(row.get("exact_time", ""))
        if "T" in exact_time:
            game_time = exact_time.replace("Z", "")
        else:
            game_time = str(row["date"]) + "T00:00:00"

        # 2. Format Confidence as a percentage (e.g., 68.5)
        raw_confidence = float(row.get("model_confidence", 0.0))
        confidence_pct = round(raw_confidence * 100, 1)

        game_payload = {
            "gameTime": game_time,
            "homeTeamId": str(row["home_team_id"]),
            "awayTeamId": str(row["away_team_id"]),
            "homeTeamName": str(row["home_team"]),
            "awayTeamName": str(row["away_team"]),
            "predictedWinner": str(row["predicted_winner"]),
            "confidence": confidence_pct,
            "spread": 0.0,
            "odds": 0.0,
            "predictiveFactors": json.dumps(factors_dict)
        }
        payload.append(game_payload)

    print(f"Sending {len(payload)} predictions to Spring Boot API...")
    try:
        response = requests.post(API_URL, json=payload, headers={'Content-Type': 'application/json'})
        if response.status_code == 200:
            print("Success! Data saved to database.")
        else:
            print(f"Failed. Code: {response.status_code}\nResponse: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"API Connection Error: {e}")

if __name__ == "__main__":
    schedule = get_todays_schedule()
    if schedule is not None:
        features = build_todays_features(schedule)
        predictions = predict_outcomes(features)
        push_to_api(predictions)