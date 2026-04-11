package com.dataatbat.data_at_bat_api.services;

import com.dataatbat.data_at_bat_api.domain.FavoriteEntity;
import com.dataatbat.data_at_bat_api.persistence.IFavoritesRepository;
import com.dataatbat.data_at_bat_api.presentation.presentation_models.FavoritesResponse;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class FavoriteService {

    private final IFavoritesRepository favoritesRepository;

    public FavoriteService(IFavoritesRepository favoritesRepository) {
        this.favoritesRepository = favoritesRepository;
    }

    public ResponseEntity<String> createFavorite(UUID teamId, UUID userId) {
        try {
            FavoriteEntity favorite = new FavoriteEntity(teamId, userId);
            FavoriteEntity saved = favoritesRepository.save(favorite);
            return ResponseEntity.ok(saved.getId().toString());
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body("Could not create favorite. Ensure userId and teamId are valid.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<FavoritesResponse> getFavoritesByUserId(UUID userId) {
        List<FavoriteEntity> favorites = favoritesRepository.findByUserId(userId);
        return ResponseEntity.ok(new FavoritesResponse(favorites));
    }

    public ResponseEntity<String> deleteFavorite(UUID id) {
        try {
            Optional<FavoriteEntity> favorite = favoritesRepository.findById(id);
            if (favorite.isEmpty()) return ResponseEntity.notFound().build();
            favoritesRepository.deleteById(id);
            return ResponseEntity.ok("Favorite deleted successfully.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}