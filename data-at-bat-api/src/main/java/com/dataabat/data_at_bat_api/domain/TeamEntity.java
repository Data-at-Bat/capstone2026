package com.dataabat.data_at_bat_api.domain;

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
    @Column(length=10, nullable = false)
    private String abbreviation;

    @Getter
    @Setter
    @Column(length=10)
    private String league;

    @Getter
    @Setter
    @Column(length=50)
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
    private short winsOfLastFive;

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


}
