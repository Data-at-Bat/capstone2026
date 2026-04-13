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

    @PostMapping("/favorites")
    public ResponseEntity<String> createFavorite(@RequestAttribute("uid") String userId, @RequestBody CreateFavoriteRequest request) {
        if (request.teamAbbreviation() != null) {
            return favoriteService.createFavorite(request.teamAbbreviation(), userId);
        }
        else {
            return favoriteService.createFavorite(request.teamId(), userId);
        }
    }

    @GetMapping("/favorites")
    public ResponseEntity<FavoritesResponse> getFavorites(@RequestAttribute("uid") String userId) {
        return favoriteService.getFavoritesByUserId(userId);
    }

    @DeleteMapping("/favorites")
    public ResponseEntity<String> deleteFavorite(@RequestAttribute("uid") String userId, @RequestParam UUID id) {
        return favoriteService.deleteFavorite(userId, id);
    }

    @DeleteMapping("/favorites")
    public ResponseEntity<String> deleteFavorite(@RequestAttribute("uid") String userId, @RequestParam String abbreviation) {
        return favoriteService.deleteFavoriteByAbbreviation(userId, abbreviation);
    }

    record CreateFavoriteRequest(String userId, UUID teamId, String teamAbbreviation) {}
}