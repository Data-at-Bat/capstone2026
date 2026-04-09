import argparse
import subprocess
import sys
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[1]
FETCH_DIR = BASE_DIR / "data" / "fetch"
MODEL_DIR = BASE_DIR / "models" / "lightgbm_v1"
SCRIPTS_DIR = BASE_DIR / "scripts"


def run_script(script_path: Path) -> None:
    if not script_path.exists():
        raise FileNotFoundError(f"Script not found: {script_path}")

    print(f"\n>>> Running: {script_path}")
    result = subprocess.run([sys.executable, str(script_path)], cwd=str(BASE_DIR))
    if result.returncode != 0:
        raise RuntimeError(f"Step failed: {script_path}")


def data_steps():
    return [
        FETCH_DIR / "fetch_schedule.py",
        FETCH_DIR / "fetch_odds.py",
        FETCH_DIR / "match_odds_to_games.py",
        FETCH_DIR / "build_odds_features.py",
        FETCH_DIR / "build_upcoming_dataset.py",
        FETCH_DIR / "fetch_pitcher_stats.py",
    ]


def training_steps():
    return [
        FETCH_DIR / "fetch_game_results.py",
        FETCH_DIR / "build_dataset.py",
        MODEL_DIR / "train.py",
    ]


def prediction_steps():
    return [
        SCRIPTS_DIR / "predict_upcoming_games.py",
    ]


def main():
    parser = argparse.ArgumentParser(
        description="Run MLB pipeline scripts in sequence."
    )
    parser.add_argument(
        "--mode",
        choices=["data", "train", "predict", "full"],
        default="full",
        help=(
            "data: fetch/match/build upcoming data | "
            "train: refresh results/build training/train model | "
            "predict: run predictions only | "
            "full: data + train + predict"
        ),
    )
    args = parser.parse_args()

    steps = []
    if args.mode == "data":
        steps = data_steps()
    elif args.mode == "train":
        steps = training_steps()
    elif args.mode == "predict":
        steps = prediction_steps()
    elif args.mode == "full":
        steps = data_steps() + training_steps() + prediction_steps()

    print(f"Pipeline mode: {args.mode}")
    print(f"Total steps: {len(steps)}")

    for step in steps:
        run_script(step)

    print("\nPipeline completed successfully.")


if __name__ == "__main__":
    main()
