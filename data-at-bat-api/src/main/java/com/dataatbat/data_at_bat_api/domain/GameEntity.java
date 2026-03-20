package com.dataatbat.data_at_bat_api.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "game")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GameEntity {

    @Id
    @Column(name = "GameID", nullable = false)
    private UUID gameId;

    @Column(name = "GameTime", nullable = false)
    private LocalDateTime gameTime;

    @Column(name = "HomeTeamID", nullable = false)
    private String homeTeamId;

    @Column(name = "HomeTeamName")
    private String homeTeamName;

    @Column(name = "AwayTeamID", nullable = false)
    private String awayTeamId;

    @Column(name = "AwayTeamName")
    private String awayTeamName;

    @Column(name = "PredictedWinner")
    private String predictedWinner;

    @Column(name = "Confidence")
    private Double confidence;

    @Column(name = "Spread")
    private Double spread;

    @Column(name = "Odds")
    private Double odds;

    @Column(name="PredictiveFactors")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> predictiveFactors;
}