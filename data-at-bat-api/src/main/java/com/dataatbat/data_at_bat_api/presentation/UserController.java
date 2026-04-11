package com.dataatbat.data_at_bat_api.presentation;

import com.dataatbat.data_at_bat_api.domain.UserEntity;
import com.dataatbat.data_at_bat_api.services.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ResponseEntity<UserEntity> getUser(@RequestParam UUID id) {
        return userService.getUserById(id);
    }

    @PostMapping
    public ResponseEntity<String> createUser(@RequestBody UserEntity user) {
        return userService.createUser(user);
    }

    @PatchMapping
    public ResponseEntity<String> updateUser(@RequestParam UUID id, @RequestBody UserEntity user) {
        return userService.updateUser(id, user);
    }

    @DeleteMapping
    public ResponseEntity<String> deleteUser(@RequestParam UUID id) {
        return userService.deleteUser(id);
    }
}