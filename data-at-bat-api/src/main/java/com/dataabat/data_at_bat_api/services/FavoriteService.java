package com.dataabat.data_at_bat_api.services;

import com.dataabat.data_at_bat_api.domain.FavoriteEntity;
import com.dataabat.data_at_bat_api.persistence.repositories.IFavoritesRepository;
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

    public FavoriteEntity createFavorite(UUID teamId, UUID userId) {
        FavoriteEntity favorite = new FavoriteEntity(teamId, userId);
        return favoritesRepository.save(favorite);
    }

    public List<FavoriteEntity> getFavoritesByUserId(UUID userId) {
        return favoritesRepository.findByUserId(userId);
    }

    public boolean deleteFavorite(UUID id) {
        Optional<FavoriteEntity> favorite = favoritesRepository.findById(id);
        if (favorite.isEmpty()) return false;
        favoritesRepository.deleteById(id);
        return true;
    }
}