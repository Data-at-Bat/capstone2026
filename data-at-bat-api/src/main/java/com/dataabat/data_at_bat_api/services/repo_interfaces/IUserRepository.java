package com.dataabat.data_at_bat_api.services.repo_interfaces;

import com.dataabat.data_at_bat_api.domain.User;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;
import org.springframework.data.repository.CrudRepository;

public interface IUserRepository extends CrudRepository<User, UUID>{
    List<User> findByEmail(String email);
    // Returns all users with a given subscription status
    List<User> findBySubscriptionStatus(Boolean subscriptionStatus);
    // Finds all users whose subscription status expires before or on a date.
    List<User> findBySubscriptionExpiryLessThanEqual(LocalDateTime subscriptionExpiry);
    // Finds all users whose subscription status expires after or on a date.
    List<User> findBySubscriptionExpiryGreaterThanEqual(LocalDateTime subscriptionExpiry);
}
