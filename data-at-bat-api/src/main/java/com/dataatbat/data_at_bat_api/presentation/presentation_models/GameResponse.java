package com.dataatbat.data_at_bat_api.presentation.presentation_models;

import java.time.LocalDateTime;
import java.util.UUID;

public record GameResponse(
    UUID gameId,
    LocalDateTime gameTime,
    String homeTeamName,
    String homeTeamId,
    String awayTeamName,
    String awayTeamId,
    String predictedWinner,
    Double confidence,
    Double spread,
    Double odds,
    String predictiveFactors
) {}