package com.dataabat.data_at_bat_api.services.repo_interfaces;

import com.dataabat.data_at_bat_api.domain.GameEntity;
import org.springframework.cglib.core.Local;
import org.springframework.data.repository.CrudRepository;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;

public interface IGamesRepository extends CrudRepository<GameEntity, UUID> {
    List<GameEntity> findByStatus(String status);
    List<GameEntity> findByStatusAndTeamId(String status, UUID teamId);
    List<GameEntity> findByTeamIdIn(List<UUID> teamIds);
    List<GameEntity> findByGameTimeBetweenAndTeamIdIn(LocalDateTime startDate, LocalDateTime endDate, List<UUID> teamIds);
    void deleteByStatus(String status);
    void deleteByTeamId(UUID teamId);
}
