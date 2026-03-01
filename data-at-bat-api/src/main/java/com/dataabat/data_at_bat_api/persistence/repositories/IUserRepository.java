package com.dataabat.data_at_bat_api.persistence.repositories;

import com.dataabat.data_at_bat_api.domain.UserEntity;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;
import org.springframework.data.repository.CrudRepository;

public interface IUserRepository extends CrudRepository<UserEntity, UUID>{
    List<UserEntity> findByEmail(String email);
    // Returns all users with a given subscription status
    List<UserEntity> findBySubscriptionStatus(Boolean subscriptionStatus);
    // Finds all users whose subscription status expires before or on a date.
    List<UserEntity> findBySubscriptionExpiryLessThanEqual(LocalDateTime subscriptionExpiry);
    // Finds all users whose subscription status expires after or on a date.
    List<UserEntity> findBySubscriptionExpiryGreaterThanEqual(LocalDateTime subscriptionExpiry);
}
