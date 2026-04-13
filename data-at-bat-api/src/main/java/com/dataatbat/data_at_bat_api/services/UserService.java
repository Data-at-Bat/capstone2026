package com.dataatbat.data_at_bat_api.services;

import com.dataatbat.data_at_bat_api.domain.UserEntity;
import com.dataatbat.data_at_bat_api.persistence.IUserRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;

@Service
public class UserService {

    private final IUserRepository userRepository;

    public UserService(IUserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public ResponseEntity<UserEntity> getUserById(String id) {
        return userRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    public ResponseEntity<String> createUser(UserEntity user) {
        try {
            assert user.getUid() == null;
            UserEntity saved = userRepository.save(user);
            return ResponseEntity.ok(saved.getUid().toString());
        } catch (AssertionError e) {
            return ResponseEntity.badRequest().body("Cannot specify ID when creating a user.");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body("Could not create user. Email may already be in use.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<String> updateUser(String id, UserEntity user) {
        try {
            Optional<UserEntity> existing = userRepository.findById(id);
            if (existing.isEmpty()) return ResponseEntity.notFound().build();
            UserEntity existingUser = existing.get();
            if (user.getEmail() != null) existingUser.setEmail(user.getEmail());
            userRepository.save(existingUser);
            return ResponseEntity.ok("User updated successfully.");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.badRequest().body("Could not update user. Email may already be in use.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    public ResponseEntity<String> deleteUser(String id) {
        try {
            if (!userRepository.existsById(id)) return ResponseEntity.notFound().build();
            userRepository.deleteById(id);
            return ResponseEntity.ok("User deleted successfully.");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}