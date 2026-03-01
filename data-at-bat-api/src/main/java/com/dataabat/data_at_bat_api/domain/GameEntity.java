package com.dataabat.data_at_bat_api.domain;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "game")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GameEntity {

    @Id
    @Column(name = "game_id", length = 128, nullable = false)
    private UUID gameId;

    @Column(name = "game_time", nullable = false)
    private LocalDateTime gameTime;

    @Column(name = "home_team_id", length = 50, nullable = false)
    private UUID homeTeamId;

    @Column(name = "away_team_id", length = 50, nullable = false)
    private UUID awayTeamId;

    @Column(name = "status", length = 50)
    private String status;

    @Column(name = "final_score_home")
    private Integer finalScoreHome;

    @Column(name = "final_score_away")
    private Integer finalScoreAway;
}