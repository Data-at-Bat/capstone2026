package com.dataatbat.data_at_bat_api.persistence;

import org.springframework.data.repository.CrudRepository;
import com.dataatbat.data_at_bat_api.domain.FavoriteEntity;
import java.util.UUID;
import java.util.List;

public interface IFavoritesRepository extends CrudRepository<FavoriteEntity, UUID> {
    List<FavoriteEntity> findByUserId(String userId);
    List<FavoriteEntity> findByTeamId(UUID teamId);
    FavoriteEntity findByUserIdAndTeamId(String userId, UUID teamId);
    void deleteByUserIdAndTeamId(String userId, UUID teamId);
}
