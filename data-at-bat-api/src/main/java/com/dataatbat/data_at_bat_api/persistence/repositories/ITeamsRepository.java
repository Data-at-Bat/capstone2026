package com.dataatbat.data_at_bat_api.persistence.repositories;

import com.dataatbat.data_at_bat_api.domain.TeamEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.UUID;

public interface ITeamsRepository extends CrudRepository<TeamEntity, UUID> {
    TeamEntity findByName(String name);
    List<TeamEntity> findByNameIn(List<String> names);
    TeamEntity findByAbbreviation(String abbreviation);
    List<TeamEntity> findByAbbreviationIn(List<String> abbreviations);
    List<TeamEntity> findByLeague(String league);
    List<TeamEntity> findByLeagueIn(List<String> leagues);
    List<TeamEntity> findByDivision(String division);
    List<TeamEntity> findByDivisionIn(List<String> divisions);

    void deleteByName(String name);
    void deleteByNameIn(List<String> names);
    void deleteByAbbreviation(String abbreviation);
    void deleteByAbbreviationIn(List<String> abbreviations);
    void deleteByLeague(String league);
    void deleteByLeagueIn(List<String> leagues);
    void deleteByDivision(String division);
    void deleteByDivisionIn(List<String> divisions);
}
