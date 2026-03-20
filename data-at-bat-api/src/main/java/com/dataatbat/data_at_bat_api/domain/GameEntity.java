package com.dataatbat.data_at_bat_api.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "game")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor


public class GameEntity {

    @Id
    @Column(name = "gameid")
    private UUID gameId;

    @Column(name = "game_time", nullable = false)
    private LocalDateTime gameTime;

    @Column(name = "home_teamid")
    private String homeTeamId;

    @Column(name = "away_teamid")
    private String awayTeamId;

    @Column(name = "home_team_name")
    private String homeTeamName;

    @Column(name = "away_team_name")
    private String awayTeamName;

    @Column(name = "predicted_winner")
    private String predictedWinner;

    @Column(name = "confidence")
    private Double confidence;

    @Column(name = "spread")
    private Double spread;

    @Column(name = "odds")
    private Double odds;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "predictive_factors")
    private String predictiveFactors;

    public void partialUpdate(GameEntity game) {
        if (game.getGameTime() != null) setGameTime(game.getGameTime());
        if (game.getHomeTeamId() != null) setHomeTeamId(game.getHomeTeamId());
        if (game.getAwayTeamId() != null) setAwayTeamId(game.getAwayTeamId());
        if (game.getHomeTeamName() != null) setHomeTeamName(game.getHomeTeamName());
        if (game.getAwayTeamName() != null) setAwayTeamName(game.getAwayTeamName());
        if (game.getPredictedWinner() != null) setPredictedWinner(game.getPredictedWinner());
        if (game.getConfidence() != null) setConfidence(game.getConfidence());
        if (game.getSpread() != null) setSpread(game.getSpread());
        if (game.getOdds() != null) setOdds(game.getOdds());
        if (game.getPredictiveFactors() != null) setPredictiveFactors(game.getPredictiveFactors());
    }
}