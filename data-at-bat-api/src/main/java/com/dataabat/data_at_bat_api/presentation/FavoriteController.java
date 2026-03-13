package com.dataabat.data_at_bat_api.presentation;

import com.dataabat.data_at_bat_api.domain.FavoriteEntity;
import com.dataabat.data_at_bat_api.services.FavoriteService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.dataabat.data_at_bat_api.presentation.FavoritesResponse;

import java.util.List;
import java.util.UUID;

@RestController
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @PostMapping("/favorite")
    public ResponseEntity<FavoriteEntity> createFavorite(@RequestBody CreateFavoriteRequest request) {
        FavoriteEntity created = favoriteService.createFavorite(request.teamId(), request.userId());
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/favorites")
    public ResponseEntity<FavoritesResponse> getFavorites(@RequestParam UUID userId) {
        List<FavoriteEntity> favorites = favoriteService.getFavoritesByUserId(userId);
        return ResponseEntity.ok(new FavoritesResponse(favorites));
    }

    @DeleteMapping("/favorites")
    public ResponseEntity<Void> deleteFavorite(@RequestParam UUID id) {
        boolean deleted = favoriteService.deleteFavorite(id);
        if (!deleted) return ResponseEntity.notFound().build();
        return ResponseEntity.noContent().build();
    }

    record CreateFavoriteRequest(UUID userId, UUID teamId) {}
}