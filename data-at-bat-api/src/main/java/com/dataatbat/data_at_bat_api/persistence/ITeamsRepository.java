package com.dataatbat.data_at_bat_api.persistence;

import com.dataatbat.data_at_bat_api.domain.TeamEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.UUID;

public interface ITeamsRepository extends CrudRepository<TeamEntity, UUID> {
    TeamEntity findByName(String name);
    Iterable<TeamEntity> findByNameIn(Iterable<String> names);
    TeamEntity findByAbbreviation(String abbreviation);
    Iterable<TeamEntity> findByAbbreviationIn(Iterable<String> abbreviations);
    Iterable<TeamEntity> findByLeague(String league);
    Iterable<TeamEntity> findByLeagueIn(Iterable<String> leagues);
    Iterable<TeamEntity> findByDivision(String division);
    Iterable<TeamEntity> findByDivisionIn(Iterable<String> divisions);
    Iterable<TeamEntity> findByTeamIdIn(Iterable<UUID> teamIds);

    void deleteByName(String name);
    void deleteByNameIn(Iterable<String> names);
    void deleteByAbbreviation(String abbreviation);
    void deleteByAbbreviationIn(Iterable<String> abbreviations);
    void deleteByLeague(String league);
    void deleteByLeagueIn(Iterable<String> leagues);
    void deleteByDivision(String division);
    void deleteByDivisionIn(Iterable<String> divisions);
}
