package com.dataabat.data_at_bat_api.persistence;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "favorites")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FavoritesEntity {

    @Id
    @Column(name = "id", length = 128, nullable = false)
    private String id;

    @Column(name = "user_id", length = 128, nullable = false)
    private String userId;

    @Column(name = "team_id", length = 128, nullable = false)
    private String teamId;
}