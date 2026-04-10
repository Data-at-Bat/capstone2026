#!/usr/bin/env python3
"""orchestrates dataset build, training, and predictions with edge.

Usage Examples
    python run_pipeline.py build --start-season 2015 --end-season 2024
    python run_pipeline.py train
    python run_pipeline.py predict
    python run_pipeline.py predict --season 2024
    python run_pipeline.py full --start-season 2015 --end-season 2024
"""

from __future__ import annotations

import argparse
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from data.unified_dataset import PROCESSED_DIR, run_build  # noqa: E402


def _cmd_build(args: argparse.Namespace) -> None:
    run_build(
        args.start_season,
        args.end_season,
        min_games=args.min_games,
        processed_dir=Path(args.processed_dir) if args.processed_dir else PROCESSED_DIR,
    )


def _cmd_train(args: argparse.Namespace) -> None:
    from models.lightgbm_v1.train import DEFAULT_UNIFIED_PATH, train

    unified = Path(args.unified) if args.unified else DEFAULT_UNIFIED_PATH
    train(
        unified,
        train_end_season=args.train_end_season,
        test_start_season=args.test_start_season,
        save=True,
    )


def _parse_predict_date(s: str):
    return datetime.strptime(s.strip(), "%Y-%m-%d").date()


def _cmd_predict(args: argparse.Namespace) -> None:
    from models.lightgbm_v1.predict import DEFAULT_PREDICTIONS_PATH, run_predict

    slate_day = _parse_predict_date(args.predict_date) if getattr(args, "predict_date", "") else None

    run_predict(
        unified_path=Path(args.unified) if args.unified else None,
        odds_path=Path(args.odds) if args.odds else None,
        output_path=Path(args.output) if args.output else DEFAULT_PREDICTIONS_PATH,
        season=args.season,
        upcoming_season=args.upcoming_season,
        upcoming_csv=Path(args.upcoming_csv) if getattr(args, "upcoming_csv", "") else None,
        prefer_upcoming_file=not getattr(args, "api_schedule", False),
        predict_date=slate_day,
    )


def _cmd_full(args: argparse.Namespace) -> None:
    _cmd_build(args)
    _cmd_train(args)
    _cmd_predict(args)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="ML pipeline: build unified data, train, predict with edge",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    def add_build_flags(p: argparse.ArgumentParser) -> None:
        p.add_argument("--start-season", type=int, default=2024)
        p.add_argument("--end-season", type=int, default=2024)
        p.add_argument("--min-games", type=int, default=10)
        p.add_argument(
            "--processed-dir",
            type=str,
            default="",
            help="Override processed output directory (default: data/processed)",
        )

    build_p = sub.add_parser("build", help="Fetch data and write unified_*.csv + unified_all.csv")
    add_build_flags(build_p)
    build_p.set_defaults(func=_cmd_build)

    train_p = sub.add_parser("train", help="Train LightGBM on unified_all.csv; save model + features")
    train_p.add_argument("--unified", type=str, default="", help="Path to unified_all.csv")
    train_p.add_argument("--train-end-season", type=int, default=2022)
    train_p.add_argument("--test-start-season", type=int, default=2023)
    train_p.set_defaults(func=_cmd_train)

    pred_p = sub.add_parser(
        "predict",
        help="Default: upcoming slate (upcoming_games_with_odds.csv if present, else API schedule). "
        "Use --season for historical rows from unified_all.",
    )
    pred_p.add_argument("--unified", type=str, default="", help="Path to unified_all.csv (historical)")
    pred_p.add_argument("--odds", type=str, default="", help="Path to odds_features.csv")
    pred_p.add_argument(
        "--output",
        type=str,
        default="",
        help="Output CSV (default: data/processed/predictions.csv)",
    )
    pred_p.add_argument(
        "--season",
        type=int,
        default=None,
        help="Historical mode: filter unified data to this season (disables upcoming slate)",
    )
    pred_p.add_argument(
        "--upcoming-season",
        type=int,
        default=None,
        help="MLB season for team logs in upcoming mode (default: current calendar year)",
    )
    pred_p.add_argument(
        "--upcoming-csv",
        type=str,
        default="",
        help="Spine games CSV (default: use processed/upcoming_games_with_odds.csv when present)",
    )
    pred_p.add_argument(
        "--api-schedule",
        action="store_true",
        help="Upcoming mode: fetch schedule from API; do not use upcoming_games_with_odds.csv",
    )
    pred_p.add_argument(
        "--predict-date",
        type=str,
        default="",
        help="Upcoming mode: slate date YYYY-MM-DD (default: today, local date)",
    )
    pred_p.set_defaults(func=_cmd_predict)

    full_p = sub.add_parser("full", help="build + train + predict")
    add_build_flags(full_p)
    full_p.add_argument("--unified", type=str, default="", help="Path to unified_all.csv (predict step)")
    full_p.add_argument("--odds", type=str, default="", help="Path to odds_features.csv")
    full_p.add_argument("--output", type=str, default="", help="predictions.csv path")
    full_p.add_argument("--season", type=int, default=None)
    full_p.add_argument("--upcoming-season", type=int, default=None)
    full_p.add_argument("--upcoming-csv", type=str, default="")
    full_p.add_argument("--api-schedule", action="store_true")
    full_p.add_argument("--predict-date", type=str, default="")
    full_p.add_argument("--train-end-season", type=int, default=2022)
    full_p.add_argument("--test-start-season", type=int, default=2023)
    full_p.set_defaults(func=_cmd_full)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
