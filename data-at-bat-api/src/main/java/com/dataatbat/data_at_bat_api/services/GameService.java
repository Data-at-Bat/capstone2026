package com.dataatbat.data_at_bat_api.services;

import com.dataatbat.data_at_bat_api.domain.GameEntity;
import com.dataatbat.data_at_bat_api.persistence.repositories.IGamesRepository;
import com.dataatbat.data_at_bat_api.presentation.presentation_models.GameResponse;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class GameService {

    private final IGamesRepository gamesRepository;

    public GameService(IGamesRepository gamesRepository) {
        this.gamesRepository = gamesRepository;
    }

    public ResponseEntity<List<GameResponse>> getGames(LocalDateTime startDate, LocalDateTime endDate, List<UUID> teamIds) {
        if (startDate == null) startDate = LocalDateTime.now().minusMonths(1);
        if (endDate == null) endDate = LocalDateTime.now().plusWeeks(1);

        List<GameEntity> games;
        if (teamIds == null || teamIds.isEmpty()) {
            games = gamesRepository.findByGameTimeBetweenOrderByGameTimeAsc(startDate, endDate);
        } else {
            games = gamesRepository.findByGameTimeAndTeamId(startDate, endDate, teamIds);
        }
        return ResponseEntity.ok(games.stream().map(this::toResponse).toList());
    }

    public ResponseEntity<GameResponse> getGameById(UUID id) {
        return gamesRepository.findById(id)
                .map(this::toResponse)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    public ResponseEntity<String> createSingleGame(GameEntity game) {
        try {
            assert game.getGameId() == null;
            game.setGameId(UUID.randomUUID());
            GameEntity saved = gamesRepository.save(game);
            return ResponseEntity.ok(saved.getGameId().toString());
        } catch (AssertionError e) {
            return ResponseEntity.badRequest().body("Cannot specify ID when creating a game.");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body("One or more fields could not be inserted. Ensure all required fields are present.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<String> createGamesBatchRequest(Iterable<GameEntity> games) {
        try {
            for (GameEntity game : games) {
                assert game.getGameId() == null;
                game.setGameId(UUID.randomUUID());
            }
            gamesRepository.saveAll(games);
            return ResponseEntity.ok("Games created successfully.");
        } catch (AssertionError e) {
            return ResponseEntity.badRequest().body("Cannot specify ID when creating a game.");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body("One or more fields could not be inserted. Ensure all required fields are present.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<String> updateSingleGame(UUID id, GameEntity game) {
        try {
            assert id != null;
            Optional<GameEntity> existing = gamesRepository.findById(id);
            if (existing.isEmpty()) return ResponseEntity.notFound().build();
            GameEntity existingGame = existing.get();
            existingGame.partialUpdate(game);
            gamesRepository.save(existingGame);
            return ResponseEntity.ok("Game updated successfully.");
        } catch (AssertionError e) {
            return ResponseEntity.badRequest().body("Must specify ID when updating a game.");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body("One or more fields could not be updated.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<String> updateGamesBatchRequest(Iterable<GameEntity> games) {
        try {
            HashMap<UUID, GameEntity> updates = new HashMap<>();
            for (GameEntity game : games) {
                assert game.getGameId() != null;
                updates.put(game.getGameId(), game);
            }
            Iterable<GameEntity> existingGames = gamesRepository.findAllById(updates.keySet());
            for (GameEntity existing : existingGames) {
                existing.partialUpdate(updates.get(existing.getGameId()));
            }
            gamesRepository.saveAll(existingGames);
            return ResponseEntity.ok("Games updated successfully.");
        } catch (AssertionError e) {
            return ResponseEntity.badRequest().body("Must specify ID when updating a game.");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body(e.getLocalizedMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<Void> deleteGame(UUID id) {
        if (!gamesRepository.existsById(id)) return ResponseEntity.notFound().build();
        gamesRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    private GameResponse toResponse(GameEntity game) {
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
    }
}