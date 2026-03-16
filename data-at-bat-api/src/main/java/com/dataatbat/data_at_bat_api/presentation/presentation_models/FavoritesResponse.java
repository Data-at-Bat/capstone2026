package com.dataatbat.data_at_bat_api.presentation.presentation_models;

import com.dataatbat.data_at_bat_api.domain.FavoriteEntity;
import java.util.List;

public record FavoritesResponse(List<FavoriteEntity> favorites) {}