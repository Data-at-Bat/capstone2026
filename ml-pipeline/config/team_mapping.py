"""Static mappings between MLB StatsAPI and FanGraphs team identifiers.

FanGraphs abbreviations are the canonical team key across all datasets.
8 teams have non-obvious mappings: AZ->ARI, CWS->CHW, KC->KCR, ATH->OAK,
SD->SDP, SF->SFG, TB->TBR, WSH->WSN.
"""

# MLB full team name -> FanGraphs abbreviation (30 teams)
MLB_NAME_TO_FG: dict[str, str] = {
    "Arizona Diamondbacks": "ARI",
    "Atlanta Braves": "ATL",
    "Baltimore Orioles": "BAL",
    "Boston Red Sox": "BOS",
    "Chicago Cubs": "CHC",
    "Chicago White Sox": "CHW",
    "Cincinnati Reds": "CIN",
    "Cleveland Guardians": "CLE",
    "Cleveland Indians": "CLE",
    "Colorado Rockies": "COL",
    "Detroit Tigers": "DET",
    "Houston Astros": "HOU",
    "Kansas City Royals": "KCR",
    "Los Angeles Angels": "LAA",
    "Los Angeles Dodgers": "LAD",
    "Miami Marlins": "MIA",
    "Milwaukee Brewers": "MIL",
    "Minnesota Twins": "MIN",
    "New York Mets": "NYM",
    "New York Yankees": "NYY",
    "Athletics": "OAK",
    "Oakland Athletics": "OAK",
    "Philadelphia Phillies": "PHI",
    "Pittsburgh Pirates": "PIT",
    "San Diego Padres": "SDP",
    "San Francisco Giants": "SFG",
    "Seattle Mariners": "SEA",
    "St. Louis Cardinals": "STL",
    "Tampa Bay Rays": "TBR",
    "Texas Rangers": "TEX",
    "Toronto Blue Jays": "TOR",
    "Washington Nationals": "WSN",
}

# MLB StatsAPI numeric team ID -> FanGraphs abbreviation
MLB_ID_TO_FG: dict[int, str] = {
    109: "ARI",
    144: "ATL",
    110: "BAL",
    111: "BOS",
    112: "CHC",
    145: "CHW",
    113: "CIN",
    114: "CLE",
    115: "COL",
    116: "DET",
    117: "HOU",
    118: "KCR",
    108: "LAA",
    119: "LAD",
    146: "MIA",
    158: "MIL",
    142: "MIN",
    121: "NYM",
    147: "NYY",
    133: "OAK",
    143: "PHI",
    134: "PIT",
    135: "SDP",
    137: "SFG",
    136: "SEA",
    138: "STL",
    139: "TBR",
    140: "TEX",
    141: "TOR",
    120: "WSN",
}

# Reverse: FanGraphs abbreviation -> MLB StatsAPI numeric team ID
FG_TO_MLB_ID: dict[str, int] = {v: k for k, v in MLB_ID_TO_FG.items()}
