package com.dataatbat.data_at_bat_api.services;

import com.dataatbat.data_at_bat_api.domain.GameEntity;
import com.dataatbat.data_at_bat_api.domain.TeamEntity;
import com.dataatbat.data_at_bat_api.persistence.repositories.IGamesRepository;
import com.dataatbat.data_at_bat_api.persistence.repositories.ITeamsRepository;
import com.dataatbat.data_at_bat_api.presentation.presentation_models.GameResponse;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class GameService {

    private final IGamesRepository gamesRepository;
    private final ITeamsRepository teamsRepository;

    public GameService(IGamesRepository gamesRepository, ITeamsRepository teamsRepository) {
        this.gamesRepository = gamesRepository;
        this.teamsRepository = teamsRepository;
    }

    public List<GameResponse> getGames(LocalDateTime startDate, LocalDateTime endDate, List<UUID> teamIds) {
        if (startDate == null) startDate = LocalDateTime.now().minusMonths(1);
        if (endDate == null) endDate = LocalDateTime.now().plusWeeks(1);

        List<GameEntity> games;
        if (teamIds == null || teamIds.isEmpty()) {
            games = gamesRepository.findByGameTimeBetweenOrderByGameTimeAsc(startDate, endDate);
        } else {
            games = gamesRepository.findByGameTimeAndTeamId(startDate, endDate, teamIds);
        }
        return games.stream().map(this::toResponse).toList();
    }

    public Optional<GameResponse> getGameById(UUID id) {
        return gamesRepository.findById(id).map(this::toResponse);
    }

    public GameEntity createGame(LocalDateTime gameTime, UUID homeTeamId, UUID awayTeamId,
                                  String predictedWinner, Double confidence, Double spread,
                                  Double odds, List<String> predictiveFactors) {
        Map<String, Object> features = new HashMap<>();
        if (predictedWinner != null) features.put("predictedWinner", predictedWinner);
        if (confidence != null) features.put("confidence", confidence);
        if (spread != null) features.put("spread", spread);
        if (odds != null) features.put("odds", odds);
        if (predictiveFactors != null) features.put("predictiveFactors", predictiveFactors);

        GameEntity game = GameEntity.builder()
                .gameId(UUID.randomUUID())
                .gameTime(gameTime)
                .homeTeamId(homeTeamId)
                .awayTeamId(awayTeamId)
                .status("scheduled")
                .gameFeatures(features)
                .build();
        return gamesRepository.save(game);
    }

    public Optional<GameEntity> updateGame(UUID id, LocalDateTime gameTime, UUID homeTeamId, UUID awayTeamId,
                                            String predictedWinner, Double confidence, Double spread,
                                            Double odds, List<String> predictiveFactors) {
        Optional<GameEntity> existing = gamesRepository.findById(id);
        if (existing.isEmpty()) return Optional.empty();

        GameEntity game = existing.get();
        if (gameTime != null) game.setGameTime(gameTime);
        if (homeTeamId != null) game.setHomeTeamId(homeTeamId);
        if (awayTeamId != null) game.setAwayTeamId(awayTeamId);

        Map<String, Object> features = game.getGameFeatures() != null
                ? new HashMap<>(game.getGameFeatures())
                : new HashMap<>();
        if (predictedWinner != null) features.put("predictedWinner", predictedWinner);
        if (confidence != null) features.put("confidence", confidence);
        if (spread != null) features.put("spread", spread);
        if (odds != null) features.put("odds", odds);
        if (predictiveFactors != null) features.put("predictiveFactors", predictiveFactors);
        game.setGameFeatures(features);

        return Optional.of(gamesRepository.save(game));
    }

    public boolean deleteGame(UUID id) {
        if (!gamesRepository.existsById(id)) return false;
        gamesRepository.deleteById(id);
        return true;
    }

    private GameResponse toResponse(GameEntity game) {
        String homeName = getTeamName(game.getHomeTeamId());
        String awayName = getTeamName(game.getAwayTeamId());
        Map<String, Object> features = game.getGameFeatures();

        String predictedWinner = features != null ? (String) features.get("predictedWinner") : null;
        Double confidence = features != null ? toDouble(features.get("confidence")) : null;
        Double spread = features != null ? toDouble(features.get("spread")) : null;
        Double odds = features != null ? toDouble(features.get("odds")) : null;

        @SuppressWarnings("unchecked")
        List<String> predictiveFactors = features != null
                ? (List<String>) features.get("predictiveFactors")
                : null;

        return new GameResponse(
                game.getGameId(), game.getGameTime(),
                homeName, game.getHomeTeamId(),
                awayName, game.getAwayTeamId(),
                predictedWinner, confidence, spread, odds, predictiveFactors
        );
    }

    private String getTeamName(UUID teamId) {
        if (teamId == null) return null;
        return teamsRepository.findById(teamId)
                .map(TeamEntity::getName)
                .orElse(null);
    }

    private Double toDouble(Object val) {
        if (val == null) return null;
        if (val instanceof Double d) return d;
        if (val instanceof Number n) return n.doubleValue();
        return null;
    }
}