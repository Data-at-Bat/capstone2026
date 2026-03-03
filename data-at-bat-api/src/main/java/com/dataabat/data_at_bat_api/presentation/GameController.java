package com.dataabat.data_at_bat_api.presentation;

import com.dataabat.data_at_bat_api.domain.GameEntity;
import com.dataabat.data_at_bat_api.services.GameService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/games")
public class GameController {

    private final GameService gameService;

    public GameController(GameService gameService) {
        this.gameService = gameService;
    }

    // GET /games?startDate=...&endDate=...&teamIds=...
    @GetMapping
    public ResponseEntity<List<GameEntity>> getGames(
            @RequestParam(required = false) LocalDateTime startDate,
            @RequestParam(required = false) LocalDateTime endDate,
            @RequestParam(required = false) List<UUID> teamIds) {
        return ResponseEntity.ok(gameService.getGames(startDate, endDate, teamIds));
    }

    // GET /games?id={id}
    @GetMapping("/{id}")
    public ResponseEntity<GameEntity> getGameById(@PathVariable UUID id) {
        return gameService.getGameById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /games
    @PostMapping
    public ResponseEntity<GameEntity> createGame(@RequestBody CreateGameRequest request) {
        GameEntity created = gameService.createGame(
                request.gameTime(), request.homeTeamId(), request.awayTeamId());
        return ResponseEntity.ok(created);
    }

    // PATCH /games/{id}
    @PatchMapping("/{id}")
    public ResponseEntity<GameEntity> updateGame(
            @PathVariable UUID id,
            @RequestBody UpdateGameRequest request) {
        return gameService.updateGame(id, request.gameTime(), request.homeTeamId(), request.awayTeamId())
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // DELETE /games/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteGame(@PathVariable UUID id) {
        if (gameService.deleteGame(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    // Request body records
    public record CreateGameRequest(LocalDateTime gameTime, UUID homeTeamId, UUID awayTeamId) {}
    public record UpdateGameRequest(LocalDateTime gameTime, UUID homeTeamId, UUID awayTeamId) {}
}