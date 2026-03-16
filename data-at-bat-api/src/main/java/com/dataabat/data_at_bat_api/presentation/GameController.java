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

    @GetMapping(params = "!id")
    public ResponseEntity<List<GameResponse>> getGames(
            @RequestParam(required = false) LocalDateTime startDate,
            @RequestParam(required = false) LocalDateTime endDate,
            @RequestParam(required = false) List<UUID> teamIds) {
        return gameService.getGames(startDate, endDate, teamIds);
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
}