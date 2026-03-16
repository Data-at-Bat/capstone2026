package com.dataabat.data_at_bat_api.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "game")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GameEntity {

    @Id
    @Column(name = "game_id")
    @Getter
    private UUID gameId;

    @Column(name = "game_time", nullable = false)
    @Getter
    @Setter
    private LocalDateTime gameTime;

    @Column(name = "home_team_id", nullable = false)
    @Getter
    @Setter
    private UUID homeTeamId;

    @Column(name = "away_team_id", nullable = false)
    @Getter
    @Setter
    private UUID awayTeamId;

    @Column(name = "status", length = 50)
    @Getter
    @Setter
    private String status;

    @Column(name = "final_score_home")
    @Getter
    @Setter
    private Integer finalScoreHome;

    @Column(name = "final_score_away")
    @Getter
    @Setter
    private Integer finalScoreAway;

    @Getter
    @Setter
    @Column(name="game_features", nullable = false)
    @JdbcTypeCode(SqlTypes.JSON)
    private Map<String, Object> gameFeatures;

    @Column(name="game_features_last_updated")
    @Getter
    @Setter
    private LocalDateTime gameFeaturesLastUpdated;
    
    public void partialUpdate(GameEntity game) {
    if (game.getGameTime() != null) setGameTime(game.getGameTime());
    if (game.getHomeTeamId() != null) setHomeTeamId(game.getHomeTeamId());
    if (game.getAwayTeamId() != null) setAwayTeamId(game.getAwayTeamId());
    if (game.getStatus() != null) setStatus(game.getStatus());
    if (game.getFinalScoreHome() != null) setFinalScoreHome(game.getFinalScoreHome());
    if (game.getFinalScoreAway() != null) setFinalScoreAway(game.getFinalScoreAway());
    if (game.getGameFeatures() != null) setGameFeatures(game.getGameFeatures());
    if (game.getGameFeaturesLastUpdated() != null) setGameFeaturesLastUpdated(game.getGameFeaturesLastUpdated());
}
}