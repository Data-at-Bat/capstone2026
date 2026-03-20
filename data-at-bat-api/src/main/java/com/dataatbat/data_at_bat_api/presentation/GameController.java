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

    @GetMapping
    public ResponseEntity<List<GameResponse>> getGames(
            @RequestParam(required = false) LocalDateTime startDate,
            @RequestParam(required = false) LocalDateTime endDate,
            @RequestParam(required = false) List<String> teamIds) {

        return ResponseEntity.ok(gameService.getGames(startDate, endDate, teamIds));
    }

    @GetMapping("/{id}")
    public ResponseEntity<GameResponse> getGameById(@PathVariable UUID id) {
        return gameService.getGameById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

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

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteGame(@PathVariable UUID id) {
        if (gameService.deleteGame(id)) return ResponseEntity.noContent().build();
        return ResponseEntity.notFound().build();
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