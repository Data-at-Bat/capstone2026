package com.dataabat.data_at_bat_api.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface GameRepository extends JpaRepository<GameEntity, String> {

    // Find all games with a given status
    @Query("SELECT g FROM GameEntity g WHERE g.status = :status")
    List<GameEntity> findByStatus(@Param("status") String status);

    // Find all games matching both a status and a team
    @Query("""
            SELECT g FROM GameEntity g
            WHERE g.status = :status
              AND (g.homeTeamId = :teamId OR g.awayTeamId = :teamId)
            """)
    List<GameEntity> findByStatusAndTeamId(
            @Param("status") String status,
            @Param("teamId") String teamId
    );

    // Find all games involving any of the given teams
    @Query("""
            SELECT g FROM GameEntity g
            WHERE g.homeTeamId IN :teamIds OR g.awayTeamId IN :teamIds
            """)
    List<GameEntity> findByTeamIds(@Param("teamIds") List<String> teamIds);

    // Find all games within a date range, involving any of the given teams
    @Query("""
        SELECT g FROM GameEntity g
        WHERE g.gameTime BETWEEN :startDate AND :endDate
          AND (g.homeTeamId IN :teamIds OR g.awayTeamId IN :teamIds)
        """)
        List<GameEntity> findByDateRangeAndTeams(
                @Param("startDate") LocalDateTime startDate,
                @Param("endDate") LocalDateTime endDate,
                @Param("teamIds") List<String> teamIds
        );

    // Delete a game by id — true if deleted, false if not found
    default boolean removeById(String gameId) {
        if (!existsById(gameId)) return false;
        deleteById(gameId);
        return true;
    }

    // Delete all games with a given status — returns count deleted
    @Modifying
    @Transactional
    @Query("DELETE FROM GameEntity g WHERE g.status = :status")
    int removeByStatus(@Param("status") String status);

    // Delete all games involving a specific team — returns count deleted
    @Modifying
    @Transactional
    @Query("DELETE FROM GameEntity g WHERE g.homeTeamId = :teamId OR g.awayTeamId = :teamId")
    int removeByTeamId(@Param("teamId") String teamId);
}