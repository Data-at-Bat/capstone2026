import pandas as pd
import numpy as np

from features.team_stats import aggregate_batting, aggregate_pitching, build_team_features


def _make_batting_df():
    """Minimal batting DataFrame that mimics FanGraphs output."""
    return pd.DataFrame([
        {"Team": "NYY", "Season": 2024, "WAR": 5.0, "R": 100, "HR": 30,
         "RBI": 90, "SB": 10, "BB": 50, "SO": 120, "PA": 600, "AB": 540,
         "AVG": 0.280, "OBP": 0.350, "SLG": 0.500, "OPS": 0.850,
         "wOBA": 0.370, "wRC+": 130},
        {"Team": "NYY", "Season": 2024, "WAR": 3.0, "R": 80, "HR": 20,
         "RBI": 70, "SB": 5, "BB": 40, "SO": 100, "PA": 500, "AB": 450,
         "AVG": 0.260, "OBP": 0.330, "SLG": 0.450, "OPS": 0.780,
         "wOBA": 0.340, "wRC+": 115},
        {"Team": "- - -", "Season": 2024, "WAR": 1.0, "R": 20, "HR": 5,
         "RBI": 15, "SB": 2, "BB": 10, "SO": 30, "PA": 100, "AB": 85,
         "AVG": 0.250, "OBP": 0.310, "SLG": 0.400, "OPS": 0.710,
         "wOBA": 0.310, "wRC+": 100},
        {"Team": "BOS", "Season": 2024, "WAR": 4.0, "R": 90, "HR": 25,
         "RBI": 80, "SB": 8, "BB": 45, "SO": 110, "PA": 550, "AB": 500,
         "AVG": 0.270, "OBP": 0.340, "SLG": 0.480, "OPS": 0.820,
         "wOBA": 0.360, "wRC+": 125},
    ])


def _make_pitching_df():
    """Minimal pitching DataFrame that mimics FanGraphs output."""
    return pd.DataFrame([
        {"Team": "NYY", "Season": 2024, "WAR": 4.0, "W": 12, "L": 5,
         "SO": 180, "BB": 50, "HR": 15, "ER": 60, "IP": 180.0, "TBF": 730,
         "ERA": 3.00, "FIP": 3.10, "WHIP": 1.10, "K/9": 9.0, "BB/9": 2.5,
         "K%": 0.246, "BB%": 0.068},
        {"Team": "NYY", "Season": 2024, "WAR": 2.0, "W": 8, "L": 6,
         "SO": 120, "BB": 40, "HR": 12, "ER": 50, "IP": 140.0, "TBF": 580,
         "ERA": 3.21, "FIP": 3.40, "WHIP": 1.15, "K/9": 7.7, "BB/9": 2.6,
         "K%": 0.207, "BB%": 0.069},
        {"Team": "- - -", "Season": 2024, "WAR": 0.5, "W": 2, "L": 1,
         "SO": 30, "BB": 10, "HR": 3, "ER": 12, "IP": 30.0, "TBF": 130,
         "ERA": 3.60, "FIP": 3.80, "WHIP": 1.20, "K/9": 9.0, "BB/9": 3.0,
         "K%": 0.231, "BB%": 0.077},
        {"Team": "BOS", "Season": 2024, "WAR": 3.5, "W": 10, "L": 7,
         "SO": 150, "BB": 45, "HR": 14, "ER": 55, "IP": 160.0, "TBF": 660,
         "ERA": 3.09, "FIP": 3.25, "WHIP": 1.12, "K/9": 8.4, "BB/9": 2.5,
         "K%": 0.227, "BB%": 0.068},
    ])


def test_aggregate_batting_excludes_traded():
    df = aggregate_batting(_make_batting_df())
    assert "- - -" not in df["Team"].values


def test_aggregate_batting_sums():
    df = aggregate_batting(_make_batting_df())
    nyy = df[df["Team"] == "NYY"].iloc[0]
    assert nyy["batting_PA"] == 1100  # 600 + 500
    assert nyy["batting_HR"] == 50    # 30 + 20


def test_aggregate_batting_weighted_avg():
    df = aggregate_batting(_make_batting_df())
    nyy = df[df["Team"] == "NYY"].iloc[0]
    # PA-weighted AVG: (0.280*600 + 0.260*500) / 1100
    expected = (0.280 * 600 + 0.260 * 500) / 1100
    assert abs(nyy["batting_AVG"] - expected) < 1e-6


def test_aggregate_pitching_excludes_traded():
    df = aggregate_pitching(_make_pitching_df())
    assert "- - -" not in df["Team"].values


def test_aggregate_pitching_sums():
    df = aggregate_pitching(_make_pitching_df())
    nyy = df[df["Team"] == "NYY"].iloc[0]
    assert nyy["pitching_W"] == 20   # 12 + 8
    assert nyy["pitching_SO"] == 300  # 180 + 120


def test_aggregate_pitching_weighted_avg():
    df = aggregate_pitching(_make_pitching_df())
    nyy = df[df["Team"] == "NYY"].iloc[0]
    # TBF-weighted ERA: (3.00*730 + 3.21*580) / 1310
    expected = (3.00 * 730 + 3.21 * 580) / 1310
    assert abs(nyy["pitching_ERA"] - expected) < 1e-6


def test_build_team_features_teams():
    batting = _make_batting_df()
    pitching = _make_pitching_df()
    df = build_team_features(batting, pitching)
    teams = set(df["Team"].values)
    assert teams == {"NYY", "BOS"}  # no "- - -"


def test_build_team_features_has_both_prefixes():
    batting = _make_batting_df()
    pitching = _make_pitching_df()
    df = build_team_features(batting, pitching)
    cols = df.columns.tolist()
    assert any(c.startswith("batting_") for c in cols)
    assert any(c.startswith("pitching_") for c in cols)
