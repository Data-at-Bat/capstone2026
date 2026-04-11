package com.dataatbat.data_at_bat_api.presentation;

import com.dataatbat.data_at_bat_api.domain.GameEntity;
import com.dataatbat.data_at_bat_api.presentation.presentation_models.GameResponse;
import com.dataatbat.data_at_bat_api.services.GameService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.jackson.autoconfigure.JacksonAutoConfiguration;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(GameController.class)
class GameControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper; // This will now be satisfied by the @TestConfiguration

    @MockitoBean
    private GameService gameService;

    // This nested class provides the exact bean the error is complaining about
    @TestConfiguration
    static class TestConfig {
        @Bean
        public ObjectMapper objectMapper() {
            return new ObjectMapper()
                    .registerModule(new JavaTimeModule()); // Good practice for modern Java dates
        }
    }

    @Test
    @DisplayName("GET /games - Happy Path: Get list")
    void getGames_ShouldReturnList() throws Exception {
        when(gameService.getGames(any(), any(), any())).thenReturn(ResponseEntity.ok(List.of()));
        mockMvc.perform(get("/games")).andExpect(status().isOk());
    }

    @Test
    @DisplayName("GET /games?id=... - Happy Path: Found")
    void getGameById_ShouldReturnGame() throws Exception {
        var id = UUID.randomUUID();
        var response = new GameResponse(id, null, null, null, null, null, null, null, null, null, null);
        when(gameService.getGameById(id)).thenReturn(ResponseEntity.ok(response));

        mockMvc.perform(get("/games").param("id", id.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.gameId").value(id.toString()));
    }

    @Test
    @DisplayName("POST /games?batch=true - Happy Path: Batch Create")
    void createBatch_ShouldRouteCorrectly() throws Exception {
        when(gameService.createGamesBatchRequest(any())).thenReturn(ResponseEntity.ok("Batch Success"));

        mockMvc.perform(post("/games")
                        .param("batch", "true")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("[]"))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("PATCH /games?id=... - Happy Path: Update")
    void updateSingle_ShouldRouteCorrectly() throws Exception {
        var id = UUID.randomUUID();
        when(gameService.updateSingleGame(eq(id), any())).thenReturn(ResponseEntity.ok("Updated"));

        mockMvc.perform(patch("/games")
                        .param("id", id.toString())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("Sad Path Relay: Should return 400 when service returns 400")
    void shouldRelayErrorCodes() throws Exception {
        when(gameService.createSingleGame(any())).thenReturn(ResponseEntity.badRequest().body("Error"));

        mockMvc.perform(post("/games")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(content().string("Error"));
    }
}