import pandas as pd
import numpy as np
import math

from features.team_stats import (
    compute_cumulative_batting,
    compute_cumulative_pitching,
    build_team_features,
)


def _make_batting_logs():
    """5-game batting log for a single team with known values."""
    return pd.DataFrame([
        {"Team": "NYY", "date": "2024-04-01", "game_id": 1,
         "runs": 5, "hits": 10, "homeRuns": 2, "baseOnBalls": 3,
         "strikeOuts": 8, "plateAppearances": 38, "atBats": 34,
         "doubles": 2, "triples": 0, "rbi": 5, "stolenBases": 1,
         "hitByPitch": 1},
        {"Team": "NYY", "date": "2024-04-02", "game_id": 2,
         "runs": 3, "hits": 7, "homeRuns": 1, "baseOnBalls": 2,
         "strikeOuts": 10, "plateAppearances": 35, "atBats": 32,
         "doubles": 1, "triples": 1, "rbi": 3, "stolenBases": 0,
         "hitByPitch": 0},
        {"Team": "NYY", "date": "2024-04-03", "game_id": 3,
         "runs": 8, "hits": 14, "homeRuns": 3, "baseOnBalls": 5,
         "strikeOuts": 6, "plateAppearances": 42, "atBats": 36,
         "doubles": 3, "triples": 0, "rbi": 7, "stolenBases": 2,
         "hitByPitch": 1},
        {"Team": "NYY", "date": "2024-04-04", "game_id": 4,
         "runs": 1, "hits": 4, "homeRuns": 0, "baseOnBalls": 1,
         "strikeOuts": 12, "plateAppearances": 33, "atBats": 31,
         "doubles": 0, "triples": 0, "rbi": 1, "stolenBases": 0,
         "hitByPitch": 1},
        {"Team": "NYY", "date": "2024-04-05", "game_id": 5,
         "runs": 6, "hits": 11, "homeRuns": 2, "baseOnBalls": 4,
         "strikeOuts": 7, "plateAppearances": 40, "atBats": 35,
         "doubles": 2, "triples": 1, "rbi": 6, "stolenBases": 1,
         "hitByPitch": 0},
    ])


def _make_pitching_logs():
    """5-game pitching log for a single team with known values."""
    return pd.DataFrame([
        {"Team": "NYY", "date": "2024-04-01", "game_id": 1,
         "inningsPitched": 9.0, "hits": 6, "runs": 3, "earnedRuns": 2,
         "baseOnBalls": 2, "strikeOuts": 10, "homeRuns": 1,
         "battersFaced": 35},
        {"Team": "NYY", "date": "2024-04-02", "game_id": 2,
         "inningsPitched": 9.0, "hits": 8, "runs": 5, "earnedRuns": 4,
         "baseOnBalls": 3, "strikeOuts": 7, "homeRuns": 2,
         "battersFaced": 38},
        {"Team": "NYY", "date": "2024-04-03", "game_id": 3,
         "inningsPitched": 9.0, "hits": 4, "runs": 1, "earnedRuns": 1,
         "baseOnBalls": 1, "strikeOuts": 12, "homeRuns": 0,
         "battersFaced": 32},
        {"Team": "NYY", "date": "2024-04-04", "game_id": 4,
         "inningsPitched": 9.0, "hits": 10, "runs": 7, "earnedRuns": 6,
         "baseOnBalls": 4, "strikeOuts": 5, "homeRuns": 3,
         "battersFaced": 42},
        {"Team": "NYY", "date": "2024-04-05", "game_id": 5,
         "inningsPitched": 9.0, "hits": 7, "runs": 4, "earnedRuns": 3,
         "baseOnBalls": 2, "strikeOuts": 8, "homeRuns": 1,
         "battersFaced": 36},
    ])


# ── Tests ────────────────────────────────────────────────────────────

def test_first_game_batting_is_nan():
    """First game of a season should have NaN cumulative batting features."""
    df = compute_cumulative_batting(_make_batting_logs())
    first = df.iloc[0]
    assert math.isnan(first["batting_AVG"]), "First game should have NaN batting_AVG"
    assert math.isnan(first["batting_OBP"]), "First game should have NaN batting_OBP"


def test_first_game_pitching_is_nan():
    """First game of a season should have NaN cumulative pitching features."""
    df = compute_cumulative_pitching(_make_pitching_logs())
    first = df.iloc[0]
    assert math.isnan(first["pitching_ERA"]), "First game should have NaN pitching_ERA"


def test_no_future_leakage_batting():
    """Game 3's batting features should only reflect games 1 and 2."""
    df = compute_cumulative_batting(_make_batting_logs())
    game3 = df[df["game_id"] == 3].iloc[0]

    # Games 1+2: hits=10+7=17, atBats=34+32=66
    expected_avg = 17 / 66
    assert abs(game3["batting_AVG"] - expected_avg) < 1e-6, (
        f"Game 3 AVG should be {expected_avg}, got {game3['batting_AVG']}"
    )


def test_no_future_leakage_pitching():
    """Game 3's pitching features should only reflect games 1 and 2."""
    df = compute_cumulative_pitching(_make_pitching_logs())
    game3 = df[df["game_id"] == 3].iloc[0]

    # Games 1+2: earnedRuns=2+4=6, IP=9+9=18
    expected_era = 9.0 * 6 / 18
    assert abs(game3["pitching_ERA"] - expected_era) < 1e-6, (
        f"Game 3 ERA should be {expected_era}, got {game3['pitching_ERA']}"
    )


def test_cumulative_batting_avg_progression():
    """Verify AVG accumulates correctly across games."""
    df = compute_cumulative_batting(_make_batting_logs())

    # Game 2: only sees game 1 → AVG = 10/34
    game2 = df[df["game_id"] == 2].iloc[0]
    assert abs(game2["batting_AVG"] - 10 / 34) < 1e-6

    # Game 4: sees games 1-3 → AVG = (10+7+14)/(34+32+36) = 31/102
    game4 = df[df["game_id"] == 4].iloc[0]
    assert abs(game4["batting_AVG"] - 31 / 102) < 1e-6


def test_cumulative_era_formula():
    """Verify ERA = 9 * ΣER / ΣIP across cumulated games."""
    df = compute_cumulative_pitching(_make_pitching_logs())

    # Game 5: sees games 1-4
    # ER: 2+4+1+6=13, IP: 36
    game5 = df[df["game_id"] == 5].iloc[0]
    expected = 9.0 * 13 / 36
    assert abs(game5["pitching_ERA"] - expected) < 1e-6


def test_cumulative_whip_formula():
    """Verify WHIP = (ΣH + ΣBB) / ΣIP."""
    df = compute_cumulative_pitching(_make_pitching_logs())

    # Game 4: sees games 1-3
    # H: 6+8+4=18, BB: 2+3+1=6, IP: 27
    game4 = df[df["game_id"] == 4].iloc[0]
    expected = (18 + 6) / 27
    assert abs(game4["pitching_WHIP"] - expected) < 1e-6


def test_build_team_features_drops_warmup():
    """build_team_features should drop the first min_games games."""
    bat = _make_batting_logs()
    pit = _make_pitching_logs()

    result = build_team_features(bat, pit, min_games=3)
    # 5 games - 3 warm-up = 2 remaining
    assert len(result) == 2
    assert set(result["game_id"]) == {4, 5}


def test_build_team_features_has_both_prefixes():
    """Combined features should have both batting_ and pitching_ columns."""
    bat = _make_batting_logs()
    pit = _make_pitching_logs()

    result = build_team_features(bat, pit, min_games=0)
    cols = result.columns.tolist()
    assert any(c.startswith("batting_") for c in cols)
    assert any(c.startswith("pitching_") for c in cols)


def test_two_teams_independent():
    """Cumulative stats for team A should not bleed into team B."""
    bat_a = _make_batting_logs()
    bat_b = _make_batting_logs().copy()
    bat_b["Team"] = "BOS"
    bat_b["runs"] = 0  # BOS scores 0 runs every game

    combined = pd.concat([bat_a, bat_b], ignore_index=True)
    df = compute_cumulative_batting(combined)

    # NYY game 2 should still see game 1's 5 runs
    nyy_g2 = df[(df["Team"] == "NYY") & (df["game_id"] == 2)].iloc[0]
    assert abs(nyy_g2["batting_R_per_game"] - 5.0) < 1e-6

    # BOS game 2 should see game 1's 0 runs
    bos_g2 = df[(df["Team"] == "BOS") & (df["game_id"] == 2)].iloc[0]
    assert abs(bos_g2["batting_R_per_game"] - 0.0) < 1e-6
