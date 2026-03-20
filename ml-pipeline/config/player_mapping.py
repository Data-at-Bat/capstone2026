"""Player ID mapping between MLBAM and FanGraphs via Chadwick register.

Infrastructure for future per-pitcher and Statcast joins.
"""

from __future__ import annotations

import pandas as pd
from pybaseball import chadwick_register

_CACHE: pd.DataFrame | None = None


def build_id_map() -> pd.DataFrame:
    """Download/cache Chadwick register, return DataFrame with key columns."""
    global _CACHE
    if _CACHE is not None:
        return _CACHE

    reg = chadwick_register()
    cols = ["key_mlbam", "key_fangraphs", "name_last", "name_first"]
    df = reg[cols].dropna(subset=["key_mlbam", "key_fangraphs"]).copy()
    df["key_mlbam"] = df["key_mlbam"].astype(int)
    df["key_fangraphs"] = df["key_fangraphs"].astype(int)
    _CACHE = df
    return df


def mlbam_to_fg(mlbam_ids: list[int]) -> dict[int, int]:
    """Batch lookup MLBAM -> FanGraphs IDs."""
    df = build_id_map()
    subset = df[df["key_mlbam"].isin(mlbam_ids)]
    return dict(zip(subset["key_mlbam"], subset["key_fangraphs"]))


def fg_to_mlbam(fg_ids: list[int]) -> dict[int, int]:
    """Batch lookup FanGraphs -> MLBAM IDs."""
    df = build_id_map()
    subset = df[df["key_fangraphs"].isin(fg_ids)]
    return dict(zip(subset["key_fangraphs"], subset["key_mlbam"]))
