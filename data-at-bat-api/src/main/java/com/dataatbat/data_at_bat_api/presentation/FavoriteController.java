package com.dataatbat.data_at_bat_api.presentation;

import com.dataatbat.data_at_bat_api.presentation.presentation_models.FavoritesResponse;
import com.dataatbat.data_at_bat_api.services.FavoriteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/favorites")
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @PostMapping
    public ResponseEntity<String> createFavorite(@RequestAttribute("uid") String userId, @RequestBody CreateFavoriteRequest request) {
        if (request.teamAbbreviation() != null) {
            return favoriteService.createFavorite(request.teamAbbreviation(), userId);
        }
        else {
            return favoriteService.createFavorite(request.teamId(), userId);
        }
    }

    @GetMapping
    public ResponseEntity<FavoritesResponse> getFavorites(@RequestAttribute("uid") String userId) {
        return favoriteService.getFavoritesByUserId(userId);
    }

    @DeleteMapping(params="id")
    public ResponseEntity<String> deleteFavoriteById(@RequestAttribute("uid") String userId, @RequestParam UUID id) {
        return favoriteService.deleteFavorite(userId, id);
    }

    @DeleteMapping(params="abbreviation")
    public ResponseEntity<String> deleteFavoriteByAbbreviation(@RequestAttribute("uid") String userId, @RequestParam String abbreviation) {
        return favoriteService.deleteFavoriteByAbbreviation(userId, abbreviation);
    }

    @PostMapping("/sync")
    public ResponseEntity<String> syncFavorites(@RequestAttribute("uid") String userId, @RequestBody SyncFavoritesRequest request) {
        return favoriteService.syncFavorites(userId, request.teamIds());
    }

    record SyncFavoritesRequest(List<UUID> teamIds) {}
    record CreateFavoriteRequest(String userId, UUID teamId, String teamAbbreviation) {}
}