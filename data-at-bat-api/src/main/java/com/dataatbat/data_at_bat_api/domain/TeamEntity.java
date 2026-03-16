package com.dataatbat.data_at_bat_api.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name="teams")
public class TeamEntity {
    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    @Getter
    @Setter
    @Column(name="team_id")
    private UUID teamId;

    @Getter
    @Setter
    @Column(nullable = false)
    private String name;

    @Getter
    @Setter
    @Column(length=3, nullable = false)
    private String abbreviation;

    @Getter
    @Setter
    @Column(length=64)
    private String league;

    @Getter
    @Setter
    @Column(length=32)
    private String division;

    @Getter
    @Setter
    @Column(name="created_at")
    private LocalDateTime createdAt;

    @Getter
    @Setter
    @Column(name="starting_pitcher")
    private String startingPitcher;

    @Getter
    @Setter
    @Column(name="wins_of_last_five")
    private Short winsOfLastFive;

    @Getter
    @Setter
    @Column(name="pitcher_war")
    private Double pitcherWar;

    @Getter
    @Setter
    @Column(name="season_on_base_percentage")
    private Double seasonOnBasePercentage;

    @Getter
    @Setter
    @Column(name="last_five_on_base_percentage")
    private Double lastFiveOnBasePercentage;

    @Getter
    @Setter
    private Integer wins;

    @Getter
    @Setter
    private Integer losses;

    TeamEntity() {
        createdAt = LocalDateTime.now();
    }

    public void partialUpdate(TeamEntity team) {
        if (team.getName() != null) {
            setName(team.getName());
        }
        if (team.getAbbreviation() != null) {
            setAbbreviation(team.getAbbreviation());
        }
        if (team.getLeague() != null) {
            setLeague(team.getLeague());
        }
        if (team.getDivision() != null) {
            setDivision(team.getDivision());
        }
        if (team.getCreatedAt() != null) {
            setCreatedAt(team.getCreatedAt());
        }
        if (team.getStartingPitcher() != null) {
            setStartingPitcher(team.getStartingPitcher());
        }
        if (team.getWinsOfLastFive() != null) {
            setWinsOfLastFive(team.getWinsOfLastFive());
        }
        if (team.getPitcherWar() != null) {
            setPitcherWar(team.getPitcherWar());
        }
        if (team.getSeasonOnBasePercentage() != null) {
            setSeasonOnBasePercentage(team.getSeasonOnBasePercentage());
        }
        if (team.getLastFiveOnBasePercentage() != null) {
            setLastFiveOnBasePercentage(team.getLastFiveOnBasePercentage());
        }
        if (team.getWins() != null) {
            setWins(team.getWins());
        }
        if (team.getLosses() != null) {
            setLosses(team.getLosses());
        }
    }
}
