package com.dataatbat.data_at_bat_api.persistence.repositories;

import com.dataatbat.data_at_bat_api.domain.PredictionEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.UUID;

public interface IPredictionRepository extends CrudRepository<PredictionEntity, UUID> {
    List<PredictionEntity> findByGameId(UUID gameId);
    List<PredictionEntity> findByGameIdIn(List<UUID> gameId);
    List<PredictionEntity> findByModelVersion(String modelVersion);
    List<PredictionEntity> findByModelVersionIn(List<String> modelVersion);
    List<PredictionEntity> findByHomeWinProbabilityGreaterThanEqual(Double homeWinProbability);
    List<PredictionEntity> findByHomeWinProbabilityLessThanEqual(Double homeWinProbability);
    List<PredictionEntity> findByHomeWinProbabilityBetween(Double minHomeWinProbability, Double maxHomeWinProbability);
    List<PredictionEntity> findByAwayWinProbabilityGreaterThanEqual(Double awayWinProbability);
    List<PredictionEntity> findByAwayWinProbabilityLessThanEqual(Double awayWinProbability);
    List<PredictionEntity> findByAwayWinProbabilityBetween(Double minAwayWinProbability, Double maxAwayWinProbability);
}
