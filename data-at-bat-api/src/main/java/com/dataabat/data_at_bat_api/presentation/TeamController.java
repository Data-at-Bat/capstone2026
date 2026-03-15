package com.dataabat.data_at_bat_api.presentation;

import com.dataabat.data_at_bat_api.domain.TeamEntity;
import com.dataabat.data_at_bat_api.persistence.repositories.ITeamsRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.UUID;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/team")
public class TeamController {
    private final ITeamsRepository repository;

    TeamController(ITeamsRepository repository) {
        this.repository = repository;
    }

    @GetMapping(params="!id")
    ResponseEntity<Iterable<TeamEntity>> getAllTeams() {
        return ResponseEntity.ok(repository.findAll());
    }

    @GetMapping(params="id")
    ResponseEntity<TeamEntity> getTeamById(@RequestParam UUID id) {
        return repository.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping(params = "!batch")
    ResponseEntity<String> createTeamWhenBatchNotSpecified(@RequestBody TeamEntity team) {
        return createSingleTeam(team);
    }

    @PostMapping(params = "batch=false")
    ResponseEntity<String> createTeamWhenBatchIsFalse(@RequestBody TeamEntity team) {
        return createSingleTeam(team);
    }

    @PostMapping(params = "batch=true")
    ResponseEntity<String> createTeamsBatchRequest(@RequestBody Iterable<TeamEntity> teams) {
        try {
            for (TeamEntity team : teams) {
                assert team.getTeamId() == null;
            }

            repository.saveAll(teams);
            return ResponseEntity.ok("Teams created successfully.");
        }
        catch (AssertionError error) {
            return ResponseEntity.badRequest().body("Cannot specify ID when creating a team.");
        }
        catch (DataIntegrityViolationException ex) {
            return ResponseEntity.badRequest().body("One or more field could not be inserted into the table. Ensure that you have all required fields and that all unique constraints are enforced.");
        }
        catch (Exception ex) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PatchMapping(params="!batch")
    ResponseEntity<String> updateTeamWhenBatchNotSpecified(@RequestParam(required = true) UUID id, @RequestBody TeamEntity team) {
        team.setTeamId(id);
        return updateSingleTeam(team);
    }

    @PatchMapping(params="batch=false")
    ResponseEntity<String> updateTeamWhenBatchIsFalse(@RequestParam(required = true) UUID id, @RequestBody TeamEntity team) {
        team.setTeamId(id);
        return updateSingleTeam(team);
    }

    @PatchMapping(params="batch=true")
    ResponseEntity<String> updateTeamBatchRequest(@RequestBody Iterable<TeamEntity> teams) {
        try {
            for (TeamEntity team : teams) {
                assert team.getTeamId() != null;
            }

            repository.saveAll(teams);
            return ResponseEntity.ok("Teams updated successfully.");
        }
        catch (AssertionError error) {
            return ResponseEntity.badRequest().body("Must specify ID when updating a team.");
        }
        catch (DataIntegrityViolationException ex) {
            return ResponseEntity.badRequest().body(ex.getLocalizedMessage());
        }
        catch (Exception ex) {
            return ResponseEntity.internalServerError().build();
        }
    }

    // These are not actual endpoints. Just broken out to enable batch requests to same endpoint
    ResponseEntity<String> updateSingleTeam(TeamEntity team) {
        try {
            assert team.getTeamId() != null;
            repository.save(team);
            return ResponseEntity.ok("Team updated successfully.");
        }
        catch (AssertionError error) {
            return ResponseEntity.badRequest().body("Must specify ID when updating a team.");
        }
        catch (DataIntegrityViolationException ex) {
            return ResponseEntity.badRequest().body("One or more field could not be inserted into the table. Ensure that you have all required fields and that all unique constraints are enforced.");
        }
        catch (Exception ex) {
            return ResponseEntity.internalServerError().build();
        }
    }

    ResponseEntity<String> createSingleTeam(TeamEntity team) {
        try {
            assert team.getTeamId() == null;
            TeamEntity savedTeam = repository.save(team);
            return ResponseEntity.ok(savedTeam.getTeamId().toString());
        }
        catch (AssertionError error) {
            return ResponseEntity.badRequest().body("Cannot specify ID when creating a team.");
        }
        catch (DataIntegrityViolationException ex) {
            return ResponseEntity.badRequest().body("One or more field could not be inserted into the table. Ensure that you have all required fields and that all unique constraints are enforced.");
        }
        catch (Exception ex) {
            return ResponseEntity.internalServerError().build();
        }
    }


}
