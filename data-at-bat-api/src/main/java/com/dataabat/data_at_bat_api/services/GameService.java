package com.dataabat.data_at_bat_api.services;

import com.dataabat.data_at_bat_api.domain.GameEntity;
import com.dataabat.data_at_bat_api.domain.TeamEntity;
import com.dataabat.data_at_bat_api.persistence.repositories.IGamesRepository;
import com.dataabat.data_at_bat_api.persistence.repositories.ITeamsRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.Optional;

@Service
public class GameService {

    private final IGamesRepository gamesRepository;
    private final ITeamsRepository teamsRepository;

    public GameService(IGamesRepository gamesRepository, ITeamsRepository teamsRepository) {
        this.gamesRepository = gamesRepository;
        this.teamsRepository = teamsRepository;
    }

    // GET /games
    public List<GameEntity> getGames(LocalDateTime startDate, LocalDateTime endDate, List<UUID> teamIds) {
    if (startDate == null) startDate = LocalDateTime.now().minusMonths(1);
    if (endDate == null) endDate = LocalDateTime.now().plusWeeks(1);

    if (teamIds == null || teamIds.isEmpty()) {
        // Return all games in the date range without team filter
        return gamesRepository.findByGameTimeBetweenOrderByGameTimeAsc(startDate, endDate);
    }
    return gamesRepository.findByGameTimeAndTeamId(startDate, endDate, teamIds);
}

    // GET /games?id={id}
    public Optional<GameEntity> getGameById(UUID id) {
        return gamesRepository.findById(id);
    }

    // POST /games
    public GameEntity createGame(LocalDateTime gameTime, UUID homeTeamId, UUID awayTeamId) {
        GameEntity game = GameEntity.builder()
                .gameId(UUID.randomUUID())
                .gameTime(gameTime)
                .homeTeamId(homeTeamId)
                .awayTeamId(awayTeamId)
                .status("scheduled")
                .gameFeatures(new java.util.HashMap<>())
                .build();
        return gamesRepository.save(game);
    }

    // PATCH /games?id={id}
    public Optional<GameEntity> updateGame(UUID id, LocalDateTime gameTime, UUID homeTeamId, UUID awayTeamId) {
        Optional<GameEntity> existing = gamesRepository.findById(id);
        if (existing.isEmpty()) return Optional.empty();

        GameEntity game = existing.get();
        if (gameTime != null) game.setGameTime(gameTime);
        if (homeTeamId != null) game.setHomeTeamId(homeTeamId);
        if (awayTeamId != null) game.setAwayTeamId(awayTeamId);

        return Optional.of(gamesRepository.save(game));
    }

    // DELETE /games?id={id}
    public boolean deleteGame(UUID id) {
        if (!gamesRepository.existsById(id)) return false;
        gamesRepository.deleteById(id);
        return true;
    }

    // Helper to get team name by ID
    public String getTeamName(UUID teamId) {
        return teamsRepository.findById(teamId)
                .map(TeamEntity::getName)
                .orElse("Unknown");
    }
}