package com.dataatbat.data_at_bat_api.presentation;

import com.dataatbat.data_at_bat_api.domain.GameEntity;
import com.dataatbat.data_at_bat_api.presentation.presentation_models.GameResponse;
import com.dataatbat.data_at_bat_api.services.GameService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/games")
@CrossOrigin(origins = "*")
public class GameController {

    private final GameService gameService;

    public GameController(GameService gameService) {
        this.gameService = gameService;
    }

    @GetMapping(params = "!id")
    public ResponseEntity<List<GameResponse>> getGames(
            @RequestParam(required = false) LocalDateTime startDate,
            @RequestParam(required = false) LocalDateTime endDate,
            @RequestParam(required = false) List<String> teamIds) {

        return ResponseEntity.ok(gameService.getGames(startDate, endDate, teamIds));
    }

    @GetMapping(params = "id")
    public ResponseEntity<GameResponse> getGameById(@RequestParam UUID id) {
        return gameService.getGameById(id);
    }

    @PostMapping(params = "!batch")
    public ResponseEntity<String> createGame(@RequestBody GameEntity game) {
        return gameService.createSingleGame(game);
    }

    @PostMapping(params = "batch=false")
    public ResponseEntity<String> createGameBatchFalse(@RequestBody GameEntity game) {
        return gameService.createSingleGame(game);
    @PostMapping
    public ResponseEntity<GameEntity> createGame(@RequestBody CreateGameRequest request) {
        GameEntity created = gameService.createGame(
                request.gameTime(), request.homeTeamId(), request.awayTeamId(),
                request.predictedWinner(), request.confidence(), request.spread(),
                request.homeTeamName(), request.awayTeamName(),
                request.odds(), request.predictiveFactors());
        return ResponseEntity.ok(created);
    }

    @PatchMapping("/{id}")
    public ResponseEntity<GameEntity> updateGame(
            @PathVariable UUID id,
            @RequestBody UpdateGameRequest request) {

        return gameService.updateGame(id, request.gameTime(), request.homeTeamId(), request.awayTeamId(),
                        request.predictedWinner(), request.confidence(), request.spread(),
                        request.homeTeamName(), request.awayTeamName(),
                        request.odds(), request.predictiveFactors())
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping(params = "batch=true")
    public ResponseEntity<String> createGamesBatch(@RequestBody Iterable<GameEntity> games) {
        return gameService.createGamesBatchRequest(games);
    }

    @PatchMapping(params = "!batch")
    public ResponseEntity<String> updateGame(@RequestParam UUID id, @RequestBody GameEntity game) {
        return gameService.updateSingleGame(id, game);
    }

    @PatchMapping(params = "batch=false")
    public ResponseEntity<String> updateGameBatchFalse(@RequestParam UUID id, @RequestBody GameEntity game) {
        return gameService.updateSingleGame(id, game);
    }

    @PatchMapping(params = "batch=true")
    public ResponseEntity<String> updateGamesBatch(@RequestBody Iterable<GameEntity> games) {
        return gameService.updateGamesBatchRequest(games);
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteGame(@RequestParam UUID id) {
        return gameService.deleteGame(id);
    }
    public record CreateGameRequest(
            LocalDateTime gameTime, String homeTeamId, String awayTeamId,
            String homeTeamName, String awayTeamName,
            String predictedWinner, Double confidence, Double spread,
            Double odds, List<String> predictiveFactors) {}

    public record UpdateGameRequest(
            LocalDateTime gameTime, String homeTeamId, String awayTeamId,
            String homeTeamName, String awayTeamName,
            String predictedWinner, Double confidence, Double spread,
            Double odds, List<String> predictiveFactors) {}
}