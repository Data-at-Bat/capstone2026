package com.dataatbat.data_at_bat_api.presentation;

import com.dataatbat.data_at_bat_api.domain.TeamEntity;
import com.dataatbat.data_at_bat_api.services.TeamService;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/team")
public class TeamController {
    private final TeamService service;

    TeamController( TeamService service) {
        this.service = service;
    }

    @GetMapping(params="!id")
    ResponseEntity<Iterable<TeamEntity>> getAllTeams() {
        return service.getAllTeams();
    }

    @GetMapping(params="id")
    ResponseEntity<TeamEntity> getTeamById(@RequestParam UUID id) {
        return service.getTeamById(id);
    }

    @PostMapping(params = "!batch")
    ResponseEntity<String> createTeamWhenBatchNotSpecified(@RequestBody TeamEntity team) {
        return service.createSingleTeam(team);
    }

    @PostMapping(params = "batch=false")
    ResponseEntity<String> createTeamWhenBatchIsFalse(@RequestBody TeamEntity team) {
        return service.createSingleTeam(team);
    }

    @PostMapping(params = "batch=true")
    ResponseEntity<String> createTeamsBatchRequest(@RequestBody Iterable<TeamEntity> teams) {
        return service.createTeamsBatchRequest(teams);
    }

    @PatchMapping(params="!batch")
    ResponseEntity<String> updateTeamWhenBatchNotSpecified(@RequestParam(required = true) UUID id, @RequestBody TeamEntity team) {
        team.setTeamId(id);
        return service.updateSingleTeam(team);
    }

    @PatchMapping(params="batch=false")
    ResponseEntity<String> updateTeamWhenBatchIsFalse(@RequestParam(required = true) UUID id, @RequestBody TeamEntity team) {
        team.setTeamId(id);
        return service.updateSingleTeam(team);
    }

    @PatchMapping(params="batch=true")
    ResponseEntity<String> updateTeamBatchRequest(@RequestBody Iterable<TeamEntity> teams) {
        return service.updateTeamBatchRequest(teams);
    }




}
