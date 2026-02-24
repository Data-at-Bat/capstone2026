package com.dataabat.data_at_bat_api.services.repo_interfaces;

import org.springframework.data.repository.CrudRepository;
import com.dataabat.data_at_bat_api.domain.Favorite;
import java.util.UUID;
import java.util.List;

public interface IFavoritesRepository extends CrudRepository<Favorite, UUID> {
    List<Favorite> findByUserId(UUID userId);
    List<Favorite> findByTeamId(UUID teamId);
}
