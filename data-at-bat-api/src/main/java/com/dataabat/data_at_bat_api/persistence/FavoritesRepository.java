package com.dataabat.data_at_bat_api.persistence;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FavoritesRepository extends JpaRepository<FavoritesEntity, String> {

    // Get all favorites for a given user
    @Query("SELECT f FROM FavoritesEntity f WHERE f.userId = :userId")
    List<FavoritesEntity> findByUserId(@Param("userId") String userId);
}