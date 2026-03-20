from config.team_mapping import MLB_NAME_TO_FG, MLB_ID_TO_FG, FG_TO_MLB_ID


def test_30_teams_in_name_mapping():
    # 31 entries because both "Athletics" and "Oakland Athletics" map to OAK
    unique_fg = set(MLB_NAME_TO_FG.values())
    assert len(unique_fg) == 30


def test_30_teams_in_id_mapping():
    assert len(MLB_ID_TO_FG) == 30


def test_round_trip_id_to_fg_to_id():
    for mlb_id, fg_abbr in MLB_ID_TO_FG.items():
        assert FG_TO_MLB_ID[fg_abbr] == mlb_id


def test_mismatch_mappings():
    """The 8 non-obvious team abbreviation mappings."""
    expected = {
        "Arizona Diamondbacks": "ARI",    # not AZ
        "Chicago White Sox": "CHW",       # not CWS
        "Kansas City Royals": "KCR",      # not KC
        "Athletics": "OAK",               # ATH -> OAK
        "San Diego Padres": "SDP",        # not SD
        "San Francisco Giants": "SFG",    # not SF
        "Tampa Bay Rays": "TBR",          # not TB
        "Washington Nationals": "WSN",    # not WSH
    }
    for name, fg in expected.items():
        assert MLB_NAME_TO_FG[name] == fg, f"{name} should map to {fg}"


def test_oakland_both_names():
    assert MLB_NAME_TO_FG["Oakland Athletics"] == "OAK"
    assert MLB_NAME_TO_FG["Athletics"] == "OAK"


def test_fg_to_mlb_id_completeness():
    assert len(FG_TO_MLB_ID) == 30
    for fg_abbr in FG_TO_MLB_ID:
        assert fg_abbr in MLB_ID_TO_FG.values()
