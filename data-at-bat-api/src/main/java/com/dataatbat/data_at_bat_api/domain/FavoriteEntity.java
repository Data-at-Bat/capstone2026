package com.dataatbat.data_at_bat_api.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.util.UUID;

@Entity
@Table(name="favorites")
public class FavoriteEntity {
    @Getter
    @Setter
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Getter
    @Setter
    @Column(name="team_id", nullable = false)
    private UUID teamId;

    @Getter
    @Setter
    @Column(name="user_id", nullable = false)
    private String userId;

    protected FavoriteEntity() {}

    public FavoriteEntity(UUID team_Id, String user_Id) {
        teamId = team_Id;
        userId = user_Id;
    }

    @Override
    public String toString() {
        return String.format("{ID: %s Team_ID: %s User_ID: %s}",
                (id != null) ? id.toString() : "NULL",
                (teamId != null) ? teamId.toString() : "NULL",
                (userId != null) ? userId.toString() : "NULL"
                );
    }
}
