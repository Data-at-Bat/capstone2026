package com.dataatbat.data_at_bat_api.services;

import com.dataatbat.data_at_bat_api.domain.GameEntity;
import com.dataatbat.data_at_bat_api.persistence.IGamesRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;

import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class GameServiceTests {

    @Mock
    private IGamesRepository gamesRepository;

    @InjectMocks
    private GameService gameService;

    // --- Helper Methods ---
    private GameEntity createValidEntity(UUID id) {
        var entity = new GameEntity();
        entity.setGameId(id);
        entity.setHomeTeamName("Mets");
        entity.setAwayTeamName("Braves");
        return entity;
    }

    // --- getGames Tests ---
    @Nested
    @DisplayName("getGames Coverage")
    class GetGamesTests {
        @Test
        @DisplayName("Success: Should return games list with default dates if params null")
        void getGames_Success_Defaults() {
            when(gamesRepository.findByGameTimeBetweenOrderByGameTimeAsc(any(), any()))
                    .thenReturn(List.of(createValidEntity(UUID.randomUUID())));

            var response = gameService.getGames(null, null, null);

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            assertThat(response.getBody()).isNotEmpty();
        }

        @Test
        @DisplayName("Success: Should call filtered repo method when teamIds provided")
        void getGames_Success_Filtered() {
            var teams = List.of("NYM");
            gameService.getGames(null, null, teams);
            verify(gamesRepository).findByGameTimeAndTeamId(any(), any(), eq(teams));
        }
    }

    // --- getGameById Tests ---
    @Nested
    @DisplayName("getGameById Coverage")
    class GetGameByIdTests {
        @Test
        @DisplayName("Success: Should return 200 and mapped Record")
        void getGameById_Found() {
            var id = UUID.randomUUID();
            when(gamesRepository.findById(id)).thenReturn(Optional.of(createValidEntity(id)));

            var response = gameService.getGameById(id);

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            assertThat(response.getBody().gameId()).isEqualTo(id);
        }

        @Test
        @DisplayName("Sad Path: Should return 404 when ID not in DB")
        void getGameById_NotFound() {
            when(gamesRepository.findById(any())).thenReturn(Optional.empty());
            var response = gameService.getGameById(UUID.randomUUID());
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        }
    }

    // --- createSingleGame Tests ---
    @Nested
    @DisplayName("createSingleGame Coverage")
    class CreateSingleGameTests {
        @Test
        @DisplayName("Success: Should generate UUID and save")
        void create_Success() {
            var game = new GameEntity(); // No ID
            when(gamesRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

            var response = gameService.createSingleGame(game);

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            assertThat(game.getGameId()).isNotNull();
        }

        @Test
        @DisplayName("Sad Path: Should return 400 if ID is already present (AssertionError)")
        void create_Fail_IdNotNull() {
            var game = createValidEntity(UUID.randomUUID());
            var response = gameService.createSingleGame(game);
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        }

        @Test
        @DisplayName("Sad Path: Should return 400 on Data Integrity Violation")
        void create_Fail_DataIntegrity() {
            when(gamesRepository.save(any())).thenThrow(DataIntegrityViolationException.class);
            var response = gameService.createSingleGame(new GameEntity());
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        }

        @Test
        @DisplayName("Sad Path: Should return 500 on unexpected Exception")
        void create_Fail_General() {
            when(gamesRepository.save(any())).thenThrow(RuntimeException.class);
            var response = gameService.createSingleGame(new GameEntity());
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // --- createGamesBatchRequest Tests ---
    @Nested
    @DisplayName("createGamesBatchRequest Coverage")
    class CreateBatchTests {
        @Test
        @DisplayName("Success: Should generate IDs for all and save")
        void createBatch_Success() {
            var games = List.of(new GameEntity(), new GameEntity());
            var response = gameService.createGamesBatchRequest(games);
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            verify(gamesRepository).saveAll(any());
        }

        @Test
        @DisplayName("Sad Path: Should fail if any game in batch has an ID")
        void createBatch_Fail_IdExists() {
            var games = List.of(new GameEntity(), createValidEntity(UUID.randomUUID()));
            var response = gameService.createGamesBatchRequest(games);
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        }
    }

    // --- updateSingleGame Tests ---
    @Nested
    @DisplayName("updateSingleGame Coverage")
    class UpdateSingleGameTests {
        @Test
        @DisplayName("Success: Should call partialUpdate and save")
        void update_Success() {
            var id = UUID.randomUUID();
            var existing = spy(createValidEntity(id));
            when(gamesRepository.findById(id)).thenReturn(Optional.of(existing));

            var response = gameService.updateSingleGame(id, new GameEntity());

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            verify(existing).partialUpdate(any());
            verify(gamesRepository).save(existing);
        }

        @Test
        @DisplayName("Sad Path: Should return 404 if game to update missing")
        void update_Fail_NotFound() {
            when(gamesRepository.findById(any())).thenReturn(Optional.empty());
            var response = gameService.updateSingleGame(UUID.randomUUID(), new GameEntity());
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        }
    }

    // --- updateGamesBatchRequest Tests ---
    @Nested
    @DisplayName("updateGamesBatchRequest Coverage")
    class UpdateBatchTests {
        @Test
        @DisplayName("Success: Should update existing games found by IDs")
        void updateBatch_Success() {
            var id = UUID.randomUUID();
            var update = createValidEntity(id);
            var existing = spy(createValidEntity(id));

            when(gamesRepository.findAllById(any())).thenReturn(List.of(existing));

            var response = gameService.updateGamesBatchRequest(List.of(update));

            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
            verify(existing).partialUpdate(any());
            verify(gamesRepository).saveAll(any());
        }

        @Test
        @DisplayName("Sad Path: Should return 400 if an entity lacks an ID")
        void updateBatch_Fail_MissingId() {
            var invalidUpdate = new GameEntity();
            var response = gameService.updateGamesBatchRequest(List.of(invalidUpdate));
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        }
    }

    // --- deleteGame Tests ---
    @Nested
    @DisplayName("deleteGame Coverage")
    class DeleteTests {
        @Test
        @DisplayName("Success: Should return 204 No Content")
        void delete_Success() {
            var id = UUID.randomUUID();
            when(gamesRepository.existsById(id)).thenReturn(true);
            var response = gameService.deleteGame(id);
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);
            verify(gamesRepository).deleteById(id);
        }

        @Test
        @DisplayName("Sad Path: Should return 404 if not exists")
        void delete_Fail_NotFound() {
            when(gamesRepository.existsById(any())).thenReturn(false);
            var response = gameService.deleteGame(UUID.randomUUID());
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        }
    }
}