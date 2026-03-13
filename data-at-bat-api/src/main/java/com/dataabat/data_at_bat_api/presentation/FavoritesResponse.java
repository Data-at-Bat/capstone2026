package com.dataabat.data_at_bat_api.presentation;

import com.dataabat.data_at_bat_api.domain.FavoriteEntity;
import java.util.List;

public record FavoritesResponse(List<FavoriteEntity> favorites) {}