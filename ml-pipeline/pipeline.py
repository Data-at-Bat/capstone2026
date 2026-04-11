"""build unified MLB datasets. Prefer ``run_pipeline.py build`` for the full CLI."""

from __future__ import annotations

import argparse

from data.unified_dataset import PROCESSED_DIR, run_build


def main() -> None:
    parser = argparse.ArgumentParser(description="Build unified MLB dataset")
    parser.add_argument("--start-season", type=int, default=2024)
    parser.add_argument("--end-season", type=int, default=2024)
    parser.add_argument("--min-games", type=int, default=10,
                        help="Drop first N games per team (warm-up period)")
    args = parser.parse_args()

    run_build(
        args.start_season,
        args.end_season,
        min_games=args.min_games,
        processed_dir=PROCESSED_DIR,
    )


if __name__ == "__main__":
    main()
