package com.dataatbat.data_at_bat_api.persistence.repositories;

import com.dataatbat.data_at_bat_api.domain.GameEntity;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;

public interface IGamesRepository extends CrudRepository<GameEntity, UUID> {
    List<GameEntity> findByStatus(String status);

    @Query("SELECT g FROM GameEntity g WHERE g.status = :status AND (g.homeTeamId = :teamId OR g.awayTeamId = :teamId)")
    List<GameEntity> findByStatusAndTeamId(@Param("status") String status, @Param("teamId") UUID teamId);
    List<GameEntity> findByStatusAndHomeTeamId(String status, UUID HomeTeamId);
    List<GameEntity> findByStatusAndAwayTeamId(String status, UUID AwayTeamId);
    List<GameEntity> findByGameTimeBetweenOrderByGameTimeAsc(LocalDateTime startDate, LocalDateTime endDate);


    @Query("SELECT g FROM GameEntity g WHERE g.homeTeamId IN :ids OR g.awayTeamId IN :ids")
    List<GameEntity> findByTeamIds(@Param("ids") List<UUID> teamIds);
    List<GameEntity> findByHomeTeamIdIn(List<UUID> teamIds);
    List<GameEntity> findByAwayTeamIdIn(List<UUID> teamIds);

    @Query("SELECT g FROM GameEntity g WHERE g.gameTime <= :endDate AND g.gameTime >= :startDate" +
            " AND (g.homeTeamId IN :ids OR g.awayTeamId IN :ids)" +
            " ORDER BY g.gameTime ASC")
    List<GameEntity> findByGameTimeAndTeamId(@Param("startDate") LocalDateTime startDate,
                                                      @Param("endDate") LocalDateTime endDate,
                                                      @Param("ids") List<UUID> teamIds);
    void deleteByStatus(String status);

    @Modifying
    @Query("DELETE FROM GameEntity g WHERE g.homeTeamId IN :ids OR g.awayTeamId IN :ids")
    void deleteByTeamIdIn(@Param("ids") List<UUID> teamIds);
    void deleteByHomeTeamIdIn(List<UUID> homeTeamIds);
    void deleteByAwayTeamIdIn(List<UUID> awayTeamIds);

    @Modifying
    @Query("DELETE FROM GameEntity g WHERE g.homeTeamId = :teamId OR g.awayTeamId = :teamId")
    void deleteByTeamId(@Param("teamId") UUID teamId);
    void deleteByHomeTeamId(UUID homeTeamId);
    void deleteByAwayTeamId(UUID awayTeamId);
}
