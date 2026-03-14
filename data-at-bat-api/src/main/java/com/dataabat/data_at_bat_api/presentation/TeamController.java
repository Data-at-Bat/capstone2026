package com.dataabat.data_at_bat_api.presentation;

import com.dataabat.data_at_bat_api.domain.TeamEntity;
import com.dataabat.data_at_bat_api.persistence.repositories.ITeamsRepository;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/team")
public class TeamController {
    private final ITeamsRepository repository;

    TeamController(ITeamsRepository repository) {
        this.repository = repository;
    }


}
