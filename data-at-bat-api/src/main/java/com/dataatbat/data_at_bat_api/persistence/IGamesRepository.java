package com.dataatbat.data_at_bat_api.persistence;

import com.dataatbat.data_at_bat_api.domain.GameEntity;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface IGamesRepository extends CrudRepository<GameEntity, UUID> {

    // Used when fetching all games within a date range
    List<GameEntity> findByGameTimeBetweenOrderByGameTimeAsc(LocalDateTime startDate, LocalDateTime endDate);

    // Used when fetching games for specific teams within a date range
    @Query("SELECT g FROM GameEntity g WHERE g.gameTime <= :endDate AND g.gameTime >= :startDate" +
            " AND (g.homeTeamId IN :ids OR g.awayTeamId IN :ids)" +
            " ORDER BY g.gameTime ASC")
    List<GameEntity> findByGameTimeAndTeamId(
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate,
            @Param("ids") List<String> teamIds
    );
}