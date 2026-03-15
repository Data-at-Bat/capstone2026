package com.dataabat.data_at_bat_api.presentation.presentation_models;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record GameResponse(
    UUID gameId,
    LocalDateTime gameTime,
    String homeTeamName,
    UUID homeTeamId,
    String awayTeamName,
    UUID awayTeamId,
    String predictedWinner,
    Double confidence,
    Double spread,
    Double odds,
    List<String> predictiveFactors
) {}