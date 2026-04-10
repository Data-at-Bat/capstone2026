import subprocess
import sys
from pathlib import Path

# Define base paths
BASE_DIR = Path(__file__).resolve().parents[1]
FETCH_DIR = BASE_DIR / "data" / "fetch"
SCRIPTS_DIR = BASE_DIR / "scripts"


def run_script(script_path: Path) -> None:
    """Executes a python script and halts the pipeline if it fails."""
    if not script_path.exists():
        raise FileNotFoundError(f"Script not found: {script_path}")

    print(f"\n>>> Running: {script_path}")
    result = subprocess.run([sys.executable, str(script_path)], cwd=str(BASE_DIR))
    if result.returncode != 0:
        raise RuntimeError(f"Step failed: {script_path}")


def main():
    print("Starting Daily Prediction Pipeline...")

    # Step 1: Pull games for the day (Schedule, Odds, Matchups, Pitcher Stats)
    data_steps = [
        FETCH_DIR / "fetch_schedule.py",
        FETCH_DIR / "fetch_odds.py",
        FETCH_DIR / "match_odds_to_games.py",
        FETCH_DIR / "build_odds_features.py",
        FETCH_DIR / "build_upcoming_dataset.py",
        FETCH_DIR / "fetch_pitcher_stats.py",
        ]

    # Make predictions and POST the batch to the Spring Boot API
    prediction_steps = [
        SCRIPTS_DIR / "predict_upcoming_games.py",
        ]

    # Combine into a single execution list
    steps = data_steps + prediction_steps

    print(f"Total steps: {len(steps)}")

    for step in steps:
        run_script(step)

    print("\nDaily Prediction Pipeline completed successfully.")


if __name__ == "__main__":
    main()