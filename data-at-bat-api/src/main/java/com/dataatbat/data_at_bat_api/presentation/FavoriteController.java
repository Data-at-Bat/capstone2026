package com.dataatbat.data_at_bat_api.presentation;

import com.dataatbat.data_at_bat_api.domain.FavoriteEntity;
import com.dataatbat.data_at_bat_api.presentation.presentation_models.FavoritesResponse;
import com.dataatbat.data_at_bat_api.services.FavoriteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @PostMapping("/favorite")
    public ResponseEntity<String> createFavorite(@RequestBody CreateFavoriteRequest request) {
        return favoriteService.createFavorite(request.teamId(), request.userId());
    }

    @GetMapping("/favorites")
    public ResponseEntity<FavoritesResponse> getFavorites(@RequestParam UUID userId) {
        return favoriteService.getFavoritesByUserId(userId);
    }

    @DeleteMapping("/favorites")
    public ResponseEntity<String> deleteFavorite(@RequestParam UUID id) {
        return favoriteService.deleteFavorite(id);
    }

    record CreateFavoriteRequest(UUID userId, UUID teamId) {}
}