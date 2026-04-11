package com.dataatbat.data_at_bat_api.services;

import com.dataatbat.data_at_bat_api.domain.TeamEntity;
import com.dataatbat.data_at_bat_api.persistence.ITeamsRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Optional;
import java.util.UUID;

@Service
public class TeamService {
    private final ITeamsRepository repository;

    TeamService(ITeamsRepository repository) {
        this.repository = repository;
    }

    public ResponseEntity<Iterable<TeamEntity>> getAllTeams() {
        return ResponseEntity.ok(repository.findAll());
    }

    public ResponseEntity<TeamEntity> getTeamById(UUID id) {
        return repository.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    public ResponseEntity<String> createSingleTeam(TeamEntity team) {
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

    public ResponseEntity<String> createTeamsBatchRequest(Iterable<TeamEntity> teams) {
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

    public ResponseEntity<String> updateSingleTeam(TeamEntity team) {
        try {
            assert team.getTeamId() != null;
            Optional<TeamEntity> existing = repository.findById(team.getTeamId());

            if (existing.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            TeamEntity newTeam = existing.get();
            newTeam.partialUpdate(team);
            repository.save(newTeam);

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

    public ResponseEntity<String> updateTeamBatchRequest(Iterable<TeamEntity> teams) {
        try {
            HashMap<UUID, TeamEntity> updates = new HashMap<UUID, TeamEntity>();
            for (TeamEntity team : teams) {
                assert team.getTeamId() != null;
                updates.put(team.getTeamId(), team);
            }

            Iterable<TeamEntity> existingTeams = repository.findByTeamIdIn(updates.keySet());

            for (TeamEntity existing : existingTeams) {
                existing.partialUpdate(updates.get(existing.getTeamId()));
            }
            repository.saveAll(existingTeams);
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
}
