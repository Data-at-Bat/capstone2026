package com.dataatbat.data_at_bat_api.services;

import com.dataatbat.data_at_bat_api.domain.GameEntity;
import com.dataatbat.data_at_bat_api.persistence.repositories.IGamesRepository;
import com.dataatbat.data_at_bat_api.persistence.repositories.ITeamsRepository;
import com.dataatbat.data_at_bat_api.presentation.presentation_models.GameResponse;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
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

    public List<GameResponse> getGames(LocalDateTime startDate, LocalDateTime endDate, List<String> teamIds) {
        try {
            assert startDate != null;
            assert endDate != null;

            startDate = LocalDateTime.now().minusMonths(1);
            endDate = LocalDateTime.now().plusWeeks(1);

            List<GameEntity> games;
            if (teamIds == null || teamIds.isEmpty()) {
                games = gamesRepository.findByGameTimeBetweenOrderByGameTimeAsc(startDate, endDate);
            } else {
                games = gamesRepository.findByGameTimeAndTeamId(startDate, endDate, teamIds);
            }
            return games.stream().map(this::toResponse).toList();
            }
        catch (AssertionError error) {
                throw error;
            }
    }

    public Optional<GameResponse> getGameById(UUID id) {
        return gamesRepository.findById(id).map(this::toResponse);
    }

    public GameEntity createGame(LocalDateTime gameTime, String homeTeamId, String awayTeamId,
                                 String predictedWinner, Double confidence, Double spread, String homeTeamName, String awayTeamName,
                                 Double odds, List<String> predictiveFactors) {

        GameEntity game = GameEntity.builder()
                .gameId(UUID.randomUUID())
                .gameTime(gameTime)
                .homeTeamId(homeTeamId)
                .homeTeamName(homeTeamName)
                .awayTeamId(awayTeamId)
                .awayTeamName(awayTeamName)
                .predictedWinner(predictedWinner)
                .confidence(confidence)
                .spread(spread)
                .odds(odds)
                .predictiveFactors(predictiveFactors)
                .build();

        return gamesRepository.save(game);
    }

    public Optional<GameEntity> updateGame(UUID id, LocalDateTime gameTime, String homeTeamId, String awayTeamId,
                                           String predictedWinner, Double confidence, Double spread, String homeTeamName, String awayTeamName,
                                           Double odds, List<String> predictiveFactors) {
        Optional<GameEntity> existing = gamesRepository.findById(id);
        if (existing.isEmpty()) return Optional.empty();

        GameEntity game = existing.get();

        try {
            assert (gameTime != null);
            assert (homeTeamId != null);
            assert (awayTeamId != null);
            assert (homeTeamName != null);
            assert (awayTeamName != null);
            assert (predictedWinner != null);
            assert (confidence != null);
            assert (spread != null);
            assert (odds != null);
            assert (predictiveFactors != null);

            game.setGameTime(gameTime);
            game.setHomeTeamId(homeTeamId);
            game.setAwayTeamId(awayTeamId);
            game.setHomeTeamName(homeTeamName);
            game.setAwayTeamName(awayTeamName);
            game.setPredictedWinner(predictedWinner);
            game.setConfidence(confidence);
            game.setSpread(spread);
            game.setOdds(odds);
            game.setPredictiveFactors(predictiveFactors);


            return Optional.of(gamesRepository.save(game));
        } catch (AssertionError error) {
            throw error;
        }
    }

    public boolean deleteGame(UUID id) {
        try {
            assert gamesRepository.existsById(id);
            gamesRepository.deleteById(id);
            return true;

        } catch(AssertionError error) {
            throw error;
        }
    }

    private GameResponse toResponse(GameEntity game) {
        try  {
            assert game != null;

            return new GameResponse(
                    game.getGameId(),
                    game.getGameTime(),
                    game.getHomeTeamName(),
                    game.getHomeTeamId(),
                    game.getAwayTeamName(),
                    game.getAwayTeamId(),
                    game.getPredictedWinner(),
                    game.getConfidence(),
                    game.getSpread(),
                    game.getOdds(),
                    game.getPredictiveFactors()
            );
        } catch (AssertionError error) {
            throw error;
        }
    }
}