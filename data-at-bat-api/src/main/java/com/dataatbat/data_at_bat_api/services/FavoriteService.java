package com.dataatbat.data_at_bat_api.services;

import com.dataatbat.data_at_bat_api.domain.FavoriteEntity;
import com.dataatbat.data_at_bat_api.domain.TeamEntity;
import com.dataatbat.data_at_bat_api.persistence.IFavoritesRepository;
import com.dataatbat.data_at_bat_api.persistence.ITeamsRepository;
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
    public final ITeamsRepository teamsRepository;

    public FavoriteService(IFavoritesRepository favoritesRepository, ITeamsRepository teamsRepository) {
        this.favoritesRepository = favoritesRepository;
        this.teamsRepository = teamsRepository;
    }

    public ResponseEntity<String> createFavorite(UUID teamId, String userId) {
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

    public ResponseEntity<String> createFavorite(String teamAbbreviation, String userId) {
        try {
            TeamEntity team = teamsRepository.findByAbbreviation(teamAbbreviation);

            if (team == null) {
                return ResponseEntity.notFound().build();
            }

            return createFavorite(team.getTeamId(), userId);
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body("Could not create favorite. Ensure userId and abbreviation are valid.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<FavoritesResponse> getFavoritesByUserId(String userId) {
        List<FavoriteEntity> favorites = favoritesRepository.findByUserId(userId);
        return ResponseEntity.ok(new FavoritesResponse(favorites));
    }

    public ResponseEntity<String> deleteFavorite(String userId, UUID id) {
        try {
            Optional<FavoriteEntity> favorite = favoritesRepository.findById(id);
            if (favorite.isEmpty() || favorite.get().getUserId().equals(userId)) return ResponseEntity.notFound().build();
            favoritesRepository.deleteById(id);
            return ResponseEntity.ok("Favorite deleted successfully.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<String> deleteFavoriteByTeamId(String userId, UUID teamId) {
        try {
            FavoriteEntity favorite = favoritesRepository.findByUserIdAndTeamId(userId, teamId);
            if (favorite == null) {
                return ResponseEntity.notFound().build();
            }
            favoritesRepository.deleteByUserIdAndTeamId(userId, teamId);
            return ResponseEntity.ok("Favorite deleted successfully.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<String> deleteFavoriteByAbbreviation(String userId, String abbreviation) {
        try {
            TeamEntity team = teamsRepository.findByAbbreviation(abbreviation);
            if (team == null) {
                return ResponseEntity.notFound().build();
            }

            return deleteFavoriteByTeamId(userId, team.getTeamId());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}