package com.dataabat.data_at_bat_api.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name="prediction")
public class PredictionEntity {
    @Id
    @Getter
    @GeneratedValue(strategy= GenerationType.AUTO)
    @Column(name="prediction_id")
    private UUID predictionId;

    @Getter
    @Setter
    @Column(name="game_id", nullable = false)
    private UUID gameId;

    @Getter
    @Setter
    @Column(name="model_version", length=50, nullable = false)
    private String modelVersion;

    @Getter
    @Setter
    @Column(name="home_win_prob", nullable = false)
    private Double homeWinProbability;

    @Getter
    @Setter
    @Column(name="away_win_prob", nullable = false)
    private Double awayWinProbability;

    @Getter
    @Setter
    @Column(name="predicted_winner", nullable = false)
    private UUID predictedWinner;

    @Getter
    @Setter
    @Column(name="created_at")
    private LocalDateTime createdAt;

    protected PredictionEntity() {}

    public PredictionEntity(UUID gameId,String modelVersion, Double homeWinProbability, Double awayWinProbability, UUID predictedWinner) {
        this.gameId = gameId;
        this.modelVersion = modelVersion;
        this.homeWinProbability = homeWinProbability;
        this.awayWinProbability = awayWinProbability;
        this.predictedWinner = predictedWinner;
    }

}
